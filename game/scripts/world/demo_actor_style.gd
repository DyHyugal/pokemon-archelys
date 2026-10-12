extends RefCounted
const Appearance=preload("res://scripts/domain/appearance.gd")
static func apply(node: Node3D,look: Dictionary) -> void:
 for part: Node in node.find_children("*","MeshInstance3D",true,false):
  var field: String=""
  if part.name.begins_with("Demo_Skin"):field="skin"
  elif part.name=="Demo_Shirt":field="shirt"
  elif part.name.begins_with("Demo_Pants"):field="pants"
  elif part.name.contains("Hair") or part.name.begins_with("Demo_Brow"):field="hair"
  if not field.is_empty():
   var material:=StandardMaterial3D.new();material.albedo_color=Appearance.color(look,field);material.roughness=0.92;part.material_override=material
  if part.name.begins_with("Demo_Cap"):part.visible=int(look.style)==0
  if part.name=="Demo_LongHair":part.visible=int(look.style)==2
  if part.name.begins_with("Demo_Eye"):part.scale.y=1.0 if int(look.face)==0 else 0.65
