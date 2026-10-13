extends RefCounted
const ROOT="res://assets/archipelago/"
const EXPORTED={"palm":["palm-tree",Vector2(3.2,3.2),5.0],"tree":["tree",Vector2(4,4),5.5],"rock":["rock-pile",Vector2(1.6,1.4),1.8],"lamp":["street-lamp",Vector2(.75,.75),3.4],"bench":["bench",Vector2(2.5,1),1.5],"house-tropical":["stylized-cottage",Vector2(4.8,3.7),6.0]}
static func place(parent: Node3D,id: String,at: Vector3,scale_value: float=1.0,angle: float=0.0) -> Node3D:
 if EXPORTED.has(id):
  var spec: Array=EXPORTED[id]
  var imported: Node3D=preload("res://scripts/world/tripo_scenery.gd").place(parent,spec[0],at,spec[1]*scale_value,float(spec[2])*scale_value,angle)
  if imported!=null:imported.name="Asset_"+id;return imported
 var packed: PackedScene=load(ROOT+id+".glb")
 var node: Node3D=packed.instantiate();node.name="Asset_"+id;node.position=at;node.scale=Vector3.ONE*scale_value;node.rotation.y=angle;parent.add_child(node);return node
static func trainer(parent: Node3D,at: Vector3,appearance: Dictionary) -> Node3D:
 var node: Node3D=load("res://assets/prototypes/mannequin.glb").instantiate();node.position=at;parent.add_child(node)
 preload("res://scripts/world/avatar_style.gd").apply(node,appearance);return node
