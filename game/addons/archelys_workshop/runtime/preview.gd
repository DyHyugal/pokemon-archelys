extends Node
## F6 authoring preview. Isolated from every existing campaign save.
const Runner = preload("res://addons/archelys_workshop/core/event_runner.gd")
const Catalog = preload("res://addons/archelys_workshop/core/catalog.gd")
const Adventure = preload("res://scripts/domain/solo_adventure.gd")
const Mon = preload("res://scripts/domain/pokemon.gd")
const PokemonCatalog = preload("res://scripts/domain/pokemon_catalog.gd")
const Adapter = preload("res://scripts/services/showdown_battle.gd")
const BattlePanel = preload("res://scripts/ui/pokemon_battle_panel.gd")
var runner: RefCounted
var adventure: RefCounted
var player: Node
var world: Node
var message: Label
var status: Label
var battle: RefCounted
var panel: CanvasLayer
var locale := "fr"

func _ready() -> void:
	world = get_parent()
	if not get_tree().root.has_meta("archelys_workshop"):
		var initial := Adventure.new(); initial.initialize()
		get_tree().root.set_meta("archelys_workshop", {"runner": Runner.new(), "adventure": initial})
	var session: Dictionary = get_tree().root.get_meta("archelys_workshop")
	runner = session.runner; adventure = session.adventure; locale = runner.locale
	_build_actor(); _build_ui(); _update_visibility()
	if get_tree().root.has_meta("archelys_workshop_arrival"):
		var arrival: Vector3 = get_tree().root.get_meta("archelys_workshop_arrival")
		get_tree().root.remove_meta("archelys_workshop_arrival")
		player.position = Vector2(arrival.x, arrival.z) if player is Node2D else arrival
	if runner.active != null: call_deferred("_advance")

func _build_actor() -> void:
	if world is Node2D:
		var actor := CharacterBody2D.new(); var collider := CollisionShape2D.new(); var shape := CircleShape2D.new()
		shape.radius = 12; collider.shape = shape; actor.add_child(collider)
		var sprite := Sprite2D.new(); sprite.texture = world.actor_texture
		if sprite.texture != null:
			var ratio: float = 80.0 / maxf(sprite.texture.get_height(), 1)
			sprite.scale = Vector2.ONE * ratio; sprite.position.y = -40
		else:
			var marker := Polygon2D.new(); marker.polygon = PackedVector2Array([Vector2(-10, 0), Vector2(0, -25), Vector2(10, 0)]); marker.color = Color.CYAN; actor.add_child(marker)
		actor.add_child(sprite); world.add_child(actor); actor.position = world.spawn
		var camera := Camera2D.new(); camera.zoom = Vector2.ONE * 1.2; actor.add_child(camera); player = actor
	else:
		var actor := CharacterBody3D.new(); var collider := CollisionShape3D.new(); var shape := CapsuleShape3D.new()
		shape.radius = .22; shape.height = 1.2; collider.shape = shape; collider.position.y = .6; actor.add_child(collider)
		if world.actor_model != null: actor.add_child(world.actor_model.instantiate())
		else:
			var marker := MeshInstance3D.new(); marker.mesh = CapsuleMesh.new(); marker.scale = Vector3(.4, .6, .4); marker.position.y = .6; actor.add_child(marker)
		world.add_child(actor); actor.position = world.spawn
		var camera := Camera3D.new(); camera.position = Vector3(0, 12, 10); actor.add_child(camera)
		camera.look_at(actor.global_position); camera.current = true; player = actor

func _build_ui() -> void:
	var canvas := CanvasLayer.new(); add_child(canvas)
	var box := VBoxContainer.new(); box.position = Vector2(20, 20); canvas.add_child(box)
	status = Label.new(); box.add_child(status)
	message = Label.new(); message.custom_minimum_size = Vector2(700, 60); message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; box.add_child(message)
	var controls := HBoxContainer.new(); box.add_child(controls)
	for spec in [["Interagir / Continuer (E)", _interact], ["Sauver l'essai", _save], ["Charger l'essai", _load_save], ["FR / EN", _language]]:
		var button := Button.new(); button.text = spec[0]; button.pressed.connect(spec[1]); controls.add_child(button)
	panel = BattlePanel.new(); add_child(panel); panel.finished.connect(_battle_finished)
	message.text = "Essai de map — équipe et apparence provisoires. ZQSD / flèches ; Maj : courir."
	_refresh_status()

func _physics_process(_delta: float) -> void:
	if player == null: return
	var axis := Vector2.ZERO
	if runner.active == null and (battle == null or not battle.active):
		axis = Vector2(float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_Q) or Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)), float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_Z) or Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP))).limit_length()
	var speed := 5.4 if Input.is_physical_key_pressed(KEY_SHIFT) else 2.8
	if player is CharacterBody2D:
		player.velocity = axis * speed * 64; player.move_and_slide()
	else:
		player.velocity = Vector3(axis.x * speed, -2, axis.y * speed); player.move_and_slide()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if panel.visible: panel.handle_key(event)
		elif event.keycode in [KEY_E, KEY_ENTER, KEY_SPACE]: _interact()

func _interact() -> void:
	if battle != null and battle.active: return
	if runner.active != null:
		if runner.acknowledge("dialogue"): _advance()
		return
	var nearest: Node
	var distance: float = 110 if player is Node2D else 2.0
	for node in _objects():
		if node.interaction == null or not node.visible: continue
		var separation: float = player.global_position.distance_to(node.global_position)
		if separation < distance: nearest = node; distance = separation
	if nearest != null and runner.begin(nearest.interaction): _advance()
	else: message.text = "Aucune interaction disponible à proximité."

func _advance() -> void:
	runner.locale = locale
	var next: Dictionary = runner.next(); _update_visibility(); _refresh_status()
	match next.action:
		"dialogue": message.text = next.text
		"battle": _start_battle(next.id)
		"warp": _warp(next)
		"finished": message.text = "Événement terminé."
		"blocked": message.text = "Condition non remplie."

func _start_battle(id: String) -> void:
	var record: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/workshop/battles.json"))
	var team: Variant = record.get(id) if record is Dictionary else null
	if not team is Array or team.is_empty() or team.size() > 6:
		runner.acknowledge("battle", false); message.text = "Équipe Atelier inconnue : " + id; return
	var opponents: Array = []
	for i in team.size():
		var entry: Variant = team[i]
		if not entry is Dictionary or not entry.get("species") is String or PokemonCatalog.species(entry.species).is_empty() or not Mon.integer(entry.get("level"), 1, 100):
			runner.acknowledge("battle", false); message.text = "Équipe Atelier invalide"; return
		opponents.append(Mon.make(entry.species, int(entry.level), 900000 + i))
	battle = Adapter.new()
	if not battle.begin(adventure, opponents, "demo-trainer"):
		runner.acknowledge("battle", false); message.text = "Combat indisponible : " + battle.last_error; return
	panel.open(battle, locale)

func _battle_finished(result: String) -> void:
	if battle == null or battle.active or result != battle.result: return
	panel.visible = false
	if runner.acknowledge("battle", result == "won") and result == "won": _advance()
	else:
		_update_visibility(); _refresh_status(); message.text = "Événement interrompu : " + result

func _warp(next: Dictionary) -> void:
	if next.id == world.map_id:
		player.position = Vector2(next.position.x, next.position.z) if player is Node2D else next.position
		runner.acknowledge("warp"); _advance(); return
	var maps: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/workshop/maps.json"))
	var path: String = str(maps.get(next.id, "")) if maps is Dictionary else ""
	if not path.begins_with("res://") or not path.ends_with(".tscn") or not ResourceLoader.exists(path):
		runner.acknowledge("warp", false); message.text = "Map de destination absente : " + next.id; return
	# Destination is data-checked before acknowledging; original demo scenes are not destinations.
	var packed = load(path); var destination = packed.instantiate()
	var valid: bool = destination.get_script() in [preload("res://addons/archelys_workshop/nodes/map_2d.gd"), preload("res://addons/archelys_workshop/nodes/map_3d.gd")] and destination.map_id == next.id
	destination.free()
	if not valid:
		runner.acknowledge("warp", false); message.text = "Destination hors Atelier"; return
	get_tree().root.set_meta("archelys_workshop_arrival", next.position)
	runner.acknowledge("warp")
	var error := get_tree().change_scene_to_file(path)
	if error != OK: runner.cancel(); message.text = "Transition impossible"

func _objects() -> Array[Node]:
	var result: Array[Node] = []
	for node in world.find_children("*", "", true, false):
		if node.get_script() in [preload("res://addons/archelys_workshop/nodes/object_2d.gd"), preload("res://addons/archelys_workshop/nodes/object_3d.gd")]: result.append(node)
	return result
func _update_visibility() -> void:
	for node in _objects(): node.visible = (node.visible_if.is_empty() or runner.flags.get(node.visible_if, false)) and (node.hidden_if.is_empty() or not runner.flags.get(node.hidden_if, false))
func _refresh_status() -> void:
	status.text = "ATELIER • %s • %s • Objets : %s" % [world.map_id, locale.to_upper(), runner.inventory]
func _language() -> void:
	locale = "en" if locale == "fr" else "fr"; runner.locale = locale; _refresh_status()
func _save_path() -> String: return "user://workshop-" + str(world.map_id).sha256_text().left(16) + ".json"
func _save() -> void:
	if runner.active != null or adventure.in_battle:
		message.text = "Terminer l'événement avant de sauvegarder."; return
	var position: Vector3 = Vector3(player.position.x, 0, player.position.y) if player is Node2D else player.position
	var record := {"schema": 1, "map": world.map_id, "state": runner.snapshot(), "locale": locale, "position": [position.x, position.y, position.z], "adventure": adventure.snapshot()}
	var file := FileAccess.open(_save_path(), FileAccess.WRITE)
	if file == null: message.text = "Sauvegarde impossible"; return
	file.store_string(JSON.stringify(record)); message.text = "Essai sauvegardé (séparé de la campagne)."
func _load_save() -> void:
	if runner.active != null or adventure.in_battle: return
	if not FileAccess.file_exists(_save_path()): message.text = "Aucun essai sauvegardé pour cette map."; return
	var record: Variant = JSON.parse_string(FileAccess.get_file_as_string(_save_path()))
	if not record is Dictionary or record.get("schema") != 1 or record.get("map") != world.map_id or record.get("locale") not in ["fr", "en"] or not record.get("position") is Array or record.position.size() != 3: message.text = "Sauvegarde invalide"; return
	for number in record.position:
		if not number is int and not number is float or not is_finite(float(number)): message.text = "Position invalide"; return
	var candidate := Runner.new(); var candidate_adventure := Adventure.new()
	if not candidate.restore(record.get("state")) or not Adventure.validate(record.get("adventure")) or not candidate_adventure.restore(record.adventure): message.text = "État invalide"; return
	runner.restore(record.state); adventure.restore(record.adventure); locale = record.locale; runner.locale = locale
	player.position = Vector2(record.position[0], record.position[2]) if player is Node2D else Vector3(record.position[0], record.position[1], record.position[2])
	_update_visibility(); _refresh_status(); message.text = "Essai chargé."
func _exit_tree() -> void:
	if battle != null and battle.active: battle.finish("cancelled")
