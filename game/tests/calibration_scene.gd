extends SceneTree
const Layouts=preload("res://scripts/world/drawn_layouts.gd")
var checks:=0
var failures:=0
var folder: String=""
func check(ok: bool,label: String) -> void:
 checks+=1
 if not ok:failures+=1;push_error(label)
func _initialize() -> void:run.call_deferred()
func finish_text(game: Node) -> void:
 while not game.dialogue_lines.is_empty():game.advance_dialogue()
 while game.scene.active:game.advance_scene()
func screenshot() -> Image:
 for i: int in range(3):await process_frame
 await RenderingServer.frame_post_draw
 return root.get_texture().get_image()
func save_shot(name: String) -> void:
 if folder.is_empty() or DisplayServer.get_name()=="headless":return
 var im: Image=await screenshot();check(im.save_png(folder+"/"+name+".png")==OK,"Rendered proof: "+name)
func run() -> void:
 for arg: String in OS.get_cmdline_user_args():
  if arg.begins_with("--calibration-proof="):folder=arg.trim_prefix("--calibration-proof=")
 var owner: Node=load("res://main.tscn").instantiate();owner.preferences_path="user://calibration_tests_locale.json";owner.comfort=preload("res://scripts/services/comfort_store.gd").new("user://calibration_tests_comfort.json");root.add_child(owner)
 await process_frame;await process_frame
 if not folder.is_empty():owner.comfort.set_option("resolution","1920x1080");owner._apply_comfort()
 var original: Dictionary=root.get_node("Session").campaign.snapshot()
 var game: Node=owner.demo_game;game.enable_drawn();game.save_path="user://calibration_tests_demo.json";check(game.open(owner),"Calibration demo opens")
 game.new_demo();game.choose_starter("charmander");finish_text(game)
 await process_frame;await process_frame
 var view: Node=game.hd2d_view
 game.open_menu("appearance")
 var previews: Array=game.menu.body.find_children("*","TextureRect",true,false)
 check(previews.any(func(node: TextureRect):return node.texture is AtlasTexture and node.texture.atlas.resource_path.ends_with("calibration/hero-sheet.png")),"Character menu uses the same new protagonist")
 game.menu.close()
 check(view.actors.y_sort_enabled and view.trees.size()==10,"Independent trees and real depth sorting")
 check(view.project(Vector3.RIGHT).length()==view.project(Vector3.FORWARD).length(),"Square world projection, no axial stretch")
 var density: float=view.zoom_for(Vector2(1920,1080))
 game.travel("home");await process_frame;await process_frame
 check(is_equal_approx(view.zoom_for(Vector2(1920,1080)),density),"Identical avatar/camera density indoors and outdoors")
 game.travel("town");await process_frame;await process_frame
 # Exercise walking speed independently from frame rate, direction, sprint
 # and game acceleration, in a corridor with no interfering colliders.
 game.set_process(false);view.set_process(false)
 var old_scale: float=Engine.time_scale
 for multiplier: float in [1.0,4.0]:
  Engine.time_scale=multiplier
  for fps: int in [15,30,60]:
   for running: bool in [false,true]:
    var travelled: Array=[]
    for axis: Vector2 in [Vector2.RIGHT,Vector2.DOWN,Vector2.ONE]:
     game.state.position=Vector3(0,0,-7);game.world.hero.position=game.state.position
     var start: Vector3=game.state.position;var count: int=ceili(fps*.1)
     for i: int in range(count):game.world.move_hero(axis,.1/count*multiplier,game.state,running)
     travelled.append(start.distance_to(game.state.position))
    var expected: float=(Layouts.RUN_SPEED if running else Layouts.WALK_SPEED)*.1*multiplier
    check(travelled.all(func(distance: float):return absf(distance-expected)<.0001),"Same speed on x/y/diagonal at %d FPS, run=%s, multiplier=%s" % [fps,running,multiplier])
 Engine.time_scale=old_scale
 for direction: int in range(4):
  view.set_frame(view.hero,direction,0)
  var standing: Image=view.hero_texture.get_image().get_region(Rect2i(view.hero.region_rect))
  view.set_frame(view.hero,direction,1)
  var step: Image=view.hero_texture.get_image().get_region(Rect2i(view.hero.region_rect))
  check(standing.get_data()!=step.get_data(),"Real different idle/step pixels for direction "+str(direction))
  check(is_equal_approx(view.hero.get_rect().size.y*view.hero.scale.y,Layouts.HERO_HEIGHT) and is_zero_approx((view.hero.offset.y+view.hero.region_rect.size.y)*view.hero.scale.y),"Normalized height and foot pivot for direction "+str(direction))
 for axis: Vector2 in [Vector2.DOWN,Vector2.LEFT,Vector2.UP,Vector2.RIGHT]:
  game.state.position=Vector3(0,0,-7);view.last_position=game.state.position;view.stride=0
  game.world.move_hero(axis,.05,game.state);view._process(.05)
  var moving_frame: int=view.hero.get_meta("frame")
  check(moving_frame%3!=0,"Actual displacement selects a walking pose")
  view._process(.05);check(view.hero.get_meta("frame")%3==0,"No displacement stops animation")
 view.set_process(true)
 game.state.position=Vector3(0,0,7);game.world.hero.position=game.state.position
 game.contextual.hide();await process_frame;await process_frame
 var before_preview: Dictionary=game.state.snapshot()
 game.calibration_controls();check(game.modal!=null and game.modal.find_child("PreviewLava",true,false)!=null,"Owner calibration controls available")
 game.clear_modal();view.set_grid(true);view.set_surface_mode("lava");await process_frame;await process_frame
 check(view.water.texture==view.surfaces.lava and game.state.snapshot()==before_preview,"Lava preview changes only material, not story/save")
 await save_shot("08-lave-apercu")
 view.set_grid(false);view.set_surface_mode("water")
 var tree: Sprite2D=view.trees.filter(func(node: Sprite2D):return absf(node.position.x+128)<1 and absf(node.position.y-281.6)<1)[0]
 check(not game.world.can_walk(Vector3(-2,0,4.4)) and game.world.can_walk(Vector3(-2,0,3.6)) and game.world.can_walk(Vector3(-2,0,5.2)),"Tree trunk blocks, front and rear approaches remain accessible")
 game.state.position=Vector3(-2,0,3.6);game.world.hero.position=game.state.position;await process_frame;await process_frame
 check(view.hero.get_parent()==tree.get_parent() and view.hero.position.y<tree.position.y and tree.material.get_shader_parameter("opacity")<1,"Hero sorts behind crown and crown fades for readability")
 await save_shot("06-derriere-arbre")
 game.state.position=Vector3(-2,0,5.2);game.world.hero.position=game.state.position;await process_frame;await process_frame
 check(view.hero.position.y>tree.position.y and tree.material.get_shader_parameter("opacity")==1.0,"Hero sorts in front, crown returns opaque")
 await save_shot("07-devant-arbre")
 if DisplayServer.get_name()!="headless":
  game.state.position=Vector3(0,0,7);game.world.hero.position=game.state.position;await process_frame;await process_frame
  var water_region:=Rect2i(760,1010,240,32)
  var a: Image=await screenshot()
  # Canvas coordinates can be 1280x720 while the rendered image is FHD.
  # Inspect the actual crown pixels, not an unscaled piece of nearby ground.
  var canvas_box: Rect2=(tree.get_global_transform()*tree.get_rect()).grow(4)
  var capture_scale: Vector2=Vector2(a.get_size())/root.get_visible_rect().size
  var crown_region:=Rect2i(Rect2(canvas_box.position*capture_scale,canvas_box.size*capture_scale).intersection(Rect2(Vector2.ZERO,Vector2(a.get_size()))))
  await create_timer(.8).timeout;var b: Image=await screenshot()
  check(a.get_region(water_region).get_data()!=b.get_region(water_region).get_data(),"GPU-rendered water actually animates")
  check(a.get_region(crown_region).get_data()!=b.get_region(crown_region).get_data(),"GPU-rendered tree crown actually animates")
  owner.comfort.data.reduced_motion=true;await process_frame;await process_frame
  a=await screenshot();await create_timer(.8).timeout;b=await screenshot()
  check(a.get_region(water_region).get_data()==b.get_region(water_region).get_data() and a.get_region(crown_region).get_data()==b.get_region(crown_region).get_data(),"Reduce motion freezes actual surface and foliage pixels")
  owner.comfort.data.reduced_motion=false
  view.set_surface_mode("lava");a=await screenshot();await create_timer(.8).timeout;b=await screenshot()
  check(a.get_region(water_region).get_data()!=b.get_region(water_region).get_data(),"GPU-rendered lava preview actually animates")
 view.set_surface_mode("water");game.set_process(true);game.close();await process_frame
 check(root.get_node("Session").campaign.snapshot()==original,"Calibration leaves workshop campaign intact")
 print("CALIBRATION SCENE: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
