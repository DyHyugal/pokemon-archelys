extends SceneTree
const Mon=preload("res://scripts/domain/pokemon.gd")
const State=preload("res://scripts/domain/demo_state.gd")
const Transport=preload("res://scripts/services/showdown_transport.gd")
var checks:=0
var failures:=0
var folder: String=""
func check(ok: bool,label: String) -> void:
 checks+=1
 if not ok:failures+=1;push_error(label)
func _initialize() -> void:call_deferred("run")
func finish_dialogue(game: Node) -> void:
 while not game.dialogue_lines.is_empty():game.advance_dialogue()
 while game.scene.active:game.advance_scene()
func settle(game: Node) -> void:
 var end: int=Time.get_ticks_msec()+12000
 while game.battle.busy and Time.get_ticks_msec()<end:await create_timer(.01).timeout
 check(not game.battle.busy and game.battle.last_error.is_empty(),"Native Showdown replies")
func read_messages(game: Node) -> void:
 var limit:=0
 while game.battle_panel.visible and game.battle_panel.event_index<game.battle.events.size() and limit<100:game.battle_panel.advance();limit+=1
func shot(game: Node,id: String,overview: bool=false) -> void:
 if folder.is_empty() or DisplayServer.get_name()=="headless":return
 game.set_process(false)
 if overview:
  game.world.camera.size=44;game.world.camera.position=Vector3(0,29,33);game.world.camera.look_at(Vector3(0,0,-2))
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png(folder+"/"+id+".png")==OK,"Real demo render "+id)
 game.set_process(true)
func run() -> void:
 for arg: String in OS.get_cmdline_user_args():
  if arg.begins_with("--demo-proof="):folder=arg.trim_prefix("--demo-proof=")
 var world: Node=load("res://main.tscn").instantiate();world.preferences_path="user://tests_demo_locale.json";world.comfort=preload("res://scripts/services/comfort_store.gd").new("user://tests_demo_comfort_"+("headless" if folder.is_empty() else "render")+".json");root.add_child(world)
 await process_frame;await process_frame
 var session: Node=root.get_node("Session");var before: Dictionary=session.campaign.adventure.snapshot()
 var game: Node=world.demo_game;game.save_path="user://tests_demo_scene.json" if folder.is_empty() else "user://tests_demo_render.json";DirAccess.remove_absolute(game.save_path)
 world.camera.size=17
 check(game.open(world) and game.active and not world.world_geometry.visible,"Demo opens while preserving laboratory")
 check(game.world.camera.size==17,"Demo restores saved camera distance")
 game.new_demo();await process_frame
 await shot(game,"00-starters")
 check(game.modal.find_child("Starter_charmander",true,false)!=null,"Actual starter selector available")
 game.modal.find_child("Starter_charmander",true,false).pressed.emit();finish_dialogue(game)
 check(game.state.starter=="charmander" and game.state.campaign.adventure.team.size()==1 and game.state.campaign.adventure.team[0].level==6,"One chosen starter replaces only demo roster")
 check(not game.choose_starter("squirtle") and session.campaign.adventure.snapshot()==before,"Starter selection cannot duplicate or mutate laboratory")
 check(FileAccess.file_exists(game.save_path) and State.validate(JSON.parse_string(FileAccess.get_file_as_string(game.save_path))),"Starter saves immediately in a valid demo file")
 await process_frame
 if not folder.is_empty():
  world.comfort.set_option("resolution","1920x1080");world._apply_comfort()
  await shot(game,"01-harbor",true)
 game.open_menu("appearance")
 game.menu.body.get_node("Appearance_skin").item_selected.emit(2);game.menu.body.get_node("Appearance_style").item_selected.emit(1)
 check(game.state.campaign.adventure.appearance.skin==2 and game.world.hero.has_meta("tripo_pilot") and game.world.hero.get_meta("appearance").skin==2,"Character controls update Tripo pilot appearance without changing saved schema")
 await shot(game,"02-character")
 game.menu.close();game.world.follow()
 var old: Vector3=game.state.position
 for i: int in range(20):game.world.move_hero(Vector2(-1,0),.04,game.state)
 check(game.state.position.x<old.x-1 and session.campaign.adventure.snapshot()==before,"Walking demo changes no laboratory party/state")
 check(not game.world.can_walk(Vector3(-15,0,-2)) and not game.world.can_walk(Vector3(15,0,12)) and game.world.can_walk(Vector3(11,0,12)),"Buildings and harbor water blocked, pier accessible")
 game.interact("supplies");finish_dialogue(game);var balls: int=game.state.campaign.adventure.bag['poke-ball']
 game.interact("supplies");finish_dialogue(game);check(game.state.campaign.adventure.bag['poke-ball']==balls,"Crate received only once")
 game.interact("door-shop");check(game.state.location=="shop","Actual doorway enters shop")
 game.interact("merchant");var a: RefCounted=game.state.campaign.adventure;var cash: int=a.money
 game.menu.commerce_pages.offer({"kind":"item","item":"poke-ball","count":1,"sell":false});game.menu.body.get_node("CommerceConfirmation/ConfirmCommerce").pressed.emit()
 check(a.money==cash-200 and a.bag['poke-ball']==balls+1,"Shop confirmation changes actual demo bag and money")
 await shot(game,"03-shop")
 game.menu.close();game.interact("exit");game.interact("door-center");a.team[0].hp=1;game.interact("nurse");finish_dialogue(game)
 check(a.team[0].hp==Mon.stats(a.team[0]).hp and game.state.location=="center","Actual Center heals demo roster")
 game.interact("exit");game.interact("vyna");finish_dialogue(game);game.interact("gate")
 check(game.state.location=="trail","Town gate enters playable trail")
 game.interact("trainer");check(not game.battle_panel.visible and game.modal!=null,"Trainer requires beacon survey first");finish_dialogue(game)
 game.interact("survey");finish_dialogue(game)
 await shot(game,"04-trail")
 a.team[0]=Mon.make("charmander",10,1);a.next_uid=2;a.heal_team()
 game.interact("trainer");check(game.battle_panel.visible and game.arena!=null,"Trainer opens native battle plus 3D Pokemon arena")
 await settle(game)
 check(game.arena.species[0]=="charmander" or game.arena.battle.current(0).species=="charmander","Battle presents actual chosen Pokemon")
 await shot(game,"05-battle")
 read_messages(game)
 await shot(game,"06-battle-commands")
 var turns:=0
 while game.battle.active and turns<30:
  var moves: Array=game.battle.available_moves(0);var slot: int=0
  for index: int in moves:
   if game.battle.current(0).moves[index].id=="ember":slot=index
  game.battle_panel.execute({"kind":"move","slot":slot});await settle(game);read_messages(game);turns+=1
 check(game.battle.result=="won" and game.state.flags.has("trainer") and not game.battle_panel.visible,"Native battle victory completes trainer objective")
 game.interact("exit");game.interact("vyna");finish_dialogue(game)
 check(game.state.flags.has("complete"),"Vyna closes real demo quest")
 game.save_game();var data: Variant=JSON.parse_string(FileAccess.get_file_as_string(game.save_path))
 check(State.validate(data) and data.flags.complete,"Demo saved with story, roster, inventory and avatar")
 game.state.campaign.adventure.appearance.skin=0;game.load_game()
 check(game.state.flags.has("complete") and game.state.campaign.adventure.appearance.skin==2,"Loading restores demo progress and appearance")
 game.close();await process_frame
 check(not game.active and world.world_geometry.visible and session.campaign.adventure.snapshot()==before,"Returning restores laboratory unchanged")
 var base: String=ProjectSettings.globalize_path("res://../builds")
 check(Transport.resolve(base,true).error.is_empty(),"Export-layout Windows binary and bridge resolve without standalone feature")
 var paths: Dictionary=Transport.resolve(base.path_join("missing"),true)
 check(paths.error.contains("Bridge absent"),"Missing runtime has precise actionable error")
 print("DEMO SCENE: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
