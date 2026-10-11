extends Node3D
## Original procedural assets. Three unapproved directions, same layout/collision.
var variant: int=0
var water: MeshInstance3D
var leaves: Array=[]
var time: float=0
const PALETTES=[{ "wall":"efeadb","roof":"477d86","path":"ccb991","leaf":"388271","water":"419fa9"},{"wall":"e4d3b0","roof":"af5b48","path":"c39769","leaf":"52824f","water":"298695"},{"wall":"d9e6ec","roof":"486281","path":"a6b4b6","leaf":"467b78","water":"497fa9"}]
func material(hex: String) -> StandardMaterial3D:
	var value:=StandardMaterial3D.new();value.albedo_color=Color(hex);value.roughness=0.8;return value
func shape(mesh: Mesh,pos: Vector3,color: String) -> MeshInstance3D:
	var node:=MeshInstance3D.new();node.mesh=mesh;node.position=pos;node.material_override=material(color);add_child(node);return node
func box(size: Vector3,pos: Vector3,color: String) -> MeshInstance3D:
	var mesh:=BoxMesh.new();mesh.size=size;return shape(mesh,pos,color)
func sphere(radius: float,pos: Vector3,color: String) -> MeshInstance3D:
	var mesh:=SphereMesh.new();mesh.radius=radius;mesh.height=radius*2;mesh.radial_segments=24;mesh.rings=12;return shape(mesh,pos,color)
func build(value: int) -> void:
	variant=clampi(value,0,2)
	var p: Dictionary=PALETTES[variant]
	box(Vector3(60,0.1,60),Vector3(0,-0.7,0),p.water)
	water=box(Vector3(60,0.05,60),Vector3(0,-0.65,0),p.water)
	box(Vector3(33,0.6,25),Vector3(0,-0.4,0),"d9c998")
	box(Vector3(29,0.1,21),Vector3(0,-0.05,0),"85a474")
	box(Vector3(5,0.03,20),Vector3(0,0.025,0),p.path)
	box(Vector3(24,0.03,3),Vector3(0,0.026,3),p.path)
	# A modular building: foundation, bevel-like steps, pillars, inset openings,
	# double pitched roof and frame. Dimensions are identical in all variants.
	for at: Vector2 in [Vector2(-8,0),Vector2(8,0),Vector2(-8,6)]:
		box(Vector3(3.8,0.25,3.4),Vector3(at.x,0.125,at.y),"666d69")
		box(Vector3(3.3,2.6,2.9),Vector3(at.x,1.5,at.y),p.wall)
		box(Vector3(1.2,0.15,0.6),Vector3(at.x,0.075,at.y+1.7),p.path)
		box(Vector3(1,1.85,0.12),Vector3(at.x,1.03,at.y+1.5),"304d56")
		for x: float in [-1.1,1.1]:
			box(Vector3(0.85,0.85,0.12),Vector3(at.x+x,1.65,at.y+1.5),"cad3c2")
			box(Vector3(0.66,0.66,0.13),Vector3(at.x+x,1.65,at.y+1.52),"4a7180")
			box(Vector3(0.06,0.66,0.15),Vector3(at.x+x,1.65,at.y+1.54),p.wall)
			box(Vector3(0.66,0.06,0.15),Vector3(at.x+x,1.65,at.y+1.54),p.wall)
		for x: float in [-1.7,1.7]:box(Vector3(0.16,2.7,0.16),Vector3(at.x+x,1.55,at.y+1.5),"8a735a")
		for angle: float in ([-0.45,0.45] if variant!=2 else [0.0]):
			var roof:=box(Vector3(2.15 if variant!=2 else 4.1,0.16,3.8),Vector3(at.x+((-0.94 if angle<0 else 0.94) if variant!=2 else 0),3.15,at.y),p.roof);roof.rotation.z=-angle
		if variant!=2:box(Vector3(0.35,0.28,3.9),Vector3(at.x,3.6,at.y),p.roof)
		else:
			box(Vector3(4.2,0.12,1.25),Vector3(at.x,2.4,at.y+1.75),p.roof)
			for x: float in [-1.85,1.85]:box(Vector3(0.08,2.5,0.08),Vector3(at.x+x,1.25,at.y+2),"5c7580")
		if variant==1:
			box(Vector3(0.5,1.1,0.6),Vector3(at.x-1,3.3,at.y-0.8),p.wall)
			box(Vector3(0.65,0.12,0.75),Vector3(at.x-1,3.9,at.y-0.8),p.roof)
		for x: float in [-2.1,2.1]:
			box(Vector3(0.8,0.4,0.75),Vector3(at.x+x,0.2,at.y+1.4),"8a735a")
			sphere(0.48,Vector3(at.x+x,0.67,at.y+1.4),p.leaf)
	for at: Vector2 in [Vector2(-12,-5),Vector2(12,-5),Vector2(10,7),Vector2(-4,7)]:
		var trunk:=CylinderMesh.new();trunk.top_radius=0.16;trunk.bottom_radius=0.25;trunk.height=2.9;shape(trunk,Vector3(at.x,1.45,at.y),"846a50")
		for i: int in range(5):
			var angle: float=i*TAU/5
			var leaf:=sphere(0.8,Vector3(at.x+cos(angle)*0.65,3.0,at.y+sin(angle)*0.65),p.leaf);leaf.scale=Vector3(1.1,0.55,1.8);leaf.rotation.y=-angle;leaves.append(leaf)
	# Terraced volcanic silhouette with a visible crater, no imported texture.
	for tier: int in range(4):
		var rock:=CylinderMesh.new();rock.top_radius=5.5-tier*1.1;rock.bottom_radius=6.3-tier*1.1;rock.height=1.4;rock.radial_segments=24;shape(rock,Vector3(0,0.7+tier*1.25,-16),"5d6264")
	var crater:=CylinderMesh.new();crater.top_radius=1.6;crater.bottom_radius=1.6;crater.height=0.12;shape(crater,Vector3(0,5.15,-16),"a35e46")
	for side: int in [-1,1]:
		for z: int in range(-8,9,4):
			box(Vector3(0.13,2.2,0.13),Vector3(side*3,1.1,z),"475d62")
			var lamp:=sphere(0.23,Vector3(side*3,2.3,z),"f0dfa2");lamp.material_override.emission_enabled=true;lamp.material_override.emission=Color("a28b50")
	set_process(true)
func _process(delta: float) -> void:
	time+=delta
	for index: int in range(leaves.size()):leaves[index].rotation.z=sin(time*1.6+index)*0.035
	if water:water.position.y=-0.65+sin(time)*0.025
