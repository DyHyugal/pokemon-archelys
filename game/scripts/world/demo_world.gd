extends Node3D
const State=preload("res://scripts/domain/demo_state.gd")
const Style=preload("res://scripts/world/demo_actor_style.gd")
const OldKit=preload("res://scripts/world/asset_kit.gd")
const Scenery=preload("res://scripts/world/tripo_scenery.gd")
const Chapter=preload("res://scripts/domain/demo_chapter.gd")
var logic_only: bool=false
var chapter: RefCounted
var blockers: Array[Rect2]=[]
var points: Dictionary={}
var hero: Node3D
var camera: Camera3D
var geometry: Node3D
var location: String=""
var avatar_preview: Dictionary={}
const TOWN_BUILDINGS={"center":Vector3(-15,0,-2),"shop":Vector3(14,0,-12),"home":Vector3(-16,0,8),"arcade":Vector3(0,0,-14),"villa":Vector3(14,0,0)}
const SHOP_SIZE_MULTIPLIER=1.25
static func shop_blocker() -> Rect2:
 var at: Vector3=TOWN_BUILDINGS.shop
 return Rect2(Vector2(at.x-2.55*SHOP_SIZE_MULTIPLIER,at.z-2.8*SHOP_SIZE_MULTIPLIER),Vector2(5.1,5.6)*SHOP_SIZE_MULTIPLIER)
static func shop_door_position() -> Vector3:
 return TOWN_BUILDINGS.shop+Vector3(1.0,0,3.3)*SHOP_SIZE_MULTIPLIER
var show_labels: bool=true
var locale: String="fr"
func configure_labels(enabled: bool) -> void:
 show_labels=enabled
 for label: Node in geometry.find_children("*","Label3D",true,false):
  label.visible=enabled
  if label.has_meta("caption_id"):label.text=preload("res://scripts/domain/demo_guidance.gd").title(str(label.get_meta("caption_id")),locale)
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
 if logic_only:
  var placeholder:=Node3D.new();placeholder.position=pos;geometry.add_child(placeholder);return placeholder
 var o: Node3D=preload("res://scripts/services/imported_assets.gd").instantiate(id)
 if o==null:o=load("res://assets/demo/"+id+".glb").instantiate();surface_shader(o)
 o.position=pos;o.scale*=scale_value;geometry.add_child(o);return o
func scenery(id: String,pos: Vector3,footprint: Vector2,height_limit: float=12.0,angle: float=0.0) -> Node3D:
 var node:=Scenery.place(geometry,id,pos,footprint,height_limit,angle)
 if node!=null and location in ["center","shop","home"] and id!="toaster":
  var b:=Scenery.bounds(node)
  blockers.append(Rect2(Vector2(b.position.x,b.position.z),Vector2(b.size.x,b.size.z)))
 return node
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
 var label:=Label3D.new();label.text={"vyna":"Vyna","professor":"Professeur","resident":"Habitant","trainer":"Dresseur","nurse":"Soins","merchant":"Boutique","clothier":"Vêtements","fossils":"Fossiles"}.get(id,id);label.position=at+Vector3(0,2.12,0);label.set_meta("caption_id",id);label.font_size=28;label.pixel_size=.005;label.billboard=BaseMaterial3D.BILLBOARD_ENABLED;label.visible=show_labels;geometry.add_child(label)
func _ready() -> void:
 geometry=Node3D.new();add_child(geometry)
 hero=Node3D.new() if logic_only else preload("res://scripts/world/tripo_actor.gd").create();add_child(hero)
 camera=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.size=18;add_child(camera);camera.current=not logic_only
func build(state: RefCounted) -> void:
 location=state.location;chapter=state.chapter
 chapter.surfing=chapter.flags.has("keeper") and Chapter.is_water(location,Vector2(state.position.x,state.position.z))
 if logic_only:
  build_logic(state);return
 for n: Node in geometry.get_children():geometry.remove_child(n);n.queue_free()
 blockers.clear();points.clear()
 if location=="town":town()
 elif location=="trail":
  trail();expedition(state)
  if state.chapter.flags.has("started"):
   points["go-canopy"]=Vector3(0,0,-17)
   npc("roadblock",Vector3(-3.5,0,-15),3)
 elif location in Chapter.LOCATIONS:preload("res://scripts/world/demo_chapter_world.gd").build(self,state)
 else:interior()
 # Older saves can stand inside the newly enlarged shop footprint.
 # Only reposition affected characters; do not change party, flags or save schema.
 if location=="town" and shop_blocker().grow(.22).has_point(Vector2(state.position.x,state.position.z)):
  state.position=shop_door_position()
 recover_position(state)
 hero.position=state.position;Style.apply(hero,state.campaign.adventure.appearance);configure_labels(show_labels);follow()
func build_logic(state: RefCounted) -> void:
 for node: Node in geometry.get_children():geometry.remove_child(node);node.queue_free()
 var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/hd2d/manifest.json"))
 var layout: Dictionary=data.layouts[location];points.clear();blockers.clear()
 for id: String in layout.points:
  var p: Array=layout.points[id];points[id]=Vector3(p[0],p[1],p[2])
 for row: Array in layout.blockers:blockers.append(Rect2(row[0],row[1],row[2],row[3]))
 if location=="trail":
  if not state.chapter.flags.has("started"):
   points.erase("go-canopy");points.erase("roadblock");blockers.erase(Rect2(-3.85,-15.35,.7,.7))
  var actions: Dictionary=preload("res://scripts/domain/demo_expedition.gd").ACTIONS
  for action: String in actions:
   if state.flags.has(actions[action]) and points.has(action):
    var at: Vector3=points[action];blockers.erase(Rect2(at.x-.5,at.z-.5,1,1));points.erase(action)
 if location=="town" and shop_blocker().grow(.22).has_point(Vector2(state.position.x,state.position.z)):state.position=shop_door_position()
 recover_position(state);hero.position=state.position;follow()
func recover_position(state: RefCounted) -> void:
 if can_walk(state.position):return
 # Restore saves made on a newly placed prop without resetting any progression.
 var old: Vector3=state.position
 for ring: int in range(1,41):
  for step: int in range(32):
   var angle: float=step*TAU/32
   var point:=old+Vector3(cos(angle),0,sin(angle))*(ring*.25)
   if can_walk(point):state.position=point;return
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
  var at: Vector3=TOWN_BUILDINGS[id]
  var replacement: String={"center":"unknown","home":"stylized-cottage","arcade":"house","villa":"medieval-cottage"}.get(id,"")
  var building: Node3D=scenery(replacement,at,Vector2(6.8,4.6),7.5) if id!="shop" else asset("shop",at,.9*SHOP_SIZE_MULTIPLIER)
  if id=="shop":
   building.name="TripoShop"
   for part: Node in building.find_children("*","MeshInstance3D",true,false):
    var original: Material=part.get_active_material(0)
    if original is StandardMaterial3D:
     var material: StandardMaterial3D=original.duplicate();material.roughness=.9;material.metallic=0;material.metallic_specular=.18;material.normal_scale=.35;part.material_override=material
   blockers.append(shop_blocker())
  else:blockers.append(Rect2(Vector2(at.x-3.4,at.z-2.3),Vector2(6.8,4.6)))
  if id in ["center","shop","home"]:
   points["door-"+id]=shop_door_position() if id=="shop" else at+Vector3(0,0,3.3)
   var sign:=Label3D.new();sign.text={"center":"CENTRE","shop":"BOUTIQUE","home":"MAISON"}[id];sign.position=at+Vector3(0,2.8,2.5)*(SHOP_SIZE_MULTIPLIER if id=="shop" else 1.0);sign.set_meta("caption_id","door-"+id);sign.font_size=28;sign.pixel_size=.007;sign.billboard=BaseMaterial3D.BILLBOARD_ENABLED;geometry.add_child(sign)
 scenery("steampunk-tower",Vector3(-7,0,-5),Vector2(2.6,2.6),8.0);blockers.append(Rect2(Vector2(-8.3,-6.3),Vector2(2.6,2.6)))
 npc("vyna",Vector3(-3,0,2),2);npc("professor",Vector3(4,0,0),0);npc("resident",Vector3(-12,0,11),3)
 points["fish"]=Vector3(11,0,14);points["gate"]=Vector3(0,0,-23);points["supplies"]=Vector3(6,0,7)
 scenery("crate",points.supplies,Vector2(.7,.6),.8)
 # Stone seawall, wooden dock, small boat, planted terraces and background cliffs.
 for x: int in range(-25,8,3):box(Vector3(2.75,.65,.4),Vector3(x,.325,15.5),"a69e88")
 box(Vector3(2,.16,9),Vector3(11,.03,11.5),"8e7252")
 for z: int in [8,11,14]:
  for x: int in [10,12]:box(Vector3(.15,.6,.15),Vector3(x,.3,z),"7d6850")
 scenery("stylized-boat",Vector3(17,-.12,12),Vector2(3.5,6),5.0)
 for x: int in [-23,-10,8,23]:
  for z: int in [-20,6,12]:OldKit.place(geometry,"palm",Vector3(x,0,z),1.15)
 for x: int in [-6,6]:
  for z: int in [-11,8]:OldKit.place(geometry,"lamp",Vector3(x,0,z),.85)
 for x: int in [-23,23]:
  for z: int in [-16,-5,5]:scenery("ornamental-plant",Vector3(x,0,z),Vector2(1.8,2),1.7)
 for x: int in [-36,-25,-12,15,29,38]:scenery("rocky-cliff",Vector3(x,-.5,-37),Vector2(15,12),8)
 for x: int in [-26,26]:
  for z: int in [-19,-8,3,12]:scenery("rock-pile",Vector3(x,-1,z),Vector2(5,5),3)
 for x: int in [-22,-12,11,21]:scenery("house" if x<0 else "medieval-cottage",Vector3(x,3.2,-30),Vector2(6,4.5),7)
 box(Vector3(50,.2,6),Vector3(0,3,-30),"b9b28e")
 # Raised upper town behind the playable gate, carrying the concept's terraced skyline.
 for side: int in [-1,1]:
  for z: int in [-14,3]:
   OldKit.place(geometry,"bench",Vector3(side*6.2,0,z),.9,side*PI/2)
 for z: int in range(-20,13,4):
  for x: int in [-5,5]:box(Vector3(.7,.25,1.1),Vector3(x,.12,z),"a19276");scenery("ornamental-plant",Vector3(x,.25,z),Vector2(1,1),.7)
 scenery("fantasy-temple",Vector3(4,3,-49),Vector2(15,12),14)
 scenery("stylized-archway",Vector3(0,0,-25),Vector2(7,2),6)
 scenery("gazebo-1",Vector3(21,0,9),Vector2(4,4),5)
 scenery("arcade-console",Vector3(0,0,-10),Vector2(1.2,.8),1.6)
 blockers.append(Rect2(Vector2(19,7),Vector2(4,4)))
 blockers.append(Rect2(Vector2(-.6,-10.4),Vector2(1.2,.8)))
func trail() -> void:
 box(Vector3(44,.2,44),Vector3(0,-.1,0),"739472");box(Vector3(5,.03,33),Vector3(0,.02,-3),"d3c49e")
 points={"exit":Vector3(0,0,12),"survey":Vector3(-6,0,-7),"grass":Vector3(5,0,-4)}
 npc("trainer",Vector3(2.2,0,-12),1)
 scenery("signpost",points.survey,Vector2(1,.8),1.6)
 box(Vector3(6,.04,6),Vector3(6,.04,-4),"407754")
 for x: int in [-11,-8,11]:
  for z: int in [-15,-8,0,7]:scenery("tree-1" if x<0 else "tree",Vector3(x,0,z),Vector2(4,4),5.5)
 for x: int in [-14,14]:
  for z: int in [-12,4]:OldKit.place(geometry,"rock",Vector3(x,0,z),2)
func expedition(state: RefCounted) -> void:
 var fixtures: Dictionary={"cut":Vector3(-5,0,2),"rock-smash":Vector3(-6,0,-12),"strength":Vector3(8,0,-12)}
 for action: String in fixtures:
  var flag: String=preload("res://scripts/domain/demo_expedition.gd").ACTIONS[action]
  if not state.flags.has(flag):
   var at: Vector3=fixtures[action];points[action]=at
   OldKit.place(geometry,"palm" if action=="cut" else "rock",at,.65 if action=="cut" else .7)
   blockers.append(Rect2(Vector2(at.x-.5,at.z-.5),Vector2(1,1)))
 points['expedition-cache']=Vector3(-9,0,-3)
 scenery("treasure-chest",points['expedition-cache'],Vector2(1.4,.8),1.1)
func interior() -> void:
 box(Vector3(18,.12,20),Vector3(0,-.06,0),"bdaf91");box(Vector3(18,3.5,.25),Vector3(0,1.75,-10),"ece6d8")
 for side: int in [-1,1]:box(Vector3(.25,3.5,20),Vector3(side*9,1.75,0),"ece6d8")
 points["exit"]=Vector3(0,0,9)
 if location=="center":
  scenery("reception-desk",Vector3(0,0,-4),Vector2(9,1.2),2);npc("nurse",Vector3(0,0,-5),1);npc("fossils",Vector3(-5,0,-2),3);points.pc=Vector3(5,0,-2)
  scenery("arcade-console",Vector3(5,0,-2),Vector2(1,.6),1.8)
  scenery("furniture",Vector3(-6,0,-6),Vector2(3,2.5),1.5)
 elif location=="shop":
  scenery("curved-desk",Vector3(0,0,-4),Vector2(8,1.2),2);npc("merchant",Vector3(0,0,-5),0);npc("clothier",Vector3(-5,0,-2),2)
  for x: int in [-7,7]:
   scenery("crate",Vector3(x,0,-5),Vector2(1.5,1.5),1.5)
   scenery("crate",Vector3(x,0,-3),Vector2(1.5,1.5),1.5)
 else:
  scenery("bed",Vector3(-5,0,-4),Vector2(3,5),2);scenery("curved-desk",Vector3(3,0,-7),Vector2(4,1.2),2)
  scenery("toaster",Vector3(3,.8,-7),Vector2(.6,.5),.5)
  points.mirror=Vector3(4,0,-3);box(Vector3(1.3,2,.12),Vector3(4,1,-3),"90acaf")
 # Imported furniture uses its actual rendered bounds; mirror remains procedural.
 if location=="home":blockers.append(Rect2(Vector2(3.3,-3.1),Vector2(1.4,.3)))
func can_walk(at: Vector3) -> bool:
 if location=="town":
  if at.x< -25 or at.x>25 or at.z< -24 or at.z>15:return false
  if Chapter.is_water(location,Vector2(at.x,at.z)) and not chapter.surfing:return false
 elif location in ["trail"]+Chapter.LOCATIONS:
  if Chapter.is_water(location,Vector2(at.x,at.z)) and not chapter.surfing:return false
  if absf(at.x)>14 or at.z< -18 or at.z>13:return false
 elif absf(at.x)>8.5 or absf(at.z)>9.5:return false
 for r: Rect2 in blockers:
  if r.grow(.22).has_point(Vector2(at.x,at.z)):return false
 return true
func move_hero(axis: Vector2,delta: float,state: RefCounted,running: bool=false) -> void:
 var rate: float=preload("res://scripts/world/tripo_actor.gd").RUN_SPEED if running else preload("res://scripts/world/tripo_actor.gd").WALK_SPEED
 var motion:=Vector3(axis.x,0,axis.y)*rate*minf(delta,.08*Engine.time_scale)
 var steps: int=maxi(1,ceili(motion.length()/.12))
 var old: Vector3=state.position
 for i: int in range(steps):
  var next: Vector3=state.position+Vector3(motion.x/steps,0,0)
  if can_walk(next):state.position=next
  next=state.position+Vector3(0,0,motion.z/steps)
  if can_walk(next):state.position=next
 if Chapter.is_water(location,Vector2(old.x,old.z)) and not Chapter.is_water(location,Vector2(state.position.x,state.position.z)):chapter.surfing=false
 hero.position=state.position
 var moving: bool=old.distance_to(state.position)>.0001
 if moving:hero.rotation.y=atan2(motion.x,motion.z)
 preload("res://scripts/world/tripo_actor.gd").animate(hero,moving,running,rate*axis.length())
 follow()
func follow() -> void:
 camera.position=hero.position+Vector3(0,13,15);camera.look_at(hero.position+Vector3(0,1,0))
func nearest() -> String:
 var at: Vector2=Vector2(hero.position.x,hero.position.z)
 var id: String="";var distance: float=2.1
 for key: String in points:
  var d: float=hero.position.distance_to(points[key])
  if d<distance:id=key;distance=d
 if id.is_empty() and not chapter.surfing and Chapter.at_shore(location,at):return "surf"
 return id
