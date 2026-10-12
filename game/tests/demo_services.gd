extends SceneTree
const Content=preload("res://scripts/domain/demo_content.gd")
const Assets=preload("res://scripts/services/imported_assets.gd")
const Mon=preload("res://scripts/domain/pokemon.gd")
const Fossils=preload("res://scripts/domain/fossils.gd")
const State=preload("res://scripts/domain/demo_state.gd")
var checks:=0
var failures:=0
var folder: String=""
func check(ok: bool,label: String) -> void:
 checks+=1
 if not ok:failures+=1;push_error(label)
func _initialize() -> void:call_deferred("run")
func finish_text(game: Node) -> void:
 while not game.dialogue_lines.is_empty():game.advance_dialogue()
func shot(id: String) -> void:
 if folder.is_empty() or DisplayServer.get_name()=="headless":return
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png(folder+"/"+id+".png")==OK,"Actual render "+id)
func run() -> void:
 for arg: String in OS.get_cmdline_user_args():
  if arg.begins_with("--d71-proof="):folder=arg.trim_prefix("--d71-proof=")
 var data: Dictionary=Content.data();check(Content.validate(data),"Fixture content validates")
 var bad: Dictionary=data.duplicate(true);bad.wild=["not-a-species"];check(not Content.validate(bad),"Unknown future species refused explicitly")
 bad=data.duplicate(true);bad.trainer=[{"species":"charizard","level":6}];check(not Content.validate(bad),"Illegal evolution level refused")
 check(Content.opponents().size()==2 and Assets.instantiate("shop")==null,"Data teams and unregistered import fallback")
 var manifest: Dictionary={"schema":1,"assets":{"shop":{"path":"res://assets/imported/shop.glb","scale":1,"rotation":0,"source":"Fixture","rights":"Original","sha256":"0".repeat(64)}}}
 check(Assets.validate(manifest),"Imported model metadata validates")
 manifest.assets.shop.path="res://assets/imported/../escape.glb";check(not Assets.validate(manifest),"Import stays in approved directory")
 var owner: Node=load("res://main.tscn").instantiate();owner.preferences_path="user://tests_d71_locale.json";root.add_child(owner);await process_frame
 var original: Dictionary=root.get_node("Session").campaign.snapshot();var game: Node=owner.demo_game;game.save_path="user://tests_d71_demo.json";game.open(owner);game.new_demo();game.choose_starter(data.starters[0]);finish_text(game)
 var a: RefCounted=game.state.campaign.adventure
 game.open_menu("rules");game.menu.body.get_node("DemoDifficulty").item_selected.emit(2);game.menu.body.get_node("DemoExperience").item_selected.emit(2);game.menu.body.get_node("DemoBattleStyle").item_selected.emit(1);game.menu.body.get_node("Rule_bag_healing").toggled.emit(false)
 check(a.exploration.difficulty=="hard" and a.exploration.exp_multiplier==3 and a.exploration.battle_style=="shift" and not a.exploration.bag_healing,"Actual rules controls change campaign")
 var cap: int=a.cap;game.menu.body.get_node("Rule_cap_enabled").toggled.emit(false);game.menu.body.get_node("Rule_cap_enabled").toggled.emit(true);check(a.cap==cap,"Cap option never lowers stored cap")
 await shot("01-rules");game.menu.close()
 game.open_menu("team");game.menu.adventure_pages.selected_uid=int(a.team[0].uid);game.menu.render();game.menu.body.get_node("SummaryShiny").toggled.emit(true)
 check(a.team[0].shiny and a.set_ability(int(a.team[0].uid),a.team[0].ability),"Summary chromatic and legal ability editing")
 a.in_battle=true;check(not a.set_shiny(int(a.team[0].uid),false) and a.team[0].shiny,"Chromatic editing blocked during battle");a.in_battle=false
 game.open_menu("bag");a.team[0].hp=1;var potions: int=a.bag.potion
 game.menu.body.get_node("Bag_potion").pressed.emit();game.menu.body.get_node("ItemTarget1").pressed.emit()
 check(a.team[0].hp>1 and a.bag.potion==potions-1,"Actual bag heals chosen member")
 a.heal_team();potions=a.bag.potion;game.menu.body.get_node("ItemTarget1").pressed.emit();check(a.bag.potion==potions,"No-effect bag action spends nothing")
 game.open_menu("bag");game.menu.body.get_node("Bag_lucky-egg").pressed.emit();game.menu.body.get_node("ItemTarget1").pressed.emit();check(a.team[0].item=="lucky-egg" and a.bag['lucky-egg']==0,"Held item assigned from actual bag")
 game.menu.close();game.interact("professor");
 game.modal.find_child("ProfessorIncubator",true,false).pressed.emit();game.menu.body.get_node("ReceiveDemoEgg").pressed.emit()
 check(a.nursery.eggs.size()==1 and a.nursery.received.size()==1,"Physical professor gives one configured egg")
 game.menu.body.get_node("ReceiveDemoEgg").pressed.emit();check(a.nursery.eggs.size()==1,"Duplicate gift refused")
 for i: int in range(25):a.nursery.walk(1)
 var egg_uid: int=a.nursery.eggs[0].mon.uid;game.menu.render();game.menu.body.get_node("HatchDemo%d" % egg_uid).pressed.emit();check(a.nursery.eggs.is_empty() and not a.find(egg_uid).is_empty(),"Walking gift hatches into actual roster")
 await shot("02-incubator");game.menu.close();game.travel("center")
 check(game.world.points.has("fossils") and Fossils.available(a),"Fossil researcher exists and accepts demo Center")
 check(Fossils.grant_samples(a) and Fossils.restore_fossil(a,"helix-fossil").result=="team","Actual Center restoration uses existing fossil service")
 check(not Fossils.grant_samples(a),"Fossil fixture samples cannot duplicate")
 check(a.team[-1].origin.location=="isle-center","Restoration origin records actual demo site")
 game.interact("fossils");await shot("03-center");game.menu.close();game.travel("town")
 game.open_menu("photo");var pose: Vector3=game.state.position;var transform: Transform3D=game.world.camera.transform
 game.menu.body.get_node("OpenDemoPhoto").pressed.emit();check(owner.photo_mode.active and owner.photo_mode.camera==game.world.camera,"Photo uses demo camera")
 game._process(.1);check(game.state.position==pose and not game.visible,"Photo locks movement and hides demo UI")
 if not folder.is_empty():
  owner.photo_mode.destination=folder;owner.photo_mode.capture()
  while owner.photo_mode.saving:await process_frame
  check(FileAccess.file_exists(owner.photo_mode.last_file),"Photo actually writes PNG")
 var back:=InputEventJoypadButton.new();back.button_index=JOY_BUTTON_B;back.pressed=true;game._input(back)
 check(game.visible and game.world.camera.transform==transform and game.menu.visible,"Photo restores exact camera/menu")
 game.menu.close();check(game.world.points.has("fish"),"Fishing available at actual dock")
 game.interact("fish");check(game.battle.active and game.battle.enemies[0].species==data.fishing,"Fishing launches real configured wild encounter")
 var deadline: int=Time.get_ticks_msec()+12000
 while game.battle.busy and Time.get_ticks_msec()<deadline:await create_timer(.01).timeout
 check(not game.battle.busy and game.battle.last_error.is_empty() and game.battle_panel.field_label.text.contains("Climat"),"Native Showdown and visible field conditions")
 game.battle.finish("escaped");game.battle_panel.event_index=game.battle.events.size();game.battle_panel.render()
 game.save_game();var saved: Dictionary=game.state.snapshot();check(State.validate(saved),"All service changes remain valid for disk save")
 game.load_game();check(game.state.campaign.adventure.team[0].shiny and game.state.campaign.adventure.exploration.difficulty=="hard" and game.state.campaign.adventure.nursery.received.size()==1,"Loading preserves rules, chromatic and gift state")
 game.close();check(root.get_node("Session").campaign.snapshot()==original,"Services never modify workshop campaign")
 print("DEMO SERVICES: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
