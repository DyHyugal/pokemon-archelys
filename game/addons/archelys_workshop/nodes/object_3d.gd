@tool
extends Node3D
const Event = preload("res://addons/archelys_workshop/core/event.gd")
@export var object_id: String = "object"
@export var source_id: String = "original"
@export var label: String = "Objet"
@export var model: PackedScene:
	set(v): model = v; _refresh()
@export var model_scale: float = 1.0:
	set(v): model_scale = v; _refresh()
@export var model_offset: Vector3 = Vector3.ZERO:
	set(v): model_offset = v; _refresh()
@export var blocking_size: Vector3 = Vector3.ZERO:
	set(v): blocking_size = v; _refresh()
@export var visible_if: String = ""
@export var hidden_if: String = ""
@export var interaction: Event
func _ready() -> void: _rebuild()
func _refresh() -> void:
	if is_inside_tree(): call_deferred("_rebuild")
func _rebuild() -> void:
	for child in get_children():
		if child.has_meta("workshop_generated"):
			remove_child(child); child.queue_free()
	if model != null:
		var visual := model.instantiate()
		if visual is Node3D:
			visual.scale *= model_scale; visual.position += model_offset
		visual.set_meta("workshop_generated", true); add_child(visual)
	if blocking_size.x > 0 and blocking_size.y > 0 and blocking_size.z > 0:
		var body := StaticBody3D.new(); body.set_meta("workshop_generated", true)
		var collider := CollisionShape3D.new(); var shape := BoxShape3D.new()
		shape.size = blocking_size; collider.shape = shape; collider.position.y = blocking_size.y / 2
		body.add_child(collider); add_child(body)
