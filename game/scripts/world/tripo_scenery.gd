extends RefCounted
## Owner exports: normalize ground pivot and fit explicit gameplay footprints.
const Imports=preload("res://scripts/services/imported_assets.gd")
const ORIENTATION={"unknown":-PI/2,"fantasy-temple":-PI/2,"gazebo":-PI/2,"medieval-cottage":-PI/2,"stylized-archway":-PI/2,"bench":-PI/2,"curved-desk":-PI/2,"reception-desk":-PI/2}
static var measured: Dictionary={}
static func bounds(node: Node3D, transform: Transform3D=Transform3D.IDENTITY) -> AABB:
 var t: Transform3D=transform*node.transform
 var b:=AABB()
 if node is MeshInstance3D and node.mesh!=null:b=t*node.get_aabb()
 for child: Node in node.get_children():
  if child is Node3D:
   var next:=bounds(child,t)
   if next.size.length()>0:b=next if b.size.length()==0 else b.merge(next)
 return b
static func create(id: String, footprint: Vector2,height_limit: float=12.0,angle: float=0.0) -> Node3D:
 var model: Node3D=Imports.instantiate("pack-"+id)
 if model==null:return null
 model.rotation.y+=float(ORIENTATION.get(id,0.0))
 var b: AABB
 if measured.has(id):b=measured[id]
 else:b=bounds(model);measured[id]=b
 if b.size.x<=0 or b.size.y<=0 or b.size.z<=0:model.free();return null
 var wrapper:=Node3D.new();wrapper.name="Tripo_"+id;wrapper.set_meta("scenery_id",id)
 var ratio: float=minf(footprint.x/b.size.x,minf(footprint.y/b.size.z,height_limit/b.size.y))
 model.scale*=ratio;model.position=model.position*ratio+Vector3(-b.get_center().x,-b.position.y,-b.get_center().z)*ratio
 wrapper.add_child(model);wrapper.rotation.y=angle
 for part: Node in model.find_children("*","MeshInstance3D",true,false):
  part.visibility_range_end=85.0;part.visibility_range_end_margin=5.0
  for surface: int in range(part.mesh.get_surface_count()):
   var original: Material=part.get_active_material(surface)
   if original is StandardMaterial3D:
    var material: StandardMaterial3D=original.duplicate();material.roughness=maxf(material.roughness,.8);material.metallic=minf(material.metallic,.15);material.metallic_specular=.2
    part.set_surface_override_material(surface,material)
 return wrapper
static func place(parent: Node3D,id: String,at: Vector3,footprint: Vector2,height_limit: float=12.0,angle: float=0.0) -> Node3D:
 var node:=create(id,footprint,height_limit,angle)
 if node==null:return null
 node.position=at;parent.add_child(node);return node
