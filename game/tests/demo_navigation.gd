extends SceneTree
const State=preload("res://scripts/domain/demo_state.gd")
const Slots=preload("res://scripts/services/demo_slots.gd")
const Guidance=preload("res://scripts/domain/demo_guidance.gd")
var failures:=0
var checks:=0
var folder: String=""
func check(ok: bool,label: String) -> void:
 checks+=1
 if not ok:failures+=1;push_error(label)
func _initialize() -> void:call_deferred("run")
func finish_text(g: Node) -> void:
 while not g.dialogue_lines.is_empty():g.advance_dialogue()
func shot(id: String) -> void:
 if folder.is_empty() or DisplayServer.get_name()=="headless":return
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png(folder+"/"+id+".png")==OK,"Actual menu render "+id)
func run() -> void:
 for arg: String in OS.get_cmdline_user_args():
  if arg.begins_with("--d70-proof="):folder=arg.trim_prefix("--d70-proof=")
 var owner: Node=load("res://main.tscn").instantiate();owner.preferences_path="user://tests_d70_locale.json";root.add_child(owner);await process_frame
 var game: Node=owner.demo_game;game.save_path="user://tests_demo_navigation.json"
 for index: int in range(1,4):
  for suffix: String in ["",".backup"]:DirAccess.remove_absolute(Slots.path(game.save_path,index)+suffix)
 var original: Dictionary=root.get_node("Session").campaign.snapshot()
 game.open(owner);game.new_demo();game.choose_starter("bulbasaur");finish_text(game)
 check(Slots.path(game.save_path,1)==game.save_path and Slots.path(game.save_path,0).is_empty(),"Legacy slot1 path preserved, invalid index refused")
 check(Guidance.target(game.state)=="gate","Initial next objective points to actual exit")
 game.open_menu("journal");await shot("01-journal");check(game.menu.body.get_node_or_null("OpenLocalMap")!=null,"Journal available through actual pause UI")
 game.menu.body.get_node("OpenLocalMap").pressed.emit();await process_frame;await shot("02-map");check(game.menu.page=="map" and game.menu.body.get_child(0).state==game.state,"Journal opens map using actual campaign coordinates")
 game.menu.close();game.travel("center");game.travel("town")
 check(game.state.position.distance_to(game.world.points['door-center'])<.3 and game.world.can_walk(game.state.position),"Center exits at accessible doorstep")
 game.travel("trail");check(Guidance.target(game.state)=="survey","Trail guidance points to beacon")
 game.state.flags.survey=true;check(Guidance.target(game.state)=="trainer","Survey switches guidance to trainer")
 game.state.flags.trainer=true;game.travel("town");check(Guidance.target(game.state)=="vyna","Victory guides back to Vyna")
 game.state.flags.complete=true;check(Guidance.target(game.state).is_empty() and Guidance.tasks(game.state,"fr").all(func(row: Dictionary):return row.done),"Completed journal contains no outstanding objective")
 game.save_game();var first: Dictionary=Slots.read(game.save_path,1)
 game.active_slot=2;game.new_demo();game.choose_starter("squirtle");finish_text(game)
 check(Slots.read(game.save_path,1)==first and Slots.read(game.save_path,2).starter=="squirtle","Independent slots keep first campaign intact")
 game.state.campaign.adventure.money=123;game.save_game()
 check(Slots.read(game.save_path,2,true).campaign.adventure.money==600,"Previous slot copy is retained")
 check(game.load_slot(1) and game.state.starter=="bulbasaur" and game.state.flags.complete,"Loading restores complete first campaign")
 game.open_menu("saves");await shot("03-saves");game.menu.close()
 var before: Dictionary=game.state.snapshot();check(not game.load_slot(3) and game.state.snapshot()==before and game.active_slot==1,"Invalid load preserves current campaign and active slot")
 game.menu.close();check(game.load_slot(2,true) and game.state.campaign.adventure.money==600,"Backup restore loads previous campaign")
 game.open_menu("settings");game.menu.language_changed.emit("en");check(game.locale=="en" and game.menu.locale=="en","Language changes active demo menu immediately")
 game.menu.language_changed.emit("fr");game.menu.close()
 # Selecting an empty slot at welcome must not autosave the old campaign into it.
 game.active_slot=3;game.save_game();check(not FileAccess.file_exists(Slots.path(game.save_path,3)),"Save ownership differs from slot highlighted at welcome")
 game.close();game.open(owner);game.active_slot=2
 var f:=FileAccess.open(Slots.path(game.save_path,2),FileAccess.WRITE);f.store_string("invalid");f.close();game.welcome()
 check(game.modal.find_child("RecoverDemo",true,false)!=null and game.modal.find_child("ContinueDemo",true,false)==null,"Welcome offers backup recovery for corrupt primary slot")
 game.modal.find_child("RecoverDemo",true,false).pressed.emit();check(game.state.starter=="squirtle" and game.loaded_slot==2,"Recovery uses valid backup without rebuilding a starter")
 game.close();check(not Slots.read(game.save_path,2,true).is_empty(),"Saving recovered game preserves its valid backup")
 check(root.get_node("Session").campaign.snapshot()==original,"Demo slot/map operations do not alter workshop campaign")
 print("DEMO NAVIGATION: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
