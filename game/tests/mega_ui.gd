extends SceneTree
const Mon=preload("res://scripts/domain/pokemon.gd")
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
var failures: int=0
func check(ok: bool,label: String) -> void:
	if not ok:failures+=1;push_error(label)
func drain(world: Node) -> void:
	var deadline: int=Time.get_ticks_msec()+12000
	while world.pokemon_battle.busy and Time.get_ticks_msec()<deadline:await create_timer(0.01).timeout
	check(not world.pokemon_battle.busy and world.pokemon_battle.last_error.is_empty(),"Showdown response arrives without simulator error")
	while world.battle_panel.event_index<world.pokemon_battle.events.size():world.battle_panel.advance()
	if world.battle_panel.visible and not world.pokemon_battle.active:world.battle_panel.render()
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var world: Node=load("res://main.tscn").instantiate();world.preferences_path="user://tests_mega_ui_prefs.json";root.add_child(world)
	await process_frame;await process_frame
	var a: RefCounted=root.get_node("Session").campaign.adventure
	# Owner reproduction: evolved original Charizard, not the kit-created duplicate.
	var original:=Mon.make("charizard",37,1);original.hp=70;original.item="leftovers";original.moves[0].pp-=1
	a.team[0]=original;var before: Dictionary=original.duplicate(true)
	world._begin_pokemon_battle([Mon.make("wartortle",35,900000)]);await drain(world)
	world.battle_panel.choice_page="moves";world.battle_panel.render()
	var toggle: CheckButton=world.battle_panel.actions.get_node("MegaToggle")
	check(toggle.disabled and toggle.text.contains("pierre"),"Unequipped evolved Charizard shows visible disabled checkbox and reason")
	world.pokemon_battle.finish("escaped");await drain(world)
	var old_leftovers: int=a.bag.leftovers;world._mega_kit()
	check(a.team[0].uid==1 and a.team[0].species=="charizard" and a.team[0].level==37 and a.team[0].hp==70 and a.team[0].moves==before.moves and a.team[0].iv==before.iv,"Kit preserves original individual, level, HP, PP and IV")
	check(a.team[0].item=="charizardite-y" and a.bag.leftovers==old_leftovers+1,"Kit equips original Charizard and returns previous item to Bag")
	var count: int=a.team.size()+a.boxes.size();var leftovers: int=a.bag.leftovers
	world._mega_kit();check(a.team.size()+a.boxes.size()==count and a.bag.leftovers==leftovers,"Repeated kit does not duplicate Pokémon or returned items")
	world._begin_pokemon_battle([Mon.make("wartortle",35,900000)]);await drain(world)
	world.battle_panel.choice_page="moves";world.battle_panel.render();toggle=world.battle_panel.actions.get_node("MegaToggle")
	check(not toggle.disabled and not toggle.button_pressed,"Compatible equipped Charizard exposes usable checkbox")
	toggle.button_pressed=true
	check(world.battle_panel.mega_selected,"Actual UI checkbox sets Mega selection")
	for control: Node in world.battle_panel.actions.get_children():
		if control is Button and not control is CheckButton and control.text.contains("PP"):control.pressed.emit();break
	await drain(world)
	check(world.pokemon_battle.mega_used[0] and a.team[0].has("battle_form") and world.pokemon_battle.field.weather=="sun","Actual move button triggers Mega Y and its Drought")
	await drain(world);world.battle_panel.choice_page="moves";world.battle_panel.render();toggle=world.battle_panel.actions.get_node("MegaToggle")
	check(toggle.disabled and toggle.text.contains("déjà"),"Spent Mega checkbox explains one-per-battle limit")
	world.pokemon_battle.finish("escaped");await drain(world)
	check(not a.team[0].has("battle_form") and a.team[0].item=="charizardite-y","After battle original form and reusable held stone preserved")
	a.bag["charizardite-x"]=1;a.equip(1,"charizardite-x");world._mega_kit()
	check(a.team[0].item=="charizardite-x","Kit preserves compatible alternative Charizard X stone")
	world._start_double_test();await drain(world);toggle=world.battle_panel.actions.get_node("MegaToggle")
	check(not toggle.disabled,"Doubles uses the same available Mega checkbox")
	toggle.button_pressed=true
	for control: Node in world.battle_panel.actions.get_children():
		if control is Button and not control is CheckButton and control.text.contains("→"):control.pressed.emit();break
	toggle=world.battle_panel.actions.get_node("MegaToggle")
	check(toggle.disabled and toggle.text.contains("réservée"),"Second doubles actor cannot reserve a second Mega")
	world.pokemon_battle.finish("won");await drain(world)
	world._open_menu("rules")
	check(not world.pause_menu.body.get_children().any(func(node: Node):return node is Button and node.text.contains("Activer le défi")),"Deferred challenge offers no new activation control")
	Engine.time_scale=1
	print("MEGA UI: existing evolved individual, equipment/Bag preservation, visible checkbox/reasons, single and doubles activation; %d failures" % failures)
	quit(1 if failures else 0)
