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
	detail()
	set_process(true)
func _process(delta: float) -> void:
	time+=delta
	for index: int in range(leaves.size()):leaves[index].rotation.z=sin(time*1.6+index)*0.035
	if water:water.position.y=-0.65+sin(time)*0.025

func cylinder(radius: float,height: float,pos: Vector3,color: String) -> MeshInstance3D:
	var mesh:=CylinderMesh.new();mesh.top_radius=radius;mesh.bottom_radius=radius;mesh.height=height;mesh.radial_segments=24
	return shape(mesh,pos,color)
func detail() -> void:
	var p: Dictionary=PALETTES[variant]
	# Original material shader: thin ripples and broad color variation, no imported art.
	var shader:=Shader.new()
	shader.code="shader_type spatial; render_mode cull_disabled; uniform vec4 tint : source_color; varying vec3 world; void vertex(){world=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; VERTEX.y+=sin(world.x*1.4+TIME)*0.018+cos(world.z*1.1+TIME*0.7)*0.016;} void fragment(){float ripple=sin(world.x*2.0+world.z*1.2+TIME)*0.025; ALBEDO=tint.rgb+vec3(ripple); ROUGHNESS=0.3; METALLIC=0.1;}"
	var mat:=ShaderMaterial.new();mat.shader=shader;mat.set_shader_parameter("tint",Color(p.water));water.material_override=mat
	water.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Cut stone paths, short grass borders, framed glass and wood shutters.
	for z: int in range(-9,10,2):
		for x: float in [-1.5,0,1.5]:box(Vector3(1.42,0.025,1.86),Vector3(x,0.05,z),"d8ccb6")
	for at: Vector2 in [Vector2(-8,0),Vector2(8,0),Vector2(-8,6)]:
		for x: float in [-1.1,1.1]:
			for side: int in [-1,1]:
				var shutter:=box(Vector3(0.18,0.85,0.08),Vector3(at.x+x+side*0.54,1.65,at.y+1.54),p.roof)
				for line: int in range(5):box(Vector3(0.18,0.025,0.1),shutter.position+Vector3(0,line*0.16-0.32,0.03),"64857f")
			box(Vector3(1.15,0.18,0.35),Vector3(at.x+x,1.1,at.y+1.6),"8b7357")
			for flower: int in range(4):sphere(0.095,Vector3(at.x+x-0.4+flower*0.25,1.28,at.y+1.7),"e9a39a")
		for step: int in range(3):box(Vector3(1.3+step*0.2,0.07,0.25),Vector3(at.x,0.12-step*0.025,at.y+1.65+step*0.25),"aba795")
		for column: int in range(6):
			box(Vector3(0.055,0.6,0.08),Vector3(at.x-0.38+column*0.15,0.9,at.y+1.57),"77918c")
	# Flowering borders stay outside walkable paths.
	for side: int in [-1,1]:
		for z: int in range(-7,9,3):
			box(Vector3(0.9,0.18,1.5),Vector3(side*13.2,0.08,z),"91795d")
			for flower: int in range(3):
				var at:=Vector3(side*13.2,0.32,z-0.5+flower*0.5)
				sphere(0.28,at,p.leaf);sphere(0.12,at+Vector3(0,0.22,0),"f3d89e")
	for x: float in [-3.3,3.3]:
		box(Vector3(0.32,0.45,1.8),Vector3(x,0.3,6),"9f805e")
		box(Vector3(0.12,0.5,1.8),Vector3(x,0.7,6),"9f805e")
func build_route(location: String) -> void:
	variant=0
	box(Vector3(55,0.3,50),Vector3(0,-0.5,0),"468c83")
	box(Vector3(27,0.4,23),Vector3(0,-0.22,0),"7a9b6c")
	box(Vector3(4,0.04,22),Vector3(0,0.01,0),"cfb38c")
	if location=="trail":
		box(Vector3(9,0.04,2),Vector3(3,0.015,-2),"cfb38c")
		box(Vector3(6,0.06,3),Vector3(-6,0.04,-5.5),"39794f")
		for at: Vector2 in [Vector2(-7,-2),Vector2(8,4)]:
			var rock:=sphere(1.55,Vector3(at.x,0.6,at.y),"737c72");rock.scale.y=0.7
		for side: int in [-1,1]:
			for z: int in [-7,1,7]:
				cylinder(0.22,2.6,Vector3(side*10,1.3,z),"8d7359")
				for i: int in range(4):
					var leaf:=sphere(0.9,Vector3(side*10+cos(i*PI/2)*0.65,2.8,z+sin(i*PI/2)*0.65),"42775b");leaf.scale=Vector3(1.2,0.5,1.8);leaves.append(leaf)
		cylinder(0.5,0.45,Vector3(6,0.22,-2),"877d65")
		var beacon:=sphere(0.35,Vector3(6,1.1,-2),"8cd8d1");beacon.material_override.emission_enabled=true;beacon.material_override.emission=Color("4e8c8c")
		cylinder(0.12,1,Vector3(6,0.55,-2),"617677")
	else:
		cylinder(5,0.12,Vector3(0,0.05,-2),"b8b3a3")
		var ring:=TorusMesh.new();ring.inner_radius=4.4;ring.outer_radius=4.65
		shape(ring,Vector3(0,0.18,-2),"d9cfb8")
		for x: int in [-6,6]:
			for z: int in [-7,2]:
				cylinder(0.48,3.2,Vector3(x,1.6,z),"a0a193")
				box(Vector3(1.25,0.3,1.25),Vector3(x,3.2,z),"c5c0ac")
		box(Vector3(2.5,0.8,1.8),Vector3(0,0.4,-7.5),"918f7f")
		var keeper: Node3D=load("res://assets/prototypes/mannequin.glb").instantiate();keeper.position=Vector3(0,0,-4);add_child(keeper)
	set_process(true)
