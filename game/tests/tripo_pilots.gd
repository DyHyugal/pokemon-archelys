extends SceneTree
const Actor=preload("res://scripts/world/tripo_actor.gd")
const Appearance=preload("res://scripts/domain/appearance.gd")
var checks:=0
var failures:=0
var folder: String=""
func check(ok: bool,label: String) -> void:
 checks+=1
 if not ok:failures+=1;push_error(label)
func _initialize() -> void:call_deferred("run")
func shot(id: String) -> void:
 if folder.is_empty():return
 for i: int in range(5):await process_frame
 await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png(folder+"/"+id+".png")==OK,"Rendered screenshot: "+id)
func run() -> void:
 for arg: String in OS.get_cmdline_user_args():
  if arg.begins_with("--tripo-proof="):folder=arg.trim_prefix("--tripo-proof=")
 var owner: Node=load("res://main.tscn").instantiate();owner.preferences_path="user://tests_tripo_preferences.json";owner.comfort=preload("res://scripts/services/comfort_store.gd").new("user://tests_tripo_comfort.json");root.add_child(owner)
 await process_frame;await process_frame
 var session: Node=root.get_node("Session");var original: Dictionary=session.campaign.adventure.snapshot()
 var game: Node=owner.demo_game;game.save_path="user://tests_tripo_demo.json"
 check(game.open(owner),"Actual demo opens with Tripo pilots")
 game.new_demo();game.choose_starter("charmander")
 while not game.dialogue_lines.is_empty():game.advance_dialogue()
 var shop: Node3D=game.world.geometry.get_node("TripoShop")
 check(shop!=null and shop.scale.is_equal_approx(Vector3.ONE*6.975),"Registry shop replaces only the intended town building at normalized scale")
 var meshes: Array=shop.find_children("*","MeshInstance3D",true,false)
 check(meshes.size()==1 and meshes[0].mesh.get_faces().size()/3<=21000,"Shop uses the reduced geometry, not 1.77M source")
 check(not game.world.can_walk(Vector3(14,0,-12)) and not game.world.can_walk(Vector3(14,0,-9.4)),"Shop footprint remains blocked, including its forward edge")
 game.state.position=game.world.points['door-shop'];game.world.hero.position=game.state.position
 check(game.world.can_walk(game.state.position) and game.world.nearest()=="door-shop","Actual shop doorway remains walkable and nearest interaction")
 game.interact();check(game.state.location=="shop","Door enters the existing functional shop")
 game.interact("exit");check(game.state.location=="town" and game.state.position.is_equal_approx(game.world.points['door-shop']) and game.world.can_walk(game.state.position),"Shop exit returns outside enlarged footprint at actual door")
 var old_save: Dictionary=game.state.snapshot()
 game.state.position=Vector3(15,0,-8.7);game.world.build(game.state)
 check(game.state.position.is_equal_approx(game.world.points['door-shop']) and game.state.campaign.snapshot()==old_save.campaign and game.state.flags==old_save.flags,"Older doorstep saves are safely repositioned without losing progression")
 var hero: Node3D=game.world.hero
 check(hero.has_meta("tripo_pilot") and hero.find_child("AnimationPlayer",true,false)!=null,"Actual supplied rigged chibi is used")
 var animator: AnimationPlayer=hero.find_child("AnimationPlayer",true,false)
 check(animator.has_animation("walk") and animator.has_animation("run") and animator.has_animation("idle"),"Supplied walk/run and derived stationary pose available")
 Actor.animate(hero,true,false,Actor.WALK_SPEED);animator.advance(.3)
 check(animator.current_animation=="walk" and animator.is_playing(),"Walk actually plays")
 Actor.animate(hero,true,true,Actor.RUN_SPEED);animator.advance(.3)
 check(animator.current_animation=="run" and animator.is_playing(),"Run actually plays")
 for name: String in ["walk","run"]:
  var animation: Animation=animator.get_animation(name)
  for track: int in range(animation.get_track_count()):
   if animation.track_get_type(track)==Animation.TYPE_POSITION_3D and str(animation.track_get_path(track)).contains("Hips"):
    var first: Vector3=animation.track_get_key_value(track,0)
    var constant:=true
    for key: int in range(animation.track_get_key_count(track)):
     var value: Vector3=animation.track_get_key_value(track,key)
     constant=constant and is_equal_approx(value.x,first.x) and is_equal_approx(value.z,first.z)
    check(constant and animation.loop_mode==Animation.LOOP_LINEAR,"No horizontal root drift across "+name+" loop")
 Actor.animate(hero,false,false);animator.advance(.2)
 check(animator.current_animation=="idle","Stop selects stationary pose")
 var parts: Array=hero.find_children("*","MeshInstance3D",true,false)
 check(parts.size()==1 and parts[0].mesh.get_faces().size()/3<=20000,"Avatar uses reduced geometry")
 var m: ShaderMaterial=parts[0].material_override
 check(m.get_shader_parameter("base_texture") is Texture2D and not m.get_shader_parameter("change_skin"),"Original embedded texture is preserved for default appearance")
 var look: Dictionary=Appearance.DEFAULT.duplicate();look.skin=2;Actor.apply(hero,look)
 check(m.get_shader_parameter("change_skin") and m.get_shader_parameter("skin_tint")==Appearance.color(look,"skin"),"Palette selection reaches actual shader")
 var other: Node3D=Actor.create();root.add_child(other);Actor.apply(other,Appearance.DEFAULT)
 var other_mat: ShaderMaterial=other.find_children("*","MeshInstance3D",true,false)[0].material_override
 check(other_mat!=m and not other_mat.get_shader_parameter("change_skin"),"Preview material does not mutate world avatar")
 other.queue_free();Actor.apply(hero,Appearance.DEFAULT)
 Actor.animate(hero,true,false,Actor.WALK_SPEED)
 game.open_menu("appearance");game._process(.02)
 check(animator.current_animation=="idle","Modal/menu stops locomotion animation")
 check(game.preview_actor.has_meta("tripo_pilot") and game.menu.body.get_node("Appearance_style").disabled and game.menu.body.get_node("Appearance_face").disabled,"Preview uses same model and unsupported selectors are explicit")
 if not folder.is_empty():
  root.size=Vector2i(1920,1080);await shot("01-avatar-menu")
 game.menu.close();game.set_process(false)
 var start: Vector3=game.state.position
 game.state.position=Vector3(6,0,-6);game.world.hero.position=game.state.position
 game.world.camera.size=13;game.world.follow();await shot("02-shop-and-hero")
 game.world.camera.size=6;game.world.camera.position=Vector3(14,7,-3);game.world.camera.look_at(Vector3(14,2,-12));await shot("03-shop-close")
 game.state.position=Vector3(0,0,2);game.world.hero.position=game.state.position;game.world.camera.size=4;game.world.follow();await shot("04-avatar-close")
 if not folder.is_empty():
  Actor.animate(hero,true,false,Actor.WALK_SPEED);animator.advance(.35);animator.speed_scale=0;await shot("05-avatar-walk")
  Actor.animate(hero,true,true,Actor.RUN_SPEED);animator.advance(.25);animator.speed_scale=0;await shot("06-avatar-run")
  Actor.animate(hero,false,false);animator.advance(.2)

 # Feed scaled engine delta for equal REAL durations, including 15/30 FPS.
 var prior_scale: float=Engine.time_scale
 for fps: float in [60.0,30.0,15.0]:
  for running: bool in [false,true]:
   var baseline:=0.0
   for multiplier: float in [1.0,2.0,4.0]:
    Engine.time_scale=multiplier;game.state.position=Vector3(0,0,5);game.world.hero.position=game.state.position
    for frame: int in range(5):game.world.move_hero(Vector2.RIGHT,multiplier/fps,game.state,running)
    var distance: float=game.state.position.x
    if multiplier==1:baseline=distance
    check(is_equal_approx(distance,baseline*multiplier),"Actual displacement x"+str(multiplier)+" at "+str(fps)+" FPS, running="+str(running))
 Engine.time_scale=1;game.state.position=Vector3(0,0,5)
 game.world.move_hero(Vector2.RIGHT,.04,game.state,true)
 check(is_equal_approx(game.state.position.x,.216),"New run actually travels 5.4 units/second")
 Engine.time_scale=4;game.state.position=Vector3(14,0,-5)
 for frame: int in range(10):game.world.move_hero(Vector2.UP,.16,game.state,true)
 check(game.world.can_walk(game.state.position) and game.state.position.z>game.world.shop_blocker().end.y+.22,"Fast x4 run cannot tunnel through enlarged shop")
 Engine.time_scale=prior_scale;game.state.position=Vector3(0,0,2)
 for i: int in range(10):game.world.move_hero(Vector2(1,0),.04,game.state)
 check(game.state.position.x>.5 and StateIsValid(game.state),"Rigged hero can move while state remains valid")
 game.save_game();var saved: Dictionary=game.state.snapshot();game.state.position=Vector3.ZERO;game.load_game()
 check(game.state.snapshot()==saved,"Save/load preserves existing demo schema and progression")
 game.close();await process_frame
 check(session.campaign.adventure.snapshot()==original,"Workshop save/state unchanged by pilot integration")
 print("TRIPO PILOTS: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
func StateIsValid(state: RefCounted) -> bool:
 return preload("res://scripts/domain/demo_state.gd").validate(state.snapshot())
