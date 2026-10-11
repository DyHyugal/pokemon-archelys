extends RefCounted
const Appearance=preload("res://scripts/domain/appearance.gd")
static func material(color: Color) -> StandardMaterial3D:
 var value:=StandardMaterial3D.new();value.albedo_color=color;value.roughness=0.85;return value
static func mesh(parent: Node3D,name: String,shape: Mesh,color: Color,position: Vector3) -> MeshInstance3D:
 var node:=MeshInstance3D.new();node.name=name;node.mesh=shape;node.material_override=material(color);node.position=position;parent.add_child(node);return node
static func apply(avatar: Node3D,value: Dictionary) -> void:
 if not Appearance.validate(value):return
 for node: Node in avatar.find_children("*","MeshInstance3D",true,false):
  if node.name.begins_with("Mannequin_"):
   var field: String="shirt" if node.name.contains("Torso") else ("pants" if node.name.contains("Leg") else "skin")
   node.material_override=material(Appearance.color(value,field))
 var old: Node=avatar.get_node_or_null("PrototypeLook")
 if old:avatar.remove_child(old);old.queue_free()
 var attachment:=BoneAttachment3D.new();attachment.name="PrototypeLook"
 var skeleton: Skeleton3D=avatar.find_child("Skeleton3D",true,false)
 if skeleton==null:
  for candidate: Node in avatar.find_children("*","Skeleton3D",true,false):skeleton=candidate;break
 if skeleton==null:return
 avatar.add_child(attachment);attachment.use_external_skeleton=true;attachment.external_skeleton=attachment.get_path_to(skeleton);attachment.bone_name="Head"
 if value.style>0:
  var hair:=BoxMesh.new();hair.size=Vector3(0.39,0.13 if value.style==1 else 0.23,0.37)
  mesh(attachment,"Hair",hair,Appearance.color(value,"hair"),Vector3(0,0.42 if value.style==1 else 0.46,0))
  if value.style==2:
   var back:=BoxMesh.new();back.size=Vector3(0.4,0.3,0.12);mesh(attachment,"HairBack",back,Appearance.color(value,"hair"),Vector3(0,0.26,-0.14))
 for side: int in [-1,1]:
  var eye:=BoxMesh.new();eye.size=Vector3(0.04,0.035 if value.face==0 else 0.012,0.012)
  mesh(attachment,"EyeLeft" if side<0 else "EyeRight",eye,Color("242229"),Vector3(side*0.085,0.25,0.174))
