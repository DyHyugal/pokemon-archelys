extends SceneTree
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
var failures: int=0
func check(ok: bool,label: String) -> void:
	if not ok:failures+=1;push_error(label)
func drain(world: Node) -> void:
	while world.battle_panel.event_index<world.pokemon_battle.events.size():world.battle_panel.advance()
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var world: Node=load("res://main.tscn").instantiate();world.preferences_path="user://tests_exploration_preferences.json";root.add_child(world)
	await process_frame;await process_frame
	var session: Node=root.get_node("Session");var a: RefCounted=session.campaign.adventure
	world._contextual_action("shop-door");await process_frame
	check(a.exploration.location=="shop" and world.displayed_location=="shop","Door rebuilds shop interior")
	world._contextual_action("counter");check(world.pause_menu.visible and world.pause_menu.page=="services","Counter opens actual shopping menu")
	var old_money: int=a.money;var old_count: int=a.bag.potion
	world.pause_menu.exploration_pages.transaction("potion",1,false)
	check(a.money==old_money-200 and a.bag.potion==old_count+1,"Shopping UI updates money and inventory")
	world.pause_menu.buttons.save.pressed.emit();world.pause_menu.close();world._travel("village")
	world._load();await process_frame;a=session.campaign.adventure
	check(a.exploration.location=="shop" and world.displayed_location=="shop","Disk load restores correct interior geometry")
	world._travel("center");a.team[0].hp=1;world._contextual_action("nurse");check(a.team[0].hp>1,"Center interaction heals real team")
	world._travel("cove");world._contextual_action("fish")
	check(world.pokemon_battle.active and world.pokemon_battle.current(1).species=="magikarp","Fishing launches real legal-stage encounter")
	drain(world);world.battle_panel.execute({"kind":"run"});drain(world)
	check(not world.battle_panel.visible,"Fishing encounter returns cleanly to exploration")
	check(not session._can_step(Vector2(4,-2),Vector2(4,-4)),"Water movement blocked before Surf")
	world._contextual_action("surf");check(not a.exploration.cleared.has("surf"),"Surf interaction cannot bypass story lock")
	a.victories["trainer-1"]=true;world._contextual_action("surf");check(a.exploration.cleared.has("surf") and session._can_step(Vector2(4,-3),Vector2(4,-4)),"Surf permits water exploration without compatible party")
	world._travel("village");check(not a.exploration.cleared.has("surf"),"Leaving cove clears active Surf state")
	check(not session._can_step(Vector2(10,3),Vector2(11,3)),"Unbroken field rock blocks movement")
	world._contextual_action("rock-smash");check(session._can_step(Vector2(10,3),Vector2(11,3)),"Contextual Rock Smash removes collision as well as marker")
	world._contextual_action("climb");check(session.campaign.players[1].position[1]==3.0,"Rock Climb reaches elevated terrain without party compatibility")
	world._contextual_action("climb");check(session.campaign.players[1].position[1]==0.0,"Rock Climb also permits descent")
	world._travel("district");await process_frame
	var camera_count: int=0
	for child: Node in world.get_children():
		if child is Camera3D:camera_count+=1
	check(camera_count==1 and world.world_geometry.get_child_count()>0,"Travel keeps one camera and creates district prototype")
	world._contextual_action("visuals");check(world.visual_variant==1,"Preview interaction cycles comparative direction")
	world._travel("village");world._open_menu("map")
	check(world.pause_menu.body.get_child_count()>3,"Map renders destinations and Fly controls")
	world.pause_menu.travel_requested.emit("cove",true);check(a.exploration.location=="cove" and not world.pause_menu.visible,"Map flight travels to visited destination and closes modal")
	world._travel("village");world._mega_kit();check(a.team.size()==6 and a.team[3].item=="venusaurite","Technical Mega kit integrates legal forms and stones")
	world._start_support_test("electric");check(world.battle_panel.visible and world.pokemon_battle.field.terrain=="","Terrain test launches through actual controls")
	world.pokemon_battle.finish("won");drain(world)
	world._start_double_test();drain(world)
	check(world.battle_panel.cards.text.contains("double") and world.battle_panel.actions.get_child_count()>=4,"Double UI shows four actors and target controls")
	click_double_move(world);check(world.pokemon_battle.turn==0 and world.pokemon_battle.queued.size()==1,"First double button queues action")
	click_double_move(world);check(world.pokemon_battle.turn==1,"Second double button resolves global turn")
	world.pokemon_battle.finish("won");drain(world)
	Engine.time_scale=1.0
	print("EXPLORATION SCENE: shop/center/doors, saved interior, fishing/Surf, field collisions/climb, map/Fly, graphical alternatives and actual double controls; %d failures" % failures)
	quit(1 if failures else 0)

func click_double_move(world: Node) -> void:
	for control: Node in world.battle_panel.actions.get_children():
		if control is Button and not control is CheckButton and control.text.contains("→"):control.pressed.emit();return
