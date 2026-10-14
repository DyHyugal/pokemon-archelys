@tool
extends Node3D
@export var map_id: String = "new-map"
@export var source_profile: String = "archelys-original"
@export var spawn: Vector3 = Vector3.ZERO
@export var actor_model: PackedScene
func _ready() -> void:
	if not Engine.is_editor_hint():
		var preview = load("res://addons/archelys_workshop/runtime/preview.gd").new()
		add_child(preview)
