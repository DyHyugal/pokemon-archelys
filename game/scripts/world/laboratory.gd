extends Node3D

const PauseMenu = preload("res://scripts/ui/pause_menu.gd")
var pause_menu: CanvasLayer
var debug_panel: PanelContainer
var menu_button: Button
const World = preload("res://scripts/domain/world_rules.gd")
const Store = preload("res://scripts/services/save_store.gd")
const Dialogue = preload("res://scripts/domain/dialogue.gd")
const Preferences = preload("res://scripts/services/preferences_store.gd")
const TARGETS = World.INTERACTIONS
var preferences_path: String = Preferences.PATH
var preferences: Dictionary = {}
var interaction_records: Dictionary = {}
var active_interaction: String = ""
var journal_text: Label
var inventory_text: Label
var language_button: Button
var crate_mesh: MeshInstance3D
const GUIDE_POSITION = TARGETS.guide
const CAMERA_OFFSET := Vector3(0, 17, 18)
var dialogue := Dialogue.new()
var dialogue_record: Dictionary = {}
var dialogue_panel: PanelContainer
var dialogue_text: Label
var dialogue_speaker: Label
var interaction_hint: Label
var locale: String = "fr"

const Battle = preload("res://scripts/domain/battle.gd")
var avatars: Dictionary = {}
var camera: Camera3D
var status: Label
var message: Label
var address: LineEdit
var log_box: RichTextLabel
var battle := Battle.new()
const SAVE_PATH := "user://laboratory_campaign.json"

func _ready() -> void:
	preferences = Preferences.read(preferences_path)
	locale = preferences.language
	_build_world()
	_build_ui()
	_start_battle()
	for id: String in TARGETS:
		interaction_records[id] = JSON.parse_string(FileAccess.get_file_as_string("res://data/dialogues/laboratory_%s.json" % id))
	dialogue_record = interaction_records.guide
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="):
			capture_frame.call_deferred(arg.trim_prefix("--capture="))

func capture_frame(path: String) -> void:
	if "--capture-menu" in OS.get_cmdline_user_args(): _open_menu("settings")
	await get_tree().create_timer(1.0).timeout
	await RenderingServer.frame_post_draw
	var error := get_viewport().get_texture().get_image().save_png(path)
	print("CAPTURE: ", error_string(error))
	get_tree().quit(0 if error == OK else 1)

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	return material

func _mesh(shape: Mesh, at: Vector3, color: Color) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = shape
	instance.material_override = _material(color)
	instance.position = at
	add_child(instance)
	return instance

func _box(size: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
	var shape := BoxMesh.new()
	shape.size = size
	return _mesh(shape, at, color)

func _build_world() -> void:
	var environment := WorldEnvironment.new()
	var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color("8acfe2")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color("dae5ff")
	settings.ambient_light_energy = 0.25
	environment.environment = settings
	add_child(environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-52, -35, 0)
	light.light_energy = 0.65
	light.shadow_enabled = true
	add_child(light)
	_box(Vector3(85,0.2,85), Vector3(0,-0.65,0), Color("3ba8ba"))
	_box(Vector3(33,0.4,25), Vector3(0,-0.3,0), Color("e1c48c"))
	_box(Vector3(29,0.1,21), Vector3(0,-0.05,0), Color("86ad6b"))
	_box(Vector3(4,0.03,20), Vector3(0,0.025,0), Color("d4ba87"))
	_box(Vector3(23,0.03,3), Vector3(0,0.026,3), Color("d4ba87"))
	for pos: Vector2 in World.HOUSES:
		_box(Vector3(3.2,2.6,2.8), Vector3(pos.x,1.3,pos.y), Color("f0dcc0"))
		var roof := PrismMesh.new()
		roof.size = Vector3(3.7,1.4,3.2)
		_mesh(roof, Vector3(pos.x,3.3,pos.y), Color("be695a"))
		_box(Vector3(0.8,1.65,0.07), Vector3(pos.x,0.85,pos.y+1.44), Color("66554b"))
		for offset: float in [-0.95,0.95]:
			_box(Vector3(0.65,0.65,0.08),Vector3(pos.x+offset,1.6,pos.y+1.45),Color("569eb8"))
	for pos: Vector2 in World.TREES:
		var trunk := CylinderMesh.new()
		trunk.top_radius=0.2; trunk.bottom_radius=0.28; trunk.height=3.5
		_mesh(trunk,Vector3(pos.x,1.75,pos.y),Color("93785b"))
		for index: int in range(5):
			var leaf := _box(Vector3(0.8,0.15,3.3),Vector3(pos.x,3.5,pos.y),Color("3e8061"))
			leaf.rotation.y = float(index) * TAU/5.0
	var mountain := CylinderMesh.new()
	mountain.top_radius = 0.8; mountain.bottom_radius=6.0; mountain.height=6.0
	_mesh(mountain,Vector3(0,3,-16),Color("555965"))
	_box(Vector3(5.5,0.07,1.4),Vector3(0,0.08,-8.0),Color("74cabc"))
	camera = Camera3D.new()
	camera.projection=Camera3D.PROJECTION_ORTHOGONAL
	camera.size=float(preferences.camera_size)
	camera.position=CAMERA_OFFSET
	add_child(camera)
	camera.look_at(Vector3.ZERO)
	camera.current=true
	var guide: Node3D = load("res://assets/prototypes/mannequin.glb").instantiate()
	guide.position = GUIDE_POSITION
	add_child(guide)
	var label := Label3D.new()
	label.text = "Guide • PNJ de test"
	label.position.y = 2.2
	label.font_size = 28
	label.pixel_size = 0.004
	guide.add_child(label)
	_box(Vector3(0.2,1.4,0.2), TARGETS.sign+Vector3(0,0.7,0),Color("66554b"))
	_box(Vector3(1.6,0.8,0.15),TARGETS.sign+Vector3(0,1.5,0),Color("f0dcc0"))
	crate_mesh = _box(Vector3(1.2,0.8,1.2),TARGETS.crate+Vector3(0,0.4,0),Color("be895a"))

func _build_ui() -> void:
	var layer:=CanvasLayer.new();add_child(layer)
	var panel:=PanelContainer.new();panel.position=Vector2(16,16);panel.custom_minimum_size=Vector2(430,0);layer.add_child(panel)
	debug_panel=panel
	panel.visible=false
	menu_button=_button(layer,"Menu • Échap",func():_open_menu())
	menu_button.position=Vector2(16,16)
	var debug_toggle := CheckButton.new();debug_toggle.text="Outils labo • F3";debug_toggle.position=Vector2(180,16);layer.add_child(debug_toggle)
	debug_toggle.toggled.connect(func(value: bool):debug_panel.visible=value)
	panel.position=Vector2(16,65)
	var stack:=VBoxContainer.new();panel.add_child(stack)
	var title:=Label.new();title.text="ARCHÉLYS • LABORATOIRE TECHNIQUE";stack.add_child(title)
	var note:=Label.new();note.text="Décors provisoires — aucune île finale\nDéplacement : ZQSD / WASD / flèches";stack.add_child(note)
	status=Label.new();stack.add_child(status)
	var camera_label := Label.new();camera_label.text="Distance caméra (proche ← → loin)";stack.add_child(camera_label)
	var zoom := HSlider.new();zoom.min_value=12;zoom.max_value=22;zoom.step=0.5;zoom.value=camera.size;stack.add_child(zoom)
	zoom.value_changed.connect(func(value: float):
		camera.size=value
		_persist_preferences())
	language_button = _button(stack,"Langue des dialogues : Français",func():_set_locale("en" if locale=="fr" else "fr"))
	var network_toggle := CheckButton.new();network_toggle.text="Afficher l’ancien essai réseau (reporté)";stack.add_child(network_toggle)
	var network_tools := VBoxContainer.new();network_tools.visible=false;stack.add_child(network_tools)
	network_toggle.toggled.connect(func(enabled: bool):network_tools.visible=enabled)
	address=LineEdit.new();address.text="127.0.0.1";address.placeholder_text="Adresse de l’hôte";network_tools.add_child(address)
	_button(network_tools,"Héberger 3 joueurs (localhost)",func():
		message.text="Serveur : %s" % error_string(Session.host(3)))
	_button(network_tools,"Rejoindre",func():message.text="Connexion : %s" % error_string(Session.join(address.text)))
	_button(stack,"Sauvegarder le laboratoire",_save)
	_button(stack,"Charger (solo uniquement)",_load)
	_button(stack,"Simuler un tour de combat",_turn)
	_button(stack,"Réinitialiser le combat",_start_battle)
	message=Label.new();message.text="Zone turquoise : tous présents pour franchir l’étape.";stack.add_child(message)
	interaction_hint=Label.new();interaction_hint.position=Vector2(20,675);layer.add_child(interaction_hint)
	dialogue_panel=PanelContainer.new();dialogue_panel.position=Vector2(460,510);dialogue_panel.custom_minimum_size=Vector2(800,190);dialogue_panel.visible=false;layer.add_child(dialogue_panel)
	var conversation := VBoxContainer.new();dialogue_panel.add_child(conversation)
	dialogue_speaker=Label.new();conversation.add_child(dialogue_speaker)
	dialogue_text=Label.new();dialogue_text.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;dialogue_text.custom_minimum_size=Vector2(780,90);conversation.add_child(dialogue_text)
	var next_hint := Label.new();next_hint.text="A / E / Entrée • phrase suivante / next line";conversation.add_child(next_hint)
	var overview := PanelContainer.new();overview.position=Vector2(460,16);overview.custom_minimum_size=Vector2(420,0);layer.add_child(overview)
	var overview_stack := VBoxContainer.new();overview.add_child(overview_stack)
	journal_text=Label.new();journal_text.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;journal_text.custom_minimum_size.x=400;overview_stack.add_child(journal_text)
	inventory_text=Label.new();overview_stack.add_child(inventory_text)
	overview.visible=false
	pause_menu=PauseMenu.new();add_child(pause_menu)
	pause_menu.language_changed.connect(func(value: String):_set_locale(value);_sync_menu())
	pause_menu.camera_changed.connect(func(value: float):camera.size=value;_persist_preferences())
	pause_menu.save_requested.connect(func():_save();pause_menu.feedback.text=message.text)
	pause_menu.load_requested.connect(func():_load();_sync_menu();pause_menu.feedback.text=message.text)
	pause_menu.closed.connect(func():Session.submit_axis(Vector2.ZERO))
	log_box=RichTextLabel.new();log_box.custom_minimum_size=Vector2(430,115);stack.add_child(log_box)

func _button(parent: Node, text: String, action: Callable) -> Button:
	var button:=Button.new();button.text=text;button.pressed.connect(action);parent.add_child(button)
	return button

func _set_locale(value: String) -> void:
	locale=value
	_persist_preferences()

func _persist_preferences() -> void:
	preferences={"language":locale,"camera_size":camera.size}
	var error := Preferences.write(preferences, preferences_path)
	if error!=OK and message:
		message.text="Préférences : %s" % error_string(error)

func _save() -> void:
	if not multiplayer.is_server():
		message.text="La sauvegarde de campagne appartient à l’hôte.";return
	message.text="Sauvegarde : %s" % error_string(Store.write_snapshot(SAVE_PATH,Session.campaign.snapshot()))

func _load() -> void:
	if Session.active_network:
		message.text="Chargement réseau non implémenté ; aucun état écrasé.";return
	var value:=Store.read_snapshot(SAVE_PATH)
	if not value.is_empty() and (int(value.get("participants",1)) != 1 or value.get("players",{}).size() != 1):
		message.text="Campagne coop : import non implémenté, solo inchangé.";return
	message.text="Chargée" if Session.campaign.restore(value) else "Sauvegarde absente/invalide ; partie intacte."

func _start_battle() -> void:
	battle.begin({
		"J1":{"side":0,"hp":100,"speed":55,"power":18},
		"Boss":{"side":1,"hp":100,"speed":40,"power":25}},false)
	if log_box:log_box.text="Combat factice : duel solo.\nAucune règle 9G complète ni IA Tactica ici."

func _turn() -> void:
	var actions:Array=[]
	for actor:String in ["J1"]:actions.append({"actor":actor,"target":"Boss"})
	actions.append({"actor":"Boss","target":"J1"})
	var events:=battle.resolve(actions)
	log_box.text="Tour %d\n%s\nPV boss : %d" % [battle.turn_index,"\n".join(events),battle.units.Boss.hp]

func _local_position() -> Vector3:
	var id := str(multiplayer.get_unique_id())
	var players: Dictionary = Session.latest.get("players", {})
	var record: Dictionary = players.get(int(id), players.get(id, {}))
	var pos: Array = record.get("position", [0,0,0])
	return Vector3(float(pos[0]), 0, float(pos[2]))

func _sync_menu() -> void:
	pause_menu.sync(locale,camera.size,Session.campaign.laboratory)

func _open_menu(page: String = "home") -> void:
	if dialogue.active: return
	Session.submit_axis(Vector2.ZERO)
	_sync_menu()
	pause_menu.open(page)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if pause_menu.visible:
			if pause_menu.handle_key(event): get_viewport().set_input_as_handled()
			return
		if not dialogue.active and event.keycode in [KEY_ESCAPE,KEY_I,KEY_J]:
			_open_menu("bag" if event.keycode==KEY_I else ("journal" if event.keycode==KEY_J else "home"))
			get_viewport().set_input_as_handled();return
		if event.keycode==KEY_F3:
			debug_panel.visible=not debug_panel.visible
			get_viewport().set_input_as_handled();return
	# Active conversations consume confirmation before any previously focused button.
	if dialogue.active:
		_unhandled_key_input(event)

func _nearest_interaction() -> String:
	var nearest: String = ""
	var distance: float = 2.2
	for id: String in TARGETS:
		var current: float = _local_position().distance_to(TARGETS[id])
		if current <= distance:
			distance=current
			nearest=id
	return nearest

func _open_interaction(id: String) -> bool:
	if id not in TARGETS or Session.active_network or pause_menu.visible:
		return false
	active_interaction=id
	var record: Dictionary=interaction_records[id]
	if id=="crate" and not Session.campaign.laboratory.complete("crate"):
		record={"fr":{"speaker":"Caisse de test","lines":["La caisse est déjà vide."]},"en":{"speaker":"Test crate","lines":["The crate is already empty."]}}
	return dialogue.begin(record,locale)

func _unhandled_key_input(event: InputEvent) -> void:
	if pause_menu.visible or not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode not in [KEY_A, KEY_E, KEY_ENTER]:
		return
	if dialogue.active:
		dialogue.advance()
		if not dialogue.active:
			Session.campaign.laboratory.complete(active_interaction)
	else:
		var target := _nearest_interaction()
		if target.is_empty() or not _open_interaction(target):
			return
	Session.submit_axis(Vector2.ZERO)
	dialogue_panel.visible = dialogue.active
	dialogue_speaker.text = dialogue.speaker
	dialogue_text.text = dialogue.current_line()
	get_viewport().set_input_as_handled()

func _update_overview() -> void:
	var progress = Session.campaign.laboratory
	var lines: Array[String]=["Journal • objectifs de laboratoire" if locale=="fr" else "Journal • laboratory objectives"]
	var names: Array=["Parler au guide","Lire le panneau au nord-ouest","Ouvrir la caisse au sud-est"] if locale=="fr" else ["Talk to the guide","Read the northwest sign","Open the southeast crate"]
	for index: int in range(3):
		lines.append(("✓ " if progress.completed.has(progress.OBJECTIVES[index]) else "○ ")+names[index])
	journal_text.text="\n".join(lines)
	inventory_text.text=("Sac • jeton de test : %d" if locale=="fr" else "Bag • test token: %d") % progress.tokens
	language_button.text="Langue des dialogues : Français" if locale=="fr" else "Dialogue language: English"
	(crate_mesh.material_override as StandardMaterial3D).albedo_color=Color("75695a") if progress.tokens else Color("be895a")

func _process(_delta: float) -> void:
	var value: Dictionary=Session.latest
	var players: Dictionary=value.get("players",{})
	for id:Variant in avatars.keys():
		if not players.has(id) and not players.has(str(id)):
			avatars[id].queue_free();avatars.erase(id)
	for id:Variant in players:
		if not avatars.has(id):
			var model: PackedScene = load("res://assets/prototypes/mannequin.glb")
			var avatar: Node3D = model.instantiate()
			add_child(avatar)
			avatars[id] = avatar
			var animator: AnimationPlayer = avatar.find_child("AnimationPlayer",true,false)
			if animator:
				for animation_name: StringName in animator.get_animation_list():
					if animation_name != &"RESET":
						animator.get_animation(animation_name).loop_mode = Animation.LOOP_LINEAR
						avatar.set_meta("walk", animation_name)
						break
			var label := Label3D.new()
			label.text = str(players[id].name)
			label.position.y = 2.0
			label.font_size = 32
			label.pixel_size = 0.004
			avatar.add_child(label)
		var pos:Array=players[id].position
		var next_position := Vector3(float(pos[0]),0.0,float(pos[2]))
		var movement: Vector3 = next_position - avatars[id].position
		var animator: AnimationPlayer = avatars[id].find_child("AnimationPlayer",true,false)
		if animator:
			if movement.length_squared() > 0.00001:
				if not animator.is_playing():
					animator.play(avatars[id].get_meta("walk", &"RESET"))
				avatars[id].rotation.y = atan2(movement.x,movement.z)
			else:
				animator.stop()
		avatars[id].position = next_position
	var axis:=Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_Q) or Input.is_physical_key_pressed(KEY_LEFT):axis.x-=1
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):axis.x+=1
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_Z) or Input.is_physical_key_pressed(KEY_UP):axis.y-=1
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):axis.y+=1
	if pause_menu.visible or dialogue.active or get_viewport().gui_get_focus_owner() is LineEdit:axis=Vector2.ZERO
	var focus := _local_position()
	camera.position = focus + CAMERA_OFFSET
	camera.look_at(focus)
	interaction_hint.text = ("E / Entrée : interagir" if locale=="fr" else "E / Enter: interact") if not _nearest_interaction().is_empty() and not dialogue.active and not pause_menu.visible else ""
	_update_overview()
	menu_button.text="Menu • Échap" if locale=="fr" else "Menu • Esc"
	Session.submit_axis(axis)
	status.text="Joueurs %d/%d • étape %d • cap factice %d" % [players.size(),value.get("participants",1),value.get("progress",0),value.get("level_cap",10)]
