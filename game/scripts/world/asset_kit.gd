extends RefCounted
const ROOT="res://assets/archipelago/"
static func place(parent: Node3D,id: String,at: Vector3,scale_value: float=1.0,angle: float=0.0) -> Node3D:
 var packed: PackedScene=load(ROOT+id+".glb")
 var node: Node3D=packed.instantiate();node.name="Asset_"+id;node.position=at;node.scale=Vector3.ONE*scale_value;node.rotation.y=angle;parent.add_child(node);return node
static func trainer(parent: Node3D,at: Vector3,appearance: Dictionary) -> Node3D:
 var node: Node3D=load("res://assets/prototypes/mannequin.glb").instantiate();node.position=at;parent.add_child(node)
 preload("res://scripts/world/avatar_style.gd").apply(node,appearance);return node
