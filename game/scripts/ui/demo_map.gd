extends Control
## Schematic of actual local coordinates, not a new world-map illustration.
var world: Node3D
var state: RefCounted
var target: String=""
var locale: String="fr"
var extent:=Rect2(-28,-28,56,44)
func _ready() -> void:
 custom_minimum_size=Vector2(480,310);size_flags_horizontal=Control.SIZE_EXPAND_FILL
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 if state.location=="trail":extent=Rect2(-15,-19,30,34)
 elif state.location!="town":extent=Rect2(-10,-11,20,22)
func project(at: Vector3) -> Vector2:
 return Vector2(18,18)+(Vector2(at.x,at.z)-extent.position)/extent.size*(size-Vector2(36,36))
func _draw() -> void:
 if not world or not state:return
 draw_style_box(make_background(),Rect2(Vector2.ZERO,size))
 if state.location=="town":
  draw_rect(Rect2(project(Vector3(-28,0,-28)),project(Vector3(28,0,16))-project(Vector3(-28,0,-28))),Color("ddd5b7"))
  draw_line(project(Vector3(0,0,-24)),project(Vector3(0,0,15)),Color("f5ead0"),20)
  draw_line(project(Vector3(-25,0,5)),project(Vector3(25,0,5)),Color("f5ead0"),12)
  var inlet: Vector2=project(Vector3(9,0,8));draw_rect(Rect2(inlet,project(Vector3(18,0,16))-inlet),Color("376b78"))
  draw_line(project(Vector3(11,0,7)),project(Vector3(11,0,16)),Color("937858"),8)
  for at: Vector3 in world.TOWN_BUILDINGS.values():
   var a: Vector2=project(at-Vector3(3.4,0,2.3));var b: Vector2=project(at+Vector3(3.4,0,2.3));draw_rect(Rect2(a,b-a),Color("497f88"))
 elif state.location=="trail":draw_line(project(Vector3(0,0,-18)),project(Vector3(0,0,13)),Color("d8c899"),20)
 for id: String in world.points:
  var p: Vector2=project(world.points[id]);draw_circle(p,6 if id==target else 4,Color("f1c56a") if id==target else Color("284f65"))
  if id.begins_with("door-") or id==target or state.location not in ["town","trail"]:
   var title: String=preload("res://scripts/domain/demo_guidance.gd").title(id,locale)
   draw_string(get_theme_default_font(),p+Vector2(9,-7),title,HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("192f3d"))
 draw_circle(project(state.position),7,Color("f6f7f0"));draw_circle(project(state.position),4,Color("cf5359"))
func make_background() -> StyleBoxFlat:
 var bg:=StyleBoxFlat.new();bg.bg_color=Color("376b78") if state.location=="town" else Color("66866a");bg.set_corner_radius_all(8);return bg
