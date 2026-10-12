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
  elif node.name.begins_with("Trainer_"):
   var field: String=""
   if node.name.contains("Hair"):field="hair"
   elif node.name.contains("Shirt"):field="shirt"
   elif node.name.contains("Hand") or node.name.contains("Ear") or node.name.contains("Nose") or node.name.contains("Neck"):field="skin"
   if not field.is_empty():node.material_override=material(Appearance.color(value,field))
   if node.name.contains("Eye"):node.scale.y=1.0 if value.face==0 else 0.6
 var old: Node=avatar.get_node_or_null("PrototypeLook")
 if old:avatar.remove_child(old);old.queue_free()
 var attachment:=BoneAttachment3D.new();attachment.name="PrototypeLook"
 var skeleton: Skeleton3D=avatar.find_child("Skeleton3D",true,false)
 if skeleton==null:
  for candidate: Node in avatar.find_children("*","Skeleton3D",true,false):skeleton=candidate;break
 if skeleton==null:return
 avatar.add_child(attachment);attachment.use_external_skeleton=true;attachment.external_skeleton=attachment.get_path_to(skeleton);attachment.bone_name="Head"
 if value.style>0:
  var hair:=SphereMesh.new();hair.radius=0.21;hair.height=0.18 if value.style==1 else 0.25
  mesh(attachment,"Hair",hair,Appearance.color(value,"hair"),Vector3(0,0.42 if value.style==1 else 0.46,0))
  if value.style==2:
   var back:=SphereMesh.new();back.radius=0.19;back.height=0.32;mesh(attachment,"HairBack",back,Appearance.color(value,"hair"),Vector3(0,0.26,-0.14))
 if avatar.find_children("Trainer_Eye*","MeshInstance3D",true,false).size()>0:return
 for side: int in [-1,1]:
  var eye:=BoxMesh.new();eye.size=Vector3(0.04,0.035 if value.face==0 else 0.012,0.012)
  mesh(attachment,"EyeLeft" if side<0 else "EyeRight",eye,Color("242229"),Vector3(side*0.085,0.25,0.174))
