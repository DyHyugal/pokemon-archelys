extends SceneTree
const Mon=preload("res://scripts/domain/pokemon.gd")
var failures: int=0
func check(ok: bool,label: String) -> void:
	if not ok:failures+=1;push_error(label)
func key(code: Key,pressed: bool=true,echo: bool=false) -> void:
	var event:=InputEventKey.new();event.keycode=code;event.physical_keycode=code;event.pressed=pressed;event.echo=echo;root.push_input(event,true)
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene: PackedScene=load("res://main.tscn");var world: Node=scene.instantiate();world.preferences_path="user://tests_pokemon_scene_preferences.json";DirAccess.remove_absolute(world.preferences_path);root.add_child(world)
	await process_frame;await process_frame
	var session: Node=root.get_node("Session");var a: RefCounted=session.campaign.adventure
	world._open_menu("team");world.pause_menu.adventure_pages.selected_uid=int(a.team[0].uid);world.pause_menu.render()
	check(world.pause_menu.page=="team" and world.pause_menu.adventure_pages.iv_controls.size()==6,"Summary renders real editable IV/EV controls")
	var pages: RefCounted=world.pause_menu.adventure_pages
	pages.iv_controls[1].value=31;pages.ev_controls[1].value=252;pages.ev_controls[5].value=252;pages.nature_control.select(3)
	for control: Node in world.pause_menu.body.get_children():
		if control is Button and control.text.begins_with("Appliquer"):control.pressed.emit();break
	check(a.team[0].iv[1]==31 and a.team[0].ev[1]==252 and a.team[0].nature=="adamant","Summary Apply updates actual model")
	world.pause_menu.page="pc";world.pause_menu.render();check(world.pause_menu.body.get_child(1).text.contains("vide"),"PC page shows empty state")
	world.pause_menu.close()
	# Walk distance in grass triggers an actual wild battle without a menu command.
	session.campaign.players[1].position=[-6.0,0.0,-5.0];session.latest=session.campaign.snapshot();world.last_walk_position=Vector3(-6,0,-5);a.encounter_steps=3.45
	var movement:=InputEventKey.new();movement.physical_keycode=KEY_D;movement.pressed=true;Input.parse_input_event(movement.duplicate())
	for step: int in range(10):await physics_frame
	movement.pressed=false;Input.parse_input_event(movement.duplicate())
	check(world.battle_panel.visible and world.pokemon_battle.active and world.pokemon_battle.trainer=="","Grass movement triggers wild battle UI")
	var stopped: Array=session.campaign.players[1].position.duplicate();var index: int=world.battle_panel.event_index
	key(KEY_E,true,true);check(world.battle_panel.event_index==index,"Held confirmation cannot skip battle text")
	movement.pressed=true;Input.parse_input_event(movement.duplicate())
	for step: int in range(20):await physics_frame
	movement.pressed=false;Input.parse_input_event(movement.duplicate())
	key(KEY_ESCAPE);check(world.battle_panel.visible and not world.pause_menu.visible and session.campaign.players[1].position==stopped,"Combat owns input and blocks menu/movement")
	while world.battle_panel.event_index<world.pokemon_battle.events.size():key(KEY_E);key(KEY_E,false)
	world.battle_panel.choice_page="moves";world.battle_panel.render()
	check(world.battle_panel.actions.get_child_count()>=2,"Battle renders move controls")
	var pp: int=world.pokemon_battle.current(0).moves[0].pp
	for control: Node in world.battle_panel.actions.get_children():
		if control is Button and not control is CheckButton and control.text.contains("PP"):control.pressed.emit();break
	check(world.pokemon_battle.turn==1 and world.pokemon_battle.current(0).moves[0].pp==pp-1,"Actual move button resolves command and PP")
	world.battle_panel.execute({"kind":"run"})
	while world.battle_panel.visible:key(KEY_E);key(KEY_E,false)
	check(not world.pokemon_battle.active and not world.battle_panel.visible,"Manual battle messages finish and return to world")
	# Capture through the same UI, with full party; RNG fixed only in this test.
	a.heal_team()
	while a.team.size()<6:a.add(Mon.make("rattata",8,a.next_uid))
	var enemy:=Mon.make("rattata",8,900000);enemy.hp=1;enemy.status="sleep";enemy.status_turns=3
	world._begin_pokemon_battle([enemy]);world.pokemon_battle.rng.seed=1
	while world.battle_panel.event_index<world.pokemon_battle.events.size():key(KEY_E);key(KEY_E,false)
	world.battle_panel.choice_page="bag";world.battle_panel.render();world.battle_panel.actions.get_child(1).pressed.emit()
	while world.battle_panel.visible:key(KEY_E);key(KEY_E,false)
	check(a.boxes.size()==1 and a.team.size()==6,"Ball button sends capture to PC when party full")
	world._open_menu("pc");check(world.pause_menu.body.get_child_count()>1,"PC refreshes newly captured Pokémon")
	world.pause_menu.buttons.save.pressed.emit();a.team[0].iv[1]=0;a.boxes=[]
	world.pause_menu.buttons.load.pressed.emit();a=session.campaign.adventure
	check(a.team[0].iv[1]==31 and a.boxes.size()==1 and world.pause_menu.feedback.text=="Chargée","Menu disk save/load restores edits and captured PC member")
	world.pause_menu.close();a.raise_cap(18);a.gain_experience(int(a.team[0].uid),100000);world._open_menu("choices")
	check(world.pause_menu.body.get_child_count()>2,"Learning page presents real pending move/evolution choices")
	while not a.pending.is_empty():
		world.pause_menu.render();world.pause_menu.body.get_child(2).pressed.emit()
	check(a.team[0].species=="ivysaur" and a.pending.is_empty(),"Learning and evolution buttons resolve all pending decisions")
	world.pause_menu.close()
	print("POKEMON SCENE: summary editing, grass encounter, combat commands/manual text, modal input, full-party capture/PC, menu disk persistence and learning/evolution exercised; %d failures" % failures)
	quit(1 if failures else 0)
