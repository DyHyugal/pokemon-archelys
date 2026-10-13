extends SceneTree
const State=preload("res://scripts/domain/demo_state.gd")
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
func shot(id: String) -> void:
 if folder.is_empty() or DisplayServer.get_name()=="headless":return
 for i: int in range(4):await process_frame
 await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png(folder+"/"+id+".png")==OK,"Actual HD2D screenshot "+id)
func run() -> void:
 for arg: String in OS.get_cmdline_user_args():
  if arg.begins_with("--hd2d-proof="):folder=arg.trim_prefix("--hd2d-proof=")
 var owner: Node=load("res://main.tscn").instantiate();owner.preferences_path="user://hd2d_tests_locale.json";owner.comfort=preload("res://scripts/services/comfort_store.gd").new("user://hd2d_tests_comfort.json");root.add_child(owner)
 await process_frame;await process_frame
 if not folder.is_empty():owner.comfort.set_option("resolution","1920x1080");owner._apply_comfort()
 var original: Dictionary=root.get_node("Session").campaign.snapshot()
 var game: Node=owner.demo_game;game.save_path="user://hd2d_tests_demo.json";game.use_hd2d=true
 check(game.open(owner),"2D demo opens")
 game.new_demo();game.choose_starter("charmander");finish_text(game);await process_frame;await process_frame
 check(game.world.logic_only and game.world.geometry.get_child_count()==0,"Main world has no live 3D scenery")
 check(game.hd2d_view.hero_sprite.texture!=null and game.hd2d_view.actors.y_sort_enabled,"Real 2D hero, native y ordering")
 var cache: Dictionary=game.hd2d_view.data
 check(cache.sprites.size()==105 and cache.layouts.size()==8,"37 props and 68 real rig-derived frames")
 check(cache.sprites['hero-0-walk-1'].path!=cache.sprites['hero-0-walk-2'].path,"Separate walking frames")
 for direction: int in range(4):
  for clip: String in ["walk","run"]:
   var a: Image=load(cache.sprites['hero-%d-%s-1' % [direction,clip]].path).get_image();var b: Image=load(cache.sprites['hero-%d-%s-3' % [direction,clip]].path).get_image()
   check(a.get_data()!=b.get_data(),"Actual animated pixels for direction/clip %d/%s" % [direction,clip])
 game.state.position=Vector3(0,0,2);game.world.hero.position=game.state.position;game.hd2d_view.last_position=game.state.position;game.hd2d_view.direction=0;await process_frame;await process_frame
 await shot("01-rue")
 var pos: Vector3=game.state.position
 for i: int in range(10):game.world.move_hero(Vector2.RIGHT,.04,game.state,true)
 await process_frame;await process_frame
 check(game.state.position.x>pos.x+1 and game.hd2d_view.hero.position.is_equal_approx(game.hd2d_view.project(game.state.position)),"Existing movement drives rendered 2D hero")
 game.state.position=game.world.points['door-home'];game.world.hero.position=game.state.position;game.interact("door-home");await process_frame
 check(game.state.location=="home" and game.world.logic_only,"Actual door reaches native 2D interior")
 await shot("02-maison")
 game.interact("exit");finish_text(game);await process_frame
 check(game.state.location=="town" and game.world.can_walk(game.state.position),"Safe return at house doorway")
 game.open_menu("bag");await shot("03-sac");game.menu.close()
 game.save_game();var saved: Dictionary=game.state.snapshot();game.state.position=Vector3.ZERO;game.load_game();await process_frame
 check(game.state.snapshot()==saved,"Same save schema and 2D position restored")
 game.state.location="trail";game.state.position=Vector3(0,0,9);game.world.build(game.state);game.state.flags.survey=true;await process_frame
 await shot("04-sentier")
 check(game.world.points.has("cut"),"Story obstacle initially present")
 game.interact("cut");finish_text(game);await process_frame
 check(not game.world.points.has("cut") and game.world.can_walk(Vector3(-5,0,2)),"Contextual field action removes collision in 2D")
 game.state.location="center";game.state.position=Vector3(0,0,9);game.world.build(game.state);await process_frame;await shot("05-centre")
 check(game.world.nearest()=="exit","Interior exit interaction remains available")
 game.menu.close();finish_text(game)
 check(game.begin_battle([preload("res://scripts/domain/pokemon.gd").make("magikarp",5,900)]),"Native Showdown battle starts in 2D")
 var deadline: int=Time.get_ticks_msec()+12000
 while game.battle.busy and Time.get_ticks_msec()<deadline:await create_timer(.01).timeout
 check(not game.battle.busy and game.battle.last_error.is_empty() and game.arena==null,"Real Showdown reply with no live 3D arena")
 while game.battle_panel.event_index<game.battle.events.size():game.battle_panel.advance()
 var pp: int=game.state.campaign.adventure.team[0].moves[0].pp
 check(game.battle.execute({"kind":"move","slot":0}),"Real attack accepted")
 deadline=Time.get_ticks_msec()+12000
 while game.battle.busy and Time.get_ticks_msec()<deadline:await create_timer(.01).timeout
 check(not game.battle.busy and game.state.campaign.adventure.team[0].moves[0].pp==pp-1,"Native attack spends one PP")
 while game.battle_panel.event_index<game.battle.events.size():game.battle_panel.advance()
 await shot("06-combat")
 check(game.battle.execute({"kind":"run"}),"Existing flee command accepted")
 var guard:=0
 while game.battle_panel.visible and guard<50:game.battle_panel.advance();guard+=1;await process_frame
 await process_frame;await process_frame
 check(not game.battle_panel.visible and game.hd2d_view.visible,"Return to 2D exploration after combat")
 game.close();await process_frame
 check(root.get_node("Session").campaign.snapshot()==original,"Workshop campaign untouched")
 check(game.hd2d_view==null,"2D view freed on close")
 print("HD2D SCENE: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
