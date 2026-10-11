extends SceneTree
const Mon=preload("res://scripts/domain/pokemon.gd")
var checks:=0
var failures:=0
func check(value: bool,message: String) -> void:
	checks+=1
	if not value:failures+=1;push_error(message)
func press(menu: CanvasLayer,text: String) -> bool:
	for node: Node in menu.body.get_children():
		if node is Button and not node.disabled and node.text.contains(text):node.pressed.emit();return true
	return false
func settle(world: Node) -> void:
	var limit: int=Time.get_ticks_msec()+12000
	while world.pokemon_battle.busy and Time.get_ticks_msec()<limit:await create_timer(0.01).timeout
	check(not world.pokemon_battle.busy,"actual Showdown response arrives")
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var world: Node=load("res://main.tscn").instantiate();world.preferences_path="user://tests_journey_prefs.json";root.add_child(world)
	await process_frame;await process_frame
	world._set_locale("fr")
	var a: RefCounted=root.get_node("Session").campaign.adventure
	world._open_menu("journey")
	check(press(world.pause_menu,"Commencer") and world.cinematic.active,"real Adventure button starts prologue")
	world._travel("trail");world._save()
	check(a.exploration.location=="village" and world.cinematic.active,"main scene blocks travel/save")
	for i: int in range(3):world.cinematic_panel.next_button.pressed.emit()
	check(not world.cinematic.active and a.records.scenes.has("slice-prologue") and world.pause_menu.page=="journey","manual scene finishes and returns to Adventure")
	world.pause_menu.close();world._contextual_action("journey-gate");await process_frame
	check(a.exploration.location=="trail" and world.displayed_location=="trail","physical gateway enters rendered trail")
	world._contextual_action("trial-gate")
	check(a.exploration.location=="trail","physical trial gate rejects unfinished beacon")
	world._contextual_action("beacon");world._contextual_action("trial-gate");await process_frame
	check(a.exploration.location=="trial" and a.journey.flags.has("beacon"),"beacon opens actual trial scene")
	# Strong test fixture shortens combat, not a campaign reward or gameplay helper.
	a.cap=100;a.team=[Mon.make("charizard",100,1)];a.next_uid=2
	world._contextual_action("slice-boss");await settle(world)
	check(world.pokemon_battle.trainer=="slice-boss","physical keeper launches real trainer battle")
	var turns:=0
	while world.pokemon_battle.active and turns<15:
		var choices: Array=world.pokemon_battle.available_moves(0)
		if world.pokemon_battle.replacement_needed():break
		var slot: int=choices[-1] if not choices.is_empty() else -1
		world.pokemon_battle.execute({"kind":"move","slot":slot});await settle(world);turns+=1
	check(world.pokemon_battle.result=="won" and a.journey.flags.has("boss"),"actual Showdown win completes milestone")
	while world.battle_panel.event_index<world.pokemon_battle.events.size():world.battle_panel.advance()
	world._open_menu("journey")
	check(press(world.pause_menu,"Voir la conclusion") and world.cinematic.active,"actual completion button starts ending")
	for i: int in range(2):world.cinematic_panel.next_button.pressed.emit()
	check(a.journey.flags.has("ending") and not world.cinematic.active,"ending finishes whole playable opening")
	world.pause_menu.close();world._contextual_action("exit-trial");world._contextual_action("exit")
	check(a.exploration.location=="village","return journey reaches village without losing flags")
	world.queue_free();await process_frame
	print("JOURNEY SCENE: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
