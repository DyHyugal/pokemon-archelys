@tool
extends Node2D
const Event = preload("res://addons/archelys_workshop/core/event.gd")
@export var object_id: String = "object"
@export var source_id: String = "original"
@export var label: String = "Objet"
@export var texture: Texture2D:
	set(v): texture = v; _refresh()
@export var height_pixels: float = 160.0:
	set(v): height_pixels = v; _refresh()
@export var tint: Color = Color.WHITE:
	set(v): tint = v; _refresh()
@export var blocking_size: Vector2 = Vector2.ZERO:
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
	if texture != null:
		var sprite := Sprite2D.new()
		sprite.texture = texture; sprite.modulate = tint
		var ratio := maxf(height_pixels, 1.0) / maxf(texture.get_height(), 1.0)
		sprite.scale = Vector2.ONE * ratio; sprite.position.y = -height_pixels / 2.0
		sprite.set_meta("workshop_generated", true); add_child(sprite)
	if blocking_size.x > 0 and blocking_size.y > 0:
		var body := StaticBody2D.new(); body.set_meta("workshop_generated", true)
		var collider := CollisionShape2D.new(); var shape := RectangleShape2D.new()
		shape.size = blocking_size; collider.shape = shape; body.add_child(collider); add_child(body)
	queue_redraw()
func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO, 5, Color.CYAN)
		if blocking_size != Vector2.ZERO: draw_rect(Rect2(-blocking_size / 2, blocking_size), Color(1, .5, 0, .25))
