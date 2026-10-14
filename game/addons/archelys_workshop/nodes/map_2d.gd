@tool
extends Node2D
@export var map_id: String = "new-map"
@export var source_profile: String = "archelys-original"
@export var spawn: Vector2 = Vector2.ZERO
@export var actor_texture: Texture2D
func _ready() -> void:
	y_sort_enabled = true
	if not Engine.is_editor_hint():
		var preview = load("res://addons/archelys_workshop/runtime/preview.gd").new()
		add_child(preview)
