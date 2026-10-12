extends "res://scripts/world/visual_district.gd"
## Approved palettes, original Blender modules. Shared blockers support walking visits.
const Atlas=preload("res://scripts/domain/atlas.gd")
const Kit=preload("res://scripts/world/asset_kit.gd")
var blockers: Array[Rect2]=[]
var region_id: String
static func building_positions(site: int) -> Array[Vector3]:
 if site==2:return [Vector3(-8,0,-5),Vector3(7,0,-3),Vector3(-8,0,5),Vector3(9,0,6)]
 if site==3:return [Vector3(-9,0,-1),Vector3(9,0,-1),Vector3(-9,0,7),Vector3(9,0,7)]
 return [Vector3(-8,0,-6),Vector3(8,0,-6),Vector3(-8,0,1),Vector3(8,0,1),Vector3(-8,0,8),Vector3(8,0,8)]
func build_proposal(region: String,site: int) -> void:
 region_id=region;var p: Array=Atlas.REGIONS[region].colors
 box(Vector3(60,0.15,48),Vector3(0,-0.5,0),"639fbb" if region!="celestial" else "abcfe2")
 water=box(Vector3(60,0.04,48),Vector3(0,-0.45,0),"5aadb9")
 box(Vector3(42,0.45,34),Vector3(0,-0.25,0),p[0])
 box(Vector3(38,0.035,30),Vector3(0,-0.01,0),"82a985" if region in ["tropical","dragon"] else p[0])
 box(Vector3(5,0.04,31),Vector3(0,0.02,0),"ded6be")
 for at: Vector3 in building_positions(site):
  Kit.place(self,"house-"+region,at)
  blockers.append(Rect2(Vector2(at.x-2.4,at.z-1.85),Vector2(4.8,3.7)))
  box(Vector3(absf(at.x),0.04,1.65),Vector3(at.x/2,0.025,at.z+2.2),"ded6be")
 for z: int in range(-14,15,2):
  for x: float in [-1.6,0,1.6]:box(Vector3(1.5,0.035,1.82),Vector3(x,0.05,z),"e6dfcd")
 var tree: String="palm" if region=="tropical" else ("pine" if region=="winter" else "tree")
 for side: int in [-1,1]:
  for z: int in [-12,-4,4,12]:Kit.place(self,tree,Vector3(side*17,0,z),0.95)
  for z: int in [-10,4,12]:Kit.place(self,"lamp",Vector3(side*3.15,0,z),0.85)
  Kit.place(self,"bench",Vector3(side*4.6,0,9),1.0,side*PI/2)
 # Unique major silhouettes per region. The rear plaza is intentionally non-walkable.
 Kit.place(self,"landmark-"+region,Vector3(0,0,-12),0.75 if site!=3 else 1.0)
 blockers.append(Rect2(Vector2(-6,-17),Vector2(12,9)))
 if region=="mystic":
  box(Vector3(5,0.04,18),Vector3(13,0.035,-1),"779cb2")
  box(Vector3(7,0.08,2.1),Vector3(13,0.09,4),"b3a495")
  for side: int in [-1,1]:box(Vector3(7,0.55,0.15),Vector3(13,0.5,4+side*1.05),"9e939e")
  blockers.append(Rect2(Vector2(10.5,-10),Vector2(5,12.8)))
 if region=="winter":
  for x: int in [-14,14]:Kit.place(self,"rock",Vector3(x,0,-10),1.6)
  cylinder(2.2,0.045,Vector3(12,0.05,11),"81b7c5")
 if region in ["tech","aether"]:
  for x: int in [-14,14]:box(Vector3(0.2,0.03,26),Vector3(x,0.025,0),"7ce1de")
 if region=="celestial":
  water.material_override=material("c5deeb")
  for at: Vector3 in [Vector3(-25,-1,0),Vector3(25,-1,0),Vector3(-21,-1,17),Vector3(21,-1,17),Vector3(-16,-1,-18),Vector3(16,-1,-18)]:
   var cloud: MeshInstance3D=sphere(3.8,at,"eff4f2");cloud.scale=Vector3(1.8,0.32,1.0)
  for side: int in [-1,1]:
   for z: int in [-6,6]:cylinder(0.3,3.2,Vector3(side*14,1.6,z),"dbd7bd")
 if site==3 and Atlas.REGIONS[region].occupied:
  for x: int in [-4,4]:
   box(Vector3(0.14,2.7,0.14),Vector3(x,1.35,-6),"51636c")
   box(Vector3(1.1,0.8,0.08),Vector3(x,2.25,-6),"bd535a")
 var appearance: Dictionary=preload("res://scripts/domain/appearance.gd").DEFAULT.duplicate()
 for i: int in range(3):
  appearance.skin=i;appearance.shirt=(i+1)%4;appearance.hair=i;appearance.style=i
  var npc: Node3D=Kit.trainer(self,Vector3(-4+i*4,0,4 if i!=1 else 7),appearance.duplicate())
  npc.name="Resident%d" % i
  blockers.append(Rect2(Vector2(npc.position.x-0.4,npc.position.z-0.4),Vector2(0.8,0.8)))
 set_process(true)
func can_walk(point: Vector3) -> bool:
 if absf(point.x)>19 or absf(point.z)>14:return false
 for rect: Rect2 in blockers:
  if rect.grow(0.25).has_point(Vector2(point.x,point.z)):return false
 return true
