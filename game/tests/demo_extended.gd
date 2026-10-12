extends SceneTree
const State=preload("res://scripts/domain/demo_state.gd")
const Expedition=preload("res://scripts/domain/demo_expedition.gd")
const Archive=preload("res://scripts/services/demo_archive.gd")
const Slots=preload("res://scripts/services/demo_slots.gd")
const Dex=preload("res://scripts/domain/demo_dex.gd")
const Mon=preload("res://scripts/domain/pokemon.gd")
var checks: int=0
var failures: int=0
var folder: String=""
func _initialize() -> void:call_deferred("run")
func check(ok: bool,label: String) -> void:
 checks+=1
 if not ok:failures+=1;push_error(label)
func clear_text(game: Node) -> void:
 while not game.dialogue_lines.is_empty():game.advance_dialogue()
 while game.scene.active:game.advance_scene()
func shot(id: String) -> void:
 if folder.is_empty() or DisplayServer.get_name()=="headless":return
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png(folder+"/"+id+".png")==OK,"Actual render "+id)
func run() -> void:
 for arg: String in OS.get_cmdline_user_args():
  if arg.begins_with("--d72-proof="):folder=arg.trim_prefix("--d72-proof=")
 var state:=State.new();state.choose("squirtle")
 check(not Expedition.perform(state,"cut"),"No field action before story unlock")
 state.flags.survey=true
 for action: String in Expedition.ACTIONS:
  check(Expedition.perform(state,action) and not Expedition.perform(state,action),"Story action once, regardless of compatible species: "+action)
 check(Expedition.open_cache(state) and not Expedition.open_cache(state),"Optional notes collected once")
 state.campaign.adventure.bag['poke-ball']=999
 check(not Expedition.reward(state) and not state.flags.has("expedition-reward"),"Full bag preserves unclaimed reward")
 state.campaign.adventure.bag['poke-ball']=3
 check(Expedition.reward(state) and state.campaign.adventure.bag['poke-ball']==8 and not Expedition.reward(state),"Reward atomic and nonrepeatable")
 check(State.validate(state.snapshot()),"Expedition valid save")
 var bad: Dictionary=state.snapshot();bad.flags.erase("rock-cleared");check(not State.validate(bad),"Forged expedition dependency refused")
 check(not Expedition.can_fly(state,"town"),"Fly requires conclusion")
 state.flags.trainer=true;state.flags.complete=true
 check(Expedition.can_fly(state,"town") and not Expedition.can_fly(state,"trail"),"Only visited unlocked stops can Fly")
 state.travel("trail");check(Expedition.can_fly(state,"trail"),"Visited trail becomes Fly stop")
 state.campaign.adventure.in_battle=true;check(not Expedition.can_fly(state,"town") and not Expedition.perform(state,"strength"),"Field actions blocked in combat");state.campaign.adventure.in_battle=false
 var old: Dictionary=state.snapshot();old.erase("autosave");var restored:=State.new();check(restored.restore(old) and restored.autosave,"Legacy demo save migrates new option")
 var archive_path: String="user://tests_d72_archive.json"
 var exported: int=Archive.export_file(state,archive_path);var roundtrip:=State.new()
 check(exported==OK and roundtrip.restore(Archive.read_file(archive_path)) and roundtrip.snapshot()==state.snapshot(),"Actual exported file round-trip")
 var f:=FileAccess.open(archive_path+".bad",FileAccess.WRITE);f.store_string('{"format":"unknown"}');f.close()
 check(Archive.read_file(archive_path+".bad").is_empty() and Archive.inspect(archive_path+".bad").status=="invalid","Malformed imported save refused")
 check(Dex.habitats("magikarp")[0].method=="fishing" and not Dex.habitats("bulbasaur").is_empty() and Dex.habitats("bulbasaur").all(func(place: Dictionary):return place.place=="canopy"),"Demo habitats describe real pools, no lab-only habitats")
 var history: RefCounted=state.campaign.adventure.records
 check(Dex.roster(history,0,"pika","en").is_empty(),"Search never reveals undiscovered species")
 history.observe("pikachu",true);check(Dex.roster(history,2,"pika","en")==["pikachu"],"Known species search and ownership filter")
 var owner: Node=load("res://main.tscn").instantiate();owner.preferences_path="user://tests_d72_preferences.json";root.add_child(owner);await process_frame
 var baseline: Dictionary=root.get_node("Session").campaign.snapshot();var game: Node=owner.demo_game;game.save_path="user://tests_d72_demo.json"
 for i: int in range(1,4):
  for suffix: String in ["",".backup",".auto",".auto.backup"]:DirAccess.remove_absolute(Slots.path(game.save_path,i)+suffix)
 game.open(owner);game.new_demo();game.choose_starter("squirtle");clear_text(game)
 check(Slots.read_auto(game.save_path,1).starter=="squirtle","New starter replaces previous slot autosave consistently")
 game.interact("vyna");check(game.scene.active and not game.state.campaign.adventure.records.scenes.has("demo-arrival"),"Actual Vyna starts uns skippable manual scene")
 var step: int=game.scene.index;game._process(.1);check(game.scene.index==step and not game.scene.skip(),"No elapsed-time advance or skip")
 await shot("01-arrival");clear_text(game);check(game.state.campaign.adventure.records.scenes.has("demo-arrival"),"Scene saved only when completed")
 game.open_menu("pc");check(game.menu.body.get_node_or_null("StorageInspect")==null,"PC menu outside Center cannot manipulate storage")
 game.open_menu("team");game.menu.adventure_pages.selected_uid=1;game.menu.render();check(game.menu.body.get_node("DepositInPC").disabled,"Summary cannot bypass local PC requirement")
 game.open_menu("services");check(game.menu.body.find_child("ShopQuantity_potion",true,false)==null,"Shop unavailable outside actual shop")
 game.menu.close();game.travel("shop");game.open_menu("services")
 check(game.menu.body.find_child("ShopQuantity_potion",true,false)!=null,"Real shop services still work")
 var a: RefCounted=game.state.campaign.adventure;var money: int=a.money;var count: int=a.bag.potion
 # Transaction through actual confirmation UI.
 game.menu.commerce_pages.offer({"kind":"item","item":"potion","count":1,"sell":false});game.menu.body.get_node("CommerceConfirmation/ConfirmCommerce").pressed.emit()
 check(a.money<money and a.bag.potion==count+1,"Confirmed purchase changes actual save")
 game.menu.close();check(Slots.read_auto(game.save_path,1).campaign.adventure.bag.potion==count+1,"Leaving services persists purchase")
 game.travel("center");game.open_menu("pc");check(game.menu.body.get_node_or_null("StorageGrid")!=null,"Actual Center PC accessible")
 game.menu.close();game.travel("trail");game.interact("survey");clear_text(game)
 for action: String in Expedition.ACTIONS:
  check(game.world.points.has(action),"Obstacle present before interaction "+action)
  game.interact(action);clear_text(game);check(not game.world.points.has(action),"Clearing removes actual obstacle "+action)
 game.interact("expedition-cache");clear_text(game);game.travel("town");game.interact("professor");game.modal.find_child("ExpeditionReward",true,false).pressed.emit();clear_text(game)
 check(game.state.flags.has("expedition-reward"),"Optional quest reachable through physical professor")
 game.state.flags.trainer=true;game.interact("vyna");clear_text(game)
 check(game.state.flags.complete and a.records.scenes.has("demo-return"),"Conclusion unlocks replay and Fly")
 var cap: int=a.cap;var bag: Dictionary=a.bag.duplicate();var camera: Transform3D=game.world.camera.transform
 game.open_menu("cinema");game.menu.body.get_node("Replay_demo-return").pressed.emit();clear_text(game)
 check(a.cap==cap and a.bag==bag and game.world.camera.transform==camera,"Replay restores camera and gives no rewards")
 game.open_menu("map");check(not game.menu.body.get_node("Fly_trail").disabled,"Actual map Fly control unlocks")
 game.menu.body.get_node("Fly_trail").pressed.emit();check(game.state.location=="trail" and game.world.can_walk(game.state.position),"Map Fly transfers to legal landing")
 var manual: Dictionary=Slots.read(game.save_path,1);a.money=42;game.auto_save()
 check(Slots.read(game.save_path,1)==manual and Slots.read_auto(game.save_path,1).campaign.adventure.money==42,"Autosave preserves manual checkpoint")
 game.open_menu("bag");game.menu.close();check(Slots.read(game.save_path,1)==manual,"Menu auto-persistence cannot overwrite manual checkpoint")
 game.open_menu("saves");check(game.menu.body.get_node_or_null("LoadDemoAuto1")!=null,"Separate autosave load available")
 game.menu.body.get_node("DemoAutosave").toggled.emit(false);check(not game.state.autosave,"Autosave setting persists")
 await shot("02-saves");game.menu.close()
 game.open_menu("dex");a.records.observe("magikarp",true);game.menu.render();game.menu.body.get_node("Dex_magikarp").pressed.emit();await shot("03-dex")
 check(game.menu.body.get_node("BackDemoDex")!=null,"Actual dex details reachable")
 game.open_menu("assets");check(game.menu.body.get_child_count()>0,"Empty import registry explained in UI")
 var inspector:=preload("res://scripts/ui/demo_extended_pages.gd").new(game)
 inspector.preview_node(load("res://assets/demo/shop.glb").instantiate())
 check(game.menu.body.get_node_or_null("ImportedModelPreview")!=null,"Inspector loads actual GLB into isolated viewport")
 await shot("04-model-inspector")
 game.menu.close()
 var before: Dictionary=game.state.snapshot();game.confirm_import(archive_path+".bad");check(game.state.snapshot()==before,"Invalid import preserves live campaign")
 game.confirm_import(archive_path);check(game.modal.find_child("ConfirmDemoImport",true,false)!=null,"Import requires concrete confirmation")
 game.modal.find_child("ConfirmDemoImport",true,false).pressed.emit();check(game.state.starter=="squirtle" and game.state.flags.has("expedition-reward"),"Confirmed imported expedition restores")
 check(not Slots.read(game.save_path,1,true).is_empty(),"Import retains previous valid disk copy")
 check(Slots.read_auto(game.save_path,1).flags.has("expedition-reward"),"Imported campaign replaces stale autosave consistently")
 game.menu.close();clear_text(game)
 check(game.begin_battle([Mon.make("rattata",5,900000)]),"Actual battle still opens after portable import")
 var deadline: int=Time.get_ticks_msec()+12000
 while game.battle.busy and Time.get_ticks_msec()<deadline:await create_timer(.01).timeout
 check(not game.battle.busy and game.battle.last_error.is_empty(),"Native Showdown returns turn after new services")
 game.battle_panel.locale="en";game.battle_panel.render();game.battle_panel._process(.1)
 check(game.battle_panel.player_label.text.contains("HP") and game.battle_panel.enemy_label.text.contains("Lv."),"Battle stat cards localized")
 check(game.battle_panel.field_label.get_parent() is PanelContainer and game.battle_panel.panel.offset_right<game.battle_panel.action_panel.offset_left,"Battle field readable; messages and actions separated")
 await shot("05-battle")
 game.battle.finish("escaped");game.battle_panel.event_index=game.battle.events.size();game.battle_panel.render()
 game.close();check(root.get_node("Session").campaign.snapshot()==baseline,"Entire lot isolated from workshop")
 print("DEMO EXTENDED: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
