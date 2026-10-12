extends Node3D
const State=preload("res://scripts/domain/demo_state.gd")
const Style=preload("res://scripts/world/demo_actor_style.gd")
const OldKit=preload("res://scripts/world/asset_kit.gd")
var blockers: Array[Rect2]=[]
var points: Dictionary={}
var hero: Node3D
var camera: Camera3D
var geometry: Node3D
var location: String=""
var avatar_preview: Dictionary={}
const TOWN_BUILDINGS={"center":Vector3(-15,0,-2),"shop":Vector3(14,0,-12),"home":Vector3(-16,0,8),"arcade":Vector3(0,0,-14),"villa":Vector3(14,0,0)}
var show_labels: bool=true
func configure_labels(enabled: bool) -> void:
 show_labels=enabled
 for label: Node in geometry.find_children("*","Label3D",true,false):label.visible=enabled
func surface_shader(node: Node3D) -> void:
 for part: Node in node.find_children("*","MeshInstance3D",true,false):
  if not part.name.contains("Stucco") and not part.name.contains("Sandstone"):continue
  var original: Material=part.get_active_material(0)
  if not original is StandardMaterial3D:continue
  var shader:=Shader.new();shader.code="shader_type spatial; uniform vec4 tint:source_color; varying vec3 p; float h(vec3 v){return fract(sin(dot(v,vec3(12.9898,78.233,39.34)))*43758.5453);} void vertex(){p=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;} void fragment(){ALBEDO=tint.rgb*(.96+.04*h(floor(p*22.)));ROUGHNESS=.94;}"
  var m:=ShaderMaterial.new();m.shader=shader;m.set_shader_parameter("tint",original.albedo_color);part.material_override=m
func mat(color: String) -> StandardMaterial3D:
 var m:=StandardMaterial3D.new();m.albedo_color=Color(color);m.roughness=0.88;return m
func box(size: Vector3,pos: Vector3,color: String) -> MeshInstance3D:
 var mesh:=BoxMesh.new();mesh.size=size
 var o:=MeshInstance3D.new();o.mesh=mesh;o.position=pos;o.material_override=mat(color);geometry.add_child(o);return o
func orb(pos: Vector3,scale_value: Vector3,color: String) -> MeshInstance3D:
 var mesh:=SphereMesh.new();mesh.radius=1;mesh.height=2
 var o:=MeshInstance3D.new();o.mesh=mesh;o.position=pos;o.scale=scale_value;o.material_override=mat(color);geometry.add_child(o);return o
func asset(id: String,pos: Vector3,scale_value: float=1.0) -> Node3D:
 var o: Node3D=load("res://assets/demo/"+id+".glb").instantiate();o.position=pos;o.scale=Vector3.ONE*scale_value;geometry.add_child(o);surface_shader(o);return o
func terrain(poly: PackedVector2Array,height: float,color: String) -> void:
 var vertices:=PackedVector3Array()
 for p: Vector2 in poly:vertices.append(Vector3(p.x,height,p.y))
 var triangles: PackedInt32Array=Geometry2D.triangulate_polygon(poly)
 var indices:=PackedInt32Array()
 for i: int in range(0,triangles.size(),3):indices.append_array([triangles[i],triangles[i+1],triangles[i+2]])
 var a: Array=[];a.resize(Mesh.ARRAY_MAX);a[Mesh.ARRAY_VERTEX]=vertices;a[Mesh.ARRAY_INDEX]=indices;a[Mesh.ARRAY_NORMAL]=PackedVector3Array(Array(vertices).map(func(_v: Vector3):return Vector3.UP))
 var mesh:=ArrayMesh.new();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,a)
 var o:=MeshInstance3D.new();o.mesh=mesh;o.material_override=mat(color);o.material_override.cull_mode=BaseMaterial3D.CULL_DISABLED;geometry.add_child(o)
func npc(id: String,at: Vector3,shirt: int) -> void:
 points[id]=at
 var o: Node3D=asset("trainer",at)
 var look: Dictionary=preload("res://scripts/domain/appearance.gd").DEFAULT.duplicate();look.shirt=shirt;look.style=1;look.skin=shirt%4;Style.apply(o,look);o.name="NPC_"+id
 blockers.append(Rect2(Vector2(at.x-.35,at.z-.35),Vector2(.7,.7)))
 var label:=Label3D.new();label.text={"vyna":"Vyna","professor":"Professeur","resident":"Habitant","trainer":"Dresseur","nurse":"Soins","merchant":"Boutique","clothier":"Vêtements"}.get(id,id);label.position=at+Vector3(0,2.12,0);label.font_size=28;label.pixel_size=.005;label.billboard=BaseMaterial3D.BILLBOARD_ENABLED;label.visible=show_labels;geometry.add_child(label)
func _ready() -> void:
 geometry=Node3D.new();add_child(geometry)
 hero=load("res://assets/demo/trainer.glb").instantiate();add_child(hero)
 camera=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.size=18;add_child(camera);camera.current=true
func build(state: RefCounted) -> void:
 location=state.location
 for n: Node in geometry.get_children():geometry.remove_child(n);n.queue_free()
 blockers.clear();points.clear()
 if location=="town":town()
 elif location=="trail":trail()
 else:interior()
 hero.position=state.position;Style.apply(hero,state.campaign.adventure.appearance);configure_labels(show_labels);follow()
func cliff(at: Vector3,radius: float,height: float) -> void:
 var v:=PackedVector3Array();var normals:=PackedVector3Array();var colors:=PackedColorArray();var rings: Array=[]
 for level: int in range(4):
  var row: Array=[]
  for i: int in range(14):
   var a: float=i*TAU/14;var r: float=radius*(1.0-level*.065)*(1+sin(i*2.7+at.x)*.09)
   row.append(Vector3(cos(a)*r,[0.0,height*.25,height*.78,height][level],sin(a)*r))
  rings.append(row)
 for level: int in range(3):
  for i: int in range(14):
   var j: int=(i+1)%14
   for tri: Array in [[rings[level][i],rings[level+1][i],rings[level+1][j]],[rings[level][i],rings[level+1][j],rings[level][j]]]:
    var normal: Vector3=(tri[1]-tri[0]).cross(tri[2]-tri[0]).normalized()
    var color: Color=Color("95816a").darkened((i%4)*.035)
    for point: Vector3 in tri:v.append(point);normals.append(normal);colors.append(color)
 var a: Array=[];a.resize(Mesh.ARRAY_MAX);a[Mesh.ARRAY_VERTEX]=v;a[Mesh.ARRAY_NORMAL]=normals;a[Mesh.ARRAY_COLOR]=colors
 var mesh:=ArrayMesh.new();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,a)
 var obj:=MeshInstance3D.new();obj.mesh=mesh;obj.position=at;obj.material_override=mat("ffffff");obj.material_override.vertex_color_use_as_albedo=true;obj.material_override.cull_mode=BaseMaterial3D.CULL_DISABLED;geometry.add_child(obj)
 var cap:=PackedVector2Array()
 for p: Vector3 in rings[3]:cap.append(Vector2(p.x+at.x,p.z+at.z))
 terrain(cap,at.y+height,"658965")
func town() -> void:
 var water:=box(Vector3(130,.15,110),Vector3(0,-.45,0),"3b9ca7")
 var shader:=Shader.new();shader.code="shader_type spatial; render_mode cull_disabled; varying vec3 p; void vertex(){p=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz; VERTEX.y+=sin(p.x*.9+TIME*.6)*.014;} void fragment(){float f=sin(p.x*1.7+p.z*1.2+TIME)*.025; ALBEDO=vec3(.10,.48,.54)+f;ROUGHNESS=.36;}";var watermat:=ShaderMaterial.new();watermat.shader=shader;water.material_override=watermat
 terrain(PackedVector2Array([Vector2(-28,-28),Vector2(28,-28),Vector2(28,16),Vector2(18,16),Vector2(18,8),Vector2(9,8),Vector2(9,16),Vector2(-28,16)]),-.03,"ccc29d")
 # Broad esplanades and round central plaza, not an identical square grid.
 box(Vector3(11,.04,42),Vector3(0,0,-5),"e4dac0");box(Vector3(45,.04,6),Vector3(0,.01,5),"e4dac0")
 var disk:=CylinderMesh.new();disk.top_radius=7;disk.bottom_radius=7;disk.height=.05;disk.radial_segments=64
 var plaza:=MeshInstance3D.new();plaza.mesh=disk;plaza.position=Vector3(0,.015,0);plaza.material_override=mat("ded5bd");geometry.add_child(plaza)
 for id: String in TOWN_BUILDINGS:
  var at: Vector3=TOWN_BUILDINGS[id];asset("villa" if id=="home" else id,at,.9);blockers.append(Rect2(Vector2(at.x-3.4,at.z-2.3),Vector2(6.8,4.6)))
  if id in ["center","shop","home"]:
   points["door-"+id]=at+Vector3(0,0,3.3)
   var sign:=Label3D.new();sign.text={"center":"CENTRE","shop":"BOUTIQUE","home":"MAISON"}[id];sign.position=at+Vector3(0,2.8,2.5);sign.font_size=28;sign.pixel_size=.007;sign.billboard=BaseMaterial3D.BILLBOARD_ENABLED;geometry.add_child(sign)
 asset("clocktower",Vector3(-7,0,-5),.8);blockers.append(Rect2(Vector2(-8.3,-6.3),Vector2(2.6,2.6)))
 npc("vyna",Vector3(-3,0,2),2);npc("professor",Vector3(4,0,0),0);npc("resident",Vector3(-12,0,11),3)
 points["gate"]=Vector3(0,0,-23);points["supplies"]=Vector3(6,0,7)
 box(Vector3(.7,.6,.6),points.supplies+Vector3(0,.3,0),"927150")
 # Stone seawall, wooden dock, small boat, planted terraces and background cliffs.
 for x: int in range(-25,8,3):box(Vector3(2.75,.65,.4),Vector3(x,.325,15.5),"a69e88")
 box(Vector3(2,.16,9),Vector3(11,.03,11.5),"8e7252")
 for z: int in [8,11,14]:
  for x: int in [10,12]:box(Vector3(.15,.6,.15),Vector3(x,.3,z),"7d6850")
 orb(Vector3(17,-.02,12),Vector3(1.4,.4,3),"a17d53");box(Vector3(.10,5,.10),Vector3(17,2.5,12),"8f795a")
 var sailmesh:=ImmediateMesh.new();sailmesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES);sailmesh.surface_add_vertex(Vector3(17,1,12));sailmesh.surface_add_vertex(Vector3(17,4.7,12));sailmesh.surface_add_vertex(Vector3(19.3,1,12));sailmesh.surface_end()
 var sail:=MeshInstance3D.new();sail.mesh=sailmesh;sail.material_override=mat("eee8d5");sail.material_override.cull_mode=BaseMaterial3D.CULL_DISABLED;geometry.add_child(sail)
 for x: int in [-23,-10,8,23]:
  for z: int in [-20,6,12]:OldKit.place(geometry,"palm",Vector3(x,0,z),1.15)
 for x: int in [-6,6]:
  for z: int in [-11,8]:OldKit.place(geometry,"lamp",Vector3(x,0,z),.85)
 for x: int in [-23,23]:
  for z: int in [-16,-5,5]:orb(Vector3(x,.35,z),Vector3(1.3,.8,1.7),"4e8264")
 for x: int in [-36,-25,-12,15,29,38]:cliff(Vector3(x,-.5,-37),8,8 if x in [-12,15] else 6)
 for x: int in [-26,26]:
  for z: int in [-19,-8,3,12]:cliff(Vector3(x,-2.8,z),3.5,2.7)
 for x: int in [-22,-12,11,21]:asset("villa",Vector3(x,3.2,-30),.7)
 box(Vector3(50,.2,6),Vector3(0,3,-30),"b9b28e")
 # Raised upper town behind the playable gate, carrying the concept's terraced skyline.
 for side: int in [-1,1]:
  for z: int in [-14,3]:
   OldKit.place(geometry,"bench",Vector3(side*6.2,0,z),.9,side*PI/2)
 for z: int in range(-20,13,4):
  for x: int in [-5,5]:box(Vector3(.7,.25,1.1),Vector3(x,.12,z),"a19276");orb(Vector3(x,.42,z),Vector3(.55,.35,.7),"5e8967")
 OldKit.place(geometry,"landmark-tropical",Vector3(4,3,-50),2)
func trail() -> void:
 box(Vector3(44,.2,44),Vector3(0,-.1,0),"739472");box(Vector3(5,.03,33),Vector3(0,.02,-3),"d3c49e")
 points={"exit":Vector3(0,0,12),"survey":Vector3(-6,0,-7),"grass":Vector3(5,0,-4)}
 npc("trainer",Vector3(2.2,0,-12),1)
 box(Vector3(1,1.4,.8),points.survey+Vector3(0,.7,0),"92b7af")
 box(Vector3(6,.04,6),Vector3(6,.04,-4),"407754")
 for x: int in [-11,-8,11]:
  for z: int in [-15,-8,0,7]:OldKit.place(geometry,"palm",Vector3(x,0,z),1.15)
 for x: int in [-14,14]:
  for z: int in [-12,4]:OldKit.place(geometry,"rock",Vector3(x,0,z),2)
func interior() -> void:
 box(Vector3(18,.12,20),Vector3(0,-.06,0),"bdaf91");box(Vector3(18,3.5,.25),Vector3(0,1.75,-10),"ece6d8")
 for side: int in [-1,1]:box(Vector3(.25,3.5,20),Vector3(side*9,1.75,0),"ece6d8")
 points["exit"]=Vector3(0,0,9)
 if location=="center":
  box(Vector3(9,.9,1.2),Vector3(0,.45,-4),"749faa");npc("nurse",Vector3(0,0,-5),1);points.pc=Vector3(5,0,-2)
  box(Vector3(1,1.4,.6),Vector3(5,.7,-2),"4a606b");box(Vector3(.8,.5,.04),Vector3(5,1,-1.65),"9bd7d9")
 elif location=="shop":
  box(Vector3(8,.9,1.2),Vector3(0,.45,-4),"a08768");npc("merchant",Vector3(0,0,-5),0);npc("clothier",Vector3(-5,0,-2),2)
  for x: int in [-7,7]:
   for y: int in [1,2,3]:box(Vector3(1.5,.20,3),Vector3(x,y*.7,-5),"967f61")
 else:
  box(Vector3(3,.5,5),Vector3(-5,.25,-4),"657f9b");box(Vector3(2.8,.2,4.5),Vector3(-5,.6,-4),"e3d8b7");box(Vector3(4,.8,1.2),Vector3(3,.4,-7),"937e63")
  points.mirror=Vector3(4,0,-3);box(Vector3(1.3,2,.12),Vector3(4,1,-3),"90acaf")
 # Furniture blockers cover both render footprint and path checks.
 if location=="home":
  blockers.append(Rect2(Vector2(-6.5,-6.5),Vector2(3,5)));blockers.append(Rect2(Vector2(1,-7.6),Vector2(4,1.2)));blockers.append(Rect2(Vector2(3.3,-3.1),Vector2(1.4,.3)))
 else:blockers.append(Rect2(Vector2(-4.5,-4.7),Vector2(9,1.4)))
 if location=="center":blockers.append(Rect2(Vector2(4.5,-2.3),Vector2(1,.6)))
 if location=="shop":
  for x: int in [-7,7]:blockers.append(Rect2(Vector2(x-.75,-6.5),Vector2(1.5,3)))
func can_walk(at: Vector3) -> bool:
 if location=="town":
  if at.x< -25 or at.x>25 or at.z< -24 or at.z>15:return false
  if at.x>9 and at.x<18 and at.z>8 and not (at.x>10 and at.x<12):return false
 elif location=="trail":
  if absf(at.x)>14 or at.z< -18 or at.z>13:return false
 elif absf(at.x)>8.5 or absf(at.z)>9.5:return false
 for r: Rect2 in blockers:
  if r.grow(.22).has_point(Vector2(at.x,at.z)):return false
 return true
func move_hero(axis: Vector2,delta: float,state: RefCounted) -> void:
 var motion:=Vector3(axis.x,0,axis.y)*3.8*minf(delta,.08)/maxf(1,Engine.time_scale)
 var steps: int=maxi(1,ceili(motion.length()/.12))
 var old: Vector3=state.position
 for i: int in range(steps):
  var next: Vector3=state.position+Vector3(motion.x/steps,0,0)
  if can_walk(next):state.position=next
  next=state.position+Vector3(0,0,motion.z/steps)
  if can_walk(next):state.position=next
 hero.position=state.position
 var animator: AnimationPlayer=hero.find_child("AnimationPlayer",true,false)
 if old.distance_to(state.position)>.0001:
  hero.rotation.y=atan2(motion.x,motion.z)
  if animator and not animator.is_playing():animator.play(animator.get_animation_list()[-1])
 elif animator:animator.stop()
 follow()
func follow() -> void:
 camera.position=hero.position+Vector3(0,13,15);camera.look_at(hero.position+Vector3(0,1,0))
func nearest() -> String:
 var id: String="";var distance: float=2.1
 for key: String in points:
  var d: float=hero.position.distance_to(points[key])
  if d<distance:id=key;distance=d
 return id
