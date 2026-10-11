extends Node3D

const World = preload("res://scripts/domain/world_rules.gd")
const Store = preload("res://scripts/services/save_store.gd")
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
	_build_world()
	_build_ui()
	_start_battle()
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="):
			capture_frame.call_deferred(arg.trim_prefix("--capture="))

func capture_frame(path: String) -> void:
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
	camera.size=22.0
	camera.position=Vector3(0,17,18)
	add_child(camera)
	camera.look_at(Vector3.ZERO)
	camera.current=true

func _build_ui() -> void:
	var layer:=CanvasLayer.new();add_child(layer)
	var panel:=PanelContainer.new();panel.position=Vector2(16,16);panel.custom_minimum_size=Vector2(430,0);layer.add_child(panel)
	var stack:=VBoxContainer.new();panel.add_child(stack)
	var title:=Label.new();title.text="ARCHÉLYS • LABORATOIRE TECHNIQUE";stack.add_child(title)
	var note:=Label.new();note.text="Décors provisoires — aucune île finale\nDéplacement : ZQSD / WASD / flèches";stack.add_child(note)
	status=Label.new();stack.add_child(status)
	address=LineEdit.new();address.text="127.0.0.1";address.placeholder_text="Adresse de l’hôte";stack.add_child(address)
	_button(stack,"Héberger 3 joueurs (localhost)",func():
		message.text="Serveur : %s" % error_string(Session.host(3)))
	_button(stack,"Rejoindre",func():message.text="Connexion : %s" % error_string(Session.join(address.text)))
	_button(stack,"Sauvegarder le laboratoire",_save)
	_button(stack,"Charger (solo uniquement)",_load)
	_button(stack,"Simuler un tour de combat",_turn)
	_button(stack,"Réinitialiser le combat",_start_battle)
	message=Label.new();message.text="Zone turquoise : tous présents pour franchir l’étape.";stack.add_child(message)
	log_box=RichTextLabel.new();log_box.custom_minimum_size=Vector2(430,115);stack.add_child(log_box)

func _button(parent: Node, text: String, action: Callable) -> void:
	var button:=Button.new();button.text=text;button.pressed.connect(action);parent.add_child(button)

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
		"J2":{"side":0,"hp":100,"speed":45,"power":18},
		"J3":{"side":0,"hp":100,"speed":35,"power":18},
		"Boss":{"side":1,"hp":240,"speed":40,"power":25}},true)
	if log_box:log_box.text="Combat factice : 3 alliés contre 1 boss.\nAucune règle 9G complète ni IA Tactica ici."

func _turn() -> void:
	var actions:Array=[]
	for actor:String in ["J1","J2","J3"]:actions.append({"actor":actor,"target":"Boss"})
	actions.append({"actor":"Boss","target":"J1"})
	var events:=battle.resolve(actions)
	log_box.text="Tour %d\n%s\nPV boss : %d" % [battle.turn_index,"\n".join(events),battle.units.Boss.hp]

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
	if get_viewport().gui_get_focus_owner() is LineEdit:axis=Vector2.ZERO
	Session.submit_axis(axis)
	status.text="Joueurs %d/%d • étape %d • cap factice %d" % [players.size(),value.get("participants",1),value.get("progress",0),value.get("level_cap",10)]
