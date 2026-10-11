extends Node3D

const PokemonBattle=preload("res://scripts/domain/pokemon_battle.gd")
const DoubleBattle=preload("res://scripts/domain/double_battle.gd")
const BattlePanel=preload("res://scripts/ui/pokemon_battle_panel.gd")
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
const Mon=preload("res://scripts/domain/pokemon.gd")
const VisualDistrict=preload("res://scripts/world/visual_district.gd")
const Comfort=preload("res://scripts/services/comfort_store.gd")
const LabAudio=preload("res://scripts/services/laboratory_audio.gd")
var comfort:=Comfort.new()
var lab_audio: Node
var ui_theme:=Theme.new()
const SaveSlots=preload("res://scripts/services/save_slots.gd")
const Cinematic=preload("res://scripts/domain/cinematic.gd")
const CinematicPanel=preload("res://scripts/ui/cinematic_panel.gd")
var slots:=SaveSlots.new()
var cinematic:=Cinematic.new()
var cinematic_panel: CanvasLayer
var gameplay_layer: CanvasLayer
var cinematic_hud_visible: bool=true
var cinematic_zoom: float=16
var shot_tween: Tween
var last_auto_tick: int=0
var auto_baseline: String=""
var world_geometry: Node3D
var visual_variant: int=0
var displayed_location: String=""
var pokemon_battle:=PokemonBattle.new()
var battle_panel: CanvasLayer
var exploration_help: Label
var last_walk_position:=Vector3.ZERO
const ACTION_TARGETS=World.SERVICE_POINTS
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
var dialogue_hint: Label
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
	Session.campaign.adventure.initialize()
	preferences = Preferences.read(preferences_path)
	locale = preferences.language
	_build_world()
	_build_ui()
	lab_audio=LabAudio.new();add_child(lab_audio)
	_apply_comfort()
	_start_battle()
	last_auto_tick=Time.get_ticks_msec();auto_baseline=JSON.stringify(Session.campaign.snapshot())
	for id: String in TARGETS:
		interaction_records[id] = JSON.parse_string(FileAccess.get_file_as_string("res://data/dialogues/laboratory_%s.json" % id))
	dialogue_record = interaction_records.guide
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="):
			capture_frame.call_deferred(arg.trim_prefix("--capture="))

func capture_frame(path: String) -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--visual="):
			visual_variant=int(arg.trim_prefix("--visual="));Session.campaign.adventure.exploration.enter("district");_rebuild_location()
			get_viewport().size=Vector2i(1920,1080);get_viewport().msaa_3d=Viewport.MSAA_4X;camera.size=30
			for child: Node in get_children():
				if child is CanvasLayer:child.visible=false
			var caption:=CanvasLayer.new();add_child(caption)
			var title:=Label.new();title.text="ARCHÉLYS • COMPARATIF %s • prototype non validé" % ["A — côtier sobre","B — chaleureux","C — contemporain"][visual_variant];title.position=Vector2(28,24);title.add_theme_font_size_override("font_size",28);caption.add_child(title)
	if "--capture-menu" in OS.get_cmdline_user_args(): _open_menu("settings")
	if "--capture-team" in OS.get_cmdline_user_args():
		_open_menu("team");pause_menu.adventure_pages.selected_uid=int(Session.campaign.adventure.team[0].uid);pause_menu.render()
	if "--capture-battle" in OS.get_cmdline_user_args(): _begin_pokemon_battle([Session.campaign.adventure.wild(8,"rattata")])
	if "--capture-choices" in OS.get_cmdline_user_args():
		Session.campaign.adventure.raise_cap(18);Session.campaign.adventure.gain_experience(1,100000);_open_menu("choices")
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
	world_geometry.add_child(instance)
	return instance

func _box(size: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
	var shape := BoxMesh.new()
	shape.size = size
	return _mesh(shape, at, color)

func _build_world() -> void:
	world_geometry=Node3D.new();add_child(world_geometry)
	displayed_location=Session.campaign.adventure.exploration.location
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
	world_geometry.add_child(guide)
	var label := Label3D.new()
	label.text = "Guide • PNJ de test"
	label.position.y = 2.2
	label.font_size = 28
	label.pixel_size = 0.004
	guide.add_child(label)
	_box(Vector3(0.2,1.4,0.2), TARGETS.sign+Vector3(0,0.7,0),Color("66554b"))
	_box(Vector3(1.6,0.8,0.15),TARGETS.sign+Vector3(0,1.5,0),Color("f0dcc0"))
	_box(Vector3(3,3,2),Vector3(-11,1.5,9),Color("777969"))
	_box(Vector3(6,0.07,3),Vector3(-6,0.08,-5.5),Color("39794f"))
	for id: String in ACTION_TARGETS:
		var marker:=_box(Vector3(1,1,1),ACTION_TARGETS[id]+Vector3(0,0.5,0),Color("65c6db") if id=="healing" else Color("bd5757"))
		var hint:=Label3D.new();hint.text="Soins / Heal" if id=="healing" else ("Dresseur / Trainer 1" if id=="trainer-1" else "Dresseur / Trainer 2");hint.position.y=1.7;hint.font_size=22;hint.pixel_size=0.004;marker.add_child(hint)
	for id: String in World.local_points("village"):
		var point: Vector3=World.local_points("village")[id]
		if id not in ["center-door","shop-door"] and not Session.campaign.adventure.exploration.cleared.has(id):
			var marker:=_box(Vector3(0.55,0.45,0.55),point+Vector3(0,0.23,0),Color("5d6970"))
			var hint:=Label3D.new();hint.text=id;hint.position.y=1;hint.font_size=22;hint.pixel_size=0.004;marker.add_child(hint)
	crate_mesh = _box(Vector3(1.2,0.8,1.2),TARGETS.crate+Vector3(0,0.4,0),Color("be895a"))

func _build_ui() -> void:
	var layer:=CanvasLayer.new();add_child(layer);gameplay_layer=layer
	var panel:=PanelContainer.new();panel.position=Vector2(16,16);panel.custom_minimum_size=Vector2(430,0);layer.add_child(panel)
	debug_panel=panel
	panel.visible=false
	var toolbar:=HBoxContainer.new();toolbar.position=Vector2(16,16);toolbar.add_theme_constant_override("separation",16);layer.add_child(toolbar)
	menu_button=_button(toolbar,"Menu • Échap",func():_open_menu())
	var debug_toggle := CheckButton.new();debug_toggle.text="Outils labo • F3";toolbar.add_child(debug_toggle)
	debug_toggle.toggled.connect(func(value: bool):debug_panel.visible=value)
	panel.position=Vector2(16,65)
	var debug_scroll:=ScrollContainer.new();debug_scroll.custom_minimum_size.y=530;debug_scroll.follow_focus=true;panel.add_child(debug_scroll)
	var stack:=VBoxContainer.new();stack.size_flags_horizontal=Control.SIZE_EXPAND_FILL;debug_scroll.add_child(stack)
	var title:=Label.new();title.text="ARCHÉLYS • LABORATOIRE TECHNIQUE";stack.add_child(title)
	var note:=Label.new();note.text="Décors provisoires — aucune île finale\nDéplacement : Paramètres → Commandes";stack.add_child(note)
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
	_button(stack,"Entraînement labo : +50000 EXP (respecte le cap)",func():
		if pokemon_battle.active:return
		for mon: Dictionary in Session.campaign.adventure.team:Session.campaign.adventure.gain_experience(int(mon.uid),50000)
		_open_menu("choices"))
	_button(stack,"Essai soleil / IA difficile",func():_start_support_test("sun"))
	_button(stack,"Essai terrain / IA difficile",func():_start_support_test("electric"))
	_button(stack,"Essai combat double",_start_double_test)
	_button(stack,"Essai zones / Abri / soutien (sans sauvegarde)",_start_tactics_test)
	_button(stack,"Terminer l’essai tactique",_stop_tactics_test)
	_button(stack,"Kit Méga (équipe niveau 36 provisoire)",_mega_kit)
	_button(stack,"Réapprovisionner les consommables du labo",func():
		if pokemon_battle.active:return
		for id: String in ["poke-ball","great-ball","potion","antidote","paralyze-heal"]:Session.campaign.adventure.bag[id]=20)
	message=Label.new();message.position=Vector2(20,640);message.text="";layer.add_child(message)
	interaction_hint=Label.new();interaction_hint.position=Vector2(20,675);layer.add_child(interaction_hint)
	dialogue_panel=PanelContainer.new();dialogue_panel.position=Vector2(460,510);dialogue_panel.custom_minimum_size=Vector2(800,190);dialogue_panel.visible=false;layer.add_child(dialogue_panel)
	var conversation := VBoxContainer.new();dialogue_panel.add_child(conversation)
	dialogue_speaker=Label.new();conversation.add_child(dialogue_speaker)
	dialogue_text=Label.new();dialogue_text.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;dialogue_text.custom_minimum_size=Vector2(780,90);conversation.add_child(dialogue_text)
	dialogue_hint=Label.new();conversation.add_child(dialogue_hint)
	var overview := PanelContainer.new();overview.position=Vector2(460,16);overview.custom_minimum_size=Vector2(420,0);layer.add_child(overview)
	var overview_stack := VBoxContainer.new();overview.add_child(overview_stack)
	journal_text=Label.new();journal_text.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;journal_text.custom_minimum_size.x=400;overview_stack.add_child(journal_text)
	inventory_text=Label.new();overview_stack.add_child(inventory_text)
	overview.visible=false
	pause_menu=PauseMenu.new();pause_menu.slots=slots;pause_menu.comfort=comfort;add_child(pause_menu)
	pause_menu.comfort_changed.connect(_apply_comfort)
	pause_menu.audio_preview_requested.connect(func(kind: String):
		if kind=="stop":lab_audio.stop_previews()
		else:lab_audio.preview(kind))
	pause_menu.slot_requested.connect(_slot_action)
	pause_menu.scene_requested.connect(_play_scene)
	cinematic_panel=CinematicPanel.new();cinematic_panel.comfort=comfort;add_child(cinematic_panel)
	cinematic_panel.advance_requested.connect(_next_shot)
	cinematic_panel.skip_requested.connect(_skip_scene)
	pause_menu.language_changed.connect(func(value: String):_set_locale(value);_sync_menu())
	pause_menu.camera_changed.connect(func(value: float):camera.size=value;_persist_preferences())
	pause_menu.save_requested.connect(func():_save();pause_menu.feedback.text=message.text)
	pause_menu.load_requested.connect(func():_load();_sync_menu();pause_menu.feedback.text=message.text)
	battle_panel=BattlePanel.new();battle_panel.comfort=comfort;add_child(battle_panel)
	battle_panel.finished.connect(_battle_finished)
	exploration_help=Label.new();exploration_help.position=Vector2(460,16);layer.add_child(exploration_help)
	var saved_speed: Variant=JSON.parse_string(FileAccess.get_file_as_string("user://laboratory_speed.json")) if FileAccess.file_exists("user://laboratory_speed.json") else 1
	if Mon.integer(saved_speed,1,4):pause_menu.speed=float(saved_speed);Engine.time_scale=float(saved_speed)
	pause_menu.speed_changed.connect(func(value: float):
		Engine.time_scale=value
		var file:=FileAccess.open("user://laboratory_speed.json",FileAccess.WRITE)
		if file:file.store_string(JSON.stringify(int(value))))
	pause_menu.travel_requested.connect(_travel)
	pause_menu.closed.connect(func():Session.submit_axis(Vector2.ZERO);if lab_audio:lab_audio.stop_previews())
	log_box=RichTextLabel.new();log_box.custom_minimum_size=Vector2(430,115);stack.add_child(log_box)

func _button(parent: Node, text: String, action: Callable) -> Button:
	var button:=Button.new();button.text=text;button.pressed.connect(action);parent.add_child(button)
	return button

func _apply_comfort() -> void:
	ui_theme.default_font_size=int(comfort.data.text_size)
	for type: String in ["Label","Button","CheckButton","CheckBox","OptionButton","ItemList","LineEdit","TextEdit","SpinBox","PopupMenu"]:ui_theme.set_font_size("font_size",type,int(comfort.data.text_size))
	for key: String in ["normal_font_size","bold_font_size","italics_font_size","bold_italics_font_size","mono_font_size"]:ui_theme.set_font_size(key,"RichTextLabel",int(comfort.data.text_size))
	for layer_node: Node in [gameplay_layer,pause_menu,battle_panel,cinematic_panel]:
		for control: Node in layer_node.get_children():
			if control is Control:control.theme=ui_theme
	dialogue_hint.text="%s / Entrée • phrase suivante / next line" % comfort.caption("interact")
	if lab_audio:lab_audio.apply(comfort.data)

func _set_locale(value: String) -> void:
	locale=value
	_persist_preferences()

func _persist_preferences() -> void:
	preferences={"language":locale,"camera_size":camera.size}
	var error := Preferences.write(preferences, preferences_path)
	if error!=OK and message:
		message.text="Préférences : %s" % error_string(error)

func _save() -> void:
	if pokemon_battle.active or cinematic.active:return
	if not multiplayer.is_server():
		message.text="La sauvegarde de campagne appartient à l’hôte.";return
	message.text="Sauvegarde : %s" % error_string(slots.write(Session.campaign.snapshot()))

func _load() -> void:
	_slot_action("load",slots.active)

func _slot_action(action: String,slot: int) -> void:
	if action not in ["save","new","load","auto","backup"]:return
	if Session.active_network or pokemon_battle.active or cinematic.active or dialogue.active:return
	var value: Dictionary={}
	if action in ["load","auto","backup"]:
		value=slots.read(slot,action=="auto",action=="backup")
		if value.is_empty():message.text="Sauvegarde absente/invalide ; partie intacte. / Save absent/invalid; game unchanged.";pause_menu.feedback.text=message.text;return
	if slot<1 or slot>3:return
	# Switch only after a valid read. Restore validates before mutating campaign.
	if action in ["load","auto","backup"] and not CampaignModel.validate(value):return
	var error: int=slots.select(slot)
	if error!=OK:message.text=error_string(error);pause_menu.feedback.text=message.text;return
	if action=="save":_save()
	elif action=="new":
		Session.campaign=CampaignModel.new();Session.campaign.add_player(1,"Solo");Session.campaign.adventure.initialize();message.text="Nouvelle partie en mémoire / New game in memory"
	elif action in ["load","auto","backup"]:
		Session.campaign.restore(value);Session.campaign.adventure.initialize();message.text="Chargée" if locale=="fr" else "Loaded"
	else:return
	Session.submit_axis(Vector2.ZERO);Session.latest=Session.campaign.snapshot();last_walk_position=_local_position()
	last_auto_tick=Time.get_ticks_msec();auto_baseline=JSON.stringify(Session.campaign.snapshot())
	_sync_menu();pause_menu.feedback.text=message.text

func _autosave_if_safe(force: bool=false) -> void:
	if not slots.autosave or Session.active_network or pokemon_battle.active or battle_panel.visible or cinematic.active or dialogue.active or pause_menu.visible:return
	var now:=Time.get_ticks_msec()
	if not force and now-last_auto_tick<60000:return
	last_auto_tick=now
	var value: Dictionary=Session.campaign.snapshot();var serialized:=JSON.stringify(value)
	if serialized==auto_baseline:return
	var error: int=slots.write(value,true)
	if error==OK:auto_baseline=serialized;message.text="Autosauvegarde · %d / Autosaved" % slots.active
	else:message.text="Autosauvegarde / Autosave : %s" % error_string(error)

func _play_scene(id: String,replay: bool=false) -> void:
	if Session.active_network or pokemon_battle.active or dialogue.active or cinematic.active or Session.campaign.adventure.exploration.location!="village":return
	if not cinematic.begin(id,Session.campaign.adventure.records,replay):return
	cinematic_zoom=camera.size;cinematic_hud_visible=gameplay_layer.visible;gameplay_layer.hide();pause_menu.close();Session.submit_axis(Vector2.ZERO);_render_shot()
func _render_shot() -> void:
	cinematic_panel.render(cinematic,locale)
	if not cinematic.active:
		if shot_tween:shot_tween.kill()
		gameplay_layer.visible=cinematic_hud_visible;camera.size=cinematic_zoom;last_walk_position=_local_position();_open_menu("cinema");return
	var shot: Dictionary=cinematic.current();var point: Array=shot.focus;var focus:=Vector3(point[0],point[1],point[2])
	if shot_tween:shot_tween.kill()
	shot_tween=create_tween().set_parallel(true)
	shot_tween.tween_property(camera,"position",focus+CAMERA_OFFSET,0.6)
	shot_tween.tween_property(camera,"size",float(shot.size),0.6)
	# Camera offset remains constant, so the existing orientation matches every shot.
func _next_shot() -> void:
	if not cinematic.active:return
	cinematic.advance();_render_shot()
func _skip_scene() -> void:
	if cinematic.skip():_render_shot()

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
	return Vector3(float(pos[0]), float(pos[1]), float(pos[2]))

func _sync_menu() -> void:
	pause_menu.adventure=Session.campaign.adventure
	pause_menu.sync(locale,camera.size,Session.campaign.laboratory)

func _open_menu(page: String = "home") -> void:
	if dialogue.active or battle_panel.visible or cinematic.active: return
	Session.submit_axis(Vector2.ZERO)
	_sync_menu()
	pause_menu.open(page)

func _input(event: InputEvent) -> void:
	if cinematic.active:
		if cinematic_panel.handle_key(event):get_viewport().set_input_as_handled()
		return
	if battle_panel.visible:
		if battle_panel.handle_key(event):get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if pause_menu.visible:
			if pause_menu.handle_key(event): get_viewport().set_input_as_handled()
			return
		if not dialogue.active and (comfort.matches(event,"menu") or comfort.matches(event,"bag") or comfort.matches(event,"journal")):
			_open_menu("bag" if comfort.matches(event,"bag") else ("journal" if comfort.matches(event,"journal") else "home"))
			get_viewport().set_input_as_handled();return
		if not dialogue.active and comfort.matches(event,"interact") and not get_viewport().gui_get_focus_owner() is LineEdit:
			_unhandled_key_input(event);get_viewport().set_input_as_handled();return
		if event.keycode==KEY_F3:
			debug_panel.visible=not debug_panel.visible
			get_viewport().set_input_as_handled();return
	# Active conversations consume confirmation before any previously focused button.
	if dialogue.active:
		_unhandled_key_input(event)

func _nearest_interaction() -> String:
	var nearest: String = ""
	var distance: float = 2.2
	var location: String=Session.campaign.adventure.exploration.location
	var targets: Dictionary=World.local_points(location).duplicate()
	if location=="village":targets.merge(TARGETS);targets.merge(ACTION_TARGETS)
	for id: String in targets:
		if id=="climb" and _local_position().y>0:targets[id]=Vector3(-11,3,9)
		var current: float = _local_position().distance_to(targets[id])
		if current <= distance:
			distance=current
			nearest=id
	return nearest

func _open_interaction(id: String) -> bool:
	if pokemon_battle.active or pause_menu.visible or cinematic.active:return false
	if _contextual_action(id):return false
	if id=="healing":
		Session.campaign.adventure.heal_team();message.text="Équipe soignée / Party healed";return false
	if id in ["trainer-1","trainer-2"]:
		_begin_trainer(id);return false
	if id not in TARGETS or Session.active_network or pause_menu.visible:
		return false
	active_interaction=id
	var record: Dictionary=interaction_records[id]
	if id=="crate" and not Session.campaign.laboratory.complete("crate"):
		record={"fr":{"speaker":"Caisse de test","lines":["La caisse est déjà vide."]},"en":{"speaker":"Test crate","lines":["The crate is already empty."]}}
	return dialogue.begin(record,locale)

func _unhandled_key_input(event: InputEvent) -> void:
	if cinematic.active or battle_panel.visible or pause_menu.visible or not event is InputEventKey or not event.pressed or event.echo:
		return
	if not comfort.confirming(event):
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
	if is_instance_valid(crate_mesh):(crate_mesh.material_override as StandardMaterial3D).albedo_color=Color("75695a") if progress.tokens else Color("be895a")

func _process(_delta: float) -> void:
	if displayed_location!=Session.campaign.adventure.exploration.location:_rebuild_location()
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
		var next_position := Vector3(float(pos[0]),float(pos[1]),float(pos[2]))
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
	var axis: Vector2=comfort.axis()
	if battle_panel.visible or pause_menu.visible or dialogue.active or cinematic.active or get_viewport().gui_get_focus_owner() is LineEdit:axis=Vector2.ZERO
	var focus := _local_position()
	if not cinematic.active:
		camera.position = focus + CAMERA_OFFSET
		camera.look_at(focus)
	interaction_hint.text = (("%s / Entrée : interagir" if locale=="fr" else "%s / Enter: interact") % comfort.caption("interact")) if not _nearest_interaction().is_empty() and not dialogue.active and not pause_menu.visible and not battle_panel.visible and not cinematic.active else ""
	_update_overview()
	_track_encounters(focus)
	if battle_panel.visible:axis=Vector2.ZERO
	exploration_help.text="Herbes : nord-ouest • Soins : cube bleu • Dresseurs : cubes rouges\nMenu → Équipe / Résumé / PC • F3 : entraînement technique" if locale=="fr" else "Grass: northwest • Healing: blue cube • Trainers: red cubes\nMenu → Party / Summary / PC • F3: laboratory training"
	if displayed_location!="village":exploration_help.text="%s • E / Entrée : interaction • Échap : menu" % displayed_location
	exploration_help.text=exploration_help.text.replace("E / Entrée",comfort.caption("interact")+" / Entrée").replace("E / Enter",comfort.caption("interact")+" / Enter")
	menu_button.text="Menu • "+comfort.caption("menu")
	Session.submit_axis(axis)
	_autosave_if_safe()
	status.text="Joueurs %d/%d • étape %d • cap factice %d" % [players.size(),value.get("participants",1),value.get("progress",0),value.get("level_cap",10)]

func _track_encounters(position_now: Vector3) -> void:
	var distance: float=position_now.distance_to(last_walk_position)
	last_walk_position=position_now
	if Session.campaign.adventure.exploration.location!="village" or Session.active_network or pause_menu.visible or dialogue.active or battle_panel.visible or cinematic.active or distance>1.0:return
	if position_now.x>=-9 and position_now.x<=-3 and position_now.z>=-7 and position_now.z<=-4:
		Session.campaign.adventure.encounter_steps+=distance
		if Session.campaign.adventure.encounter_steps>=3.5:
			Session.campaign.adventure.encounter_steps=0
			_begin_pokemon_battle([Session.campaign.adventure.wild()])

func _begin_trainer(id: String) -> void:
	var adventure: RefCounted=Session.campaign.adventure
	if id=="trainer-2" and not adventure.victories.has("trainer-1"):
		message.text="Bats le premier dresseur d'abord / Defeat trainer 1 first";return
	var opponents: Array=[]
	var ids: Array=["rattata","pikachu"] if id=="trainer-1" else ["ivysaur","charmeleon","wartortle"]
	for species_id: String in ids:opponents.append(Mon.make(species_id,10 if id=="trainer-1" else 18,900000+opponents.size()))
	_begin_pokemon_battle(opponents,id)

func _begin_pokemon_battle(opponents: Array,trainer_id: String="") -> bool:
	if dialogue.active or pause_menu.visible or cinematic.active or Session.active_network:return false
	pokemon_battle=PokemonBattle.new()
	if not pokemon_battle.begin(Session.campaign.adventure,opponents,trainer_id):return false
	Session.submit_axis(Vector2.ZERO)
	battle_panel.open(pokemon_battle,locale)
	return true

func _battle_finished(outcome: String) -> void:
	if pokemon_battle.get("sandbox")==true:
		Session.submit_axis(Vector2.ZERO);message.text="Essai terminé : campagne conservée / Sandbox ended: campaign preserved";return
	Session.submit_axis(Vector2.ZERO)
	if outcome=="lost":
		Session.campaign.adventure.exploration.enter("village")
		Session.campaign.players[1].position=[0.0,0.0,2.0];Session.latest=Session.campaign.snapshot()
	last_walk_position=_local_position()
	Session.campaign.adventure.encounter_steps=0
	if not Session.campaign.adventure.pending.is_empty():_open_menu("choices")

func _travel(target: String,flight: bool=false) -> void:
	if Session.active_network or pokemon_battle.active or cinematic.active or dialogue.active:return
	if not Session.campaign.adventure.travel(target,flight):
		message.text="Destination non visitée / Vol non débloqué";return
	Session.campaign.players[1].position=[0.0,0.0,5.0]
	Session.submit_axis(Vector2.ZERO);Session.latest=Session.campaign.snapshot();last_walk_position=_local_position()
	if pause_menu.visible:pause_menu.close()
	_rebuild_location()
func _contextual_action(id: String) -> bool:
	var owner: RefCounted=Session.campaign.adventure
	var location: String=owner.exploration.location
	match id:
		"center-door":_travel("center")
		"shop-door":_travel("shop")
		"pier":_travel("cove")
		"district-gate":_travel("district")
		"exit":_travel("village")
		"counter":_open_menu("services")
		"nurse":owner.heal_team();message.text="Soins terminés / Party healed"
		"fish":_begin_pokemon_battle([owner.wild(mini(owner.cap,Catalog.FISH_MAX_LEVEL),Catalog.FISH_BASE)])
		"surf":
			if owner.exploration.field_unlocked("surf",owner.victories):owner.exploration.cleared.surf=true;message.text="Surf sans Pokémon compatible / Surf without compatible Pokémon";Session.campaign.players[1].position=[4.0,0.0,-4.0];Session.latest=Session.campaign.snapshot()
			else:message.text="Surf : vaincre le dresseur 1 d'abord / Defeat trainer 1 first"
		"cut","rock-smash","strength","climb":
			if owner.exploration.field_unlocked(id,owner.victories):owner.exploration.cleared[id]=true;_rebuild_location();message.text="%s : passage ouvert sans Pokémon compatible" % id
			else:message.text="%s : scénario non débloqué (dresseur 1)" % id
			if id=="climb" and owner.exploration.field_unlocked(id,owner.victories):Session.campaign.players[1].position=[-11.0,0.0,7.0] if _local_position().y>0 else [-11.0,3.0,9.0];Session.latest=Session.campaign.snapshot()
		"visuals":visual_variant=(visual_variant+1)%3;_rebuild_location();message.text="Comparatif %s — non validé" % ["A : côtier sobre","B : chaleureux","C : contemporain"][visual_variant]
		_:return false
	Session.submit_axis(Vector2.ZERO);return true
func _rebuild_location() -> void:
	world_geometry.free();world_geometry=Node3D.new();add_child(world_geometry)
	displayed_location=Session.campaign.adventure.exploration.location
	if displayed_location=="village":
		world_geometry.free()
		camera.free()
		for child: Node in get_children():
			if child is WorldEnvironment or child is DirectionalLight3D:child.free()
		_build_world();return
	if displayed_location=="district":
		var district:=VisualDistrict.new();world_geometry.add_child(district);district.build(visual_variant)
	elif displayed_location in ["center","shop"]:
		_box(Vector3(12,0.3,14),Vector3(0,-0.2,1),Color("b8aa89"))
		_box(Vector3(12,3,0.3),Vector3(0,1.5,-6),Color("e7e4d7"))
		for side: int in [-1,1]:_box(Vector3(0.3,3,14),Vector3(side*6,1.5,1),Color("e7e4d7"))
		_box(Vector3(7,1,1.3),Vector3(0,0.5,-3),Color("6b98a4") if displayed_location=="center" else Color("a97a57"))
		for x: int in [-4,4]:
			for y: int in range(1,4):_box(Vector3(1.4,0.3,1),Vector3(x,y*0.7,-4),Color("698279"))
	else:
		_box(Vector3(30,0.1,30),Vector3(0,-0.5,0),Color("459eaf"))
		_box(Vector3(15,0.4,12),Vector3(0,-0.3,3),Color("d9c18a"))
		_box(Vector3(2,0.1,5),Vector3(0,0,-1),Color("897052"))
	for id: String in World.local_points(displayed_location):
		var hint:=Label3D.new();hint.text=id;hint.position=World.local_points(displayed_location)[id]+Vector3(0,1.2,0);hint.font_size=26;hint.pixel_size=0.004;world_geometry.add_child(hint)

func _start_support_test(support: String) -> void:
	if pause_menu.visible or battle_panel.visible or dialogue.active or cinematic.active or Session.active_network:return
	var owner: RefCounted=Session.campaign.adventure
	owner.exploration.difficulty="hard"
	var opponents: Array=[]
	if support=="sun":
		for id: String in ["ninetales","venusaur","vulpix"]:opponents.append(Mon.make(id,36,900000+opponents.size()))
		opponents[0].ability="drought";opponents[1].ability="chlorophyll";opponents[2].ability="drought"
	else:
		for id: String in ["raichu","pikachu","raichu"]:opponents.append(Mon.make(id,36,900000+opponents.size()))
		for index: int in [0,2]:opponents[index].moves[0]={"id":"electric-terrain","pp":10}
		# Electric Terrain is a legal reusable Gen IX TM in this test catalogue.
	_begin_pokemon_battle(opponents,"weather-test" if support=="sun" else "terrain-test")
func _start_double_test() -> void:
	if battle_panel.visible or pause_menu.visible or dialogue.active or cinematic.active or Session.active_network:return
	pokemon_battle=DoubleBattle.new()
	if not pokemon_battle.begin(Session.campaign.adventure,[Mon.make("rattata",8,900000),Mon.make("pikachu",8,900001)]):message.text="Deux Pokémon aptes nécessaires / Two ready Pokémon required";return
	Session.submit_axis(Vector2.ZERO);battle_panel.open(pokemon_battle,locale)
func _mega_kit() -> void:
	if battle_panel.visible or pause_menu.visible or dialogue.active or cinematic.active:return
	var owner: RefCounted=Session.campaign.adventure
	if owner.exploration.nuzlocke=="on":message.text="Kit technique désactivé pendant le défi";return
	if owner.grant_mega_kit():message.text="Kit Méga : Pokémon compatibles existants équipés ; pierres aussi dans le sac. Attaquer → cocher Méga. / Existing compatible Pokémon equipped; stones also in Bag. Fight → tick Mega."

func _start_tactics_test() -> void:
	if battle_panel.visible or pause_menu.visible or dialogue.active or cinematic.active or Session.active_network:return
	var trial: RefCounted=Session.campaign.adventure.get_script().new();trial.initialize()
	trial.team=[Mon.make("blastoise",50,1),Mon.make("venusaur",50,2),Mon.make("charizard",50,3)];trial.next_uid=4;trial.cap=100
	for entry: Dictionary in [{"index":0,"moves":["surf","protect","rock-slide","water-pulse"]},{"index":1,"moves":["helping-hand","protect","razor-leaf","growth"]},{"index":2,"moves":["flamethrower","protect","rock-slide","helping-hand"]}]:
		trial.team[int(entry.index)].moves=[]
		for id: String in entry.moves:trial.team[int(entry.index)].moves.append({"id":id,"pp":int(Catalog.move(id).pp)})
	pokemon_battle=DoubleBattle.new();pokemon_battle.sandbox=true
	if not pokemon_battle.begin(trial,[Mon.make("raticate",50,900000),Mon.make("raichu",50,900001)]):return
	Session.submit_axis(Vector2.ZERO);battle_panel.open(pokemon_battle,locale)
func _stop_tactics_test() -> void:
	if pokemon_battle.active and pokemon_battle.get("sandbox")==true:
		pokemon_battle.finish("escaped");battle_panel.event_index=pokemon_battle.events.size();battle_panel.render()
