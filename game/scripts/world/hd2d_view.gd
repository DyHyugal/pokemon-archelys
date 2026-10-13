extends CanvasLayer
## Native 2D presentation, fixed baked sprites. Gameplay stays in the existing domain.
const Guidance=preload("res://scripts/domain/demo_guidance.gd")
const Expedition=preload("res://scripts/domain/demo_expedition.gd")
const INK=preload("res://assets/hd2d/ink.gdshader")
const ROOT="res://assets/hd2d/"
var game: Node
var data: Dictionary
var stage: Node2D
var actors: Node2D
var hero: Node2D
var hero_sprite: Sprite2D
var textures: Dictionary={}
var last_position:=Vector3.ZERO
var direction:=0
var phase:=0.0
var built_key: String=""
class Ground extends Node2D:
 var location: String="town"
 var props: Array=[]
 var stone: Texture2D
 var grass: Texture2D
 func lawn(x: float,z: float,w: float,h: float) -> void:
  lawn_polygon([Vector2(x,z),Vector2(x+w,z),Vector2(x+w,z+h),Vector2(x,z+h)])
 func lawn_polygon(points: Array) -> void:
  var v:=PackedVector2Array();var uv:=PackedVector2Array()
  for point: Vector2 in points:v.append(p(point.x,point.y))
  for at: Vector2 in v:uv.append(at/512.0)
  if grass:draw_polygon(v,PackedColorArray([Color.WHITE]),uv,grass)
  else:draw_colored_polygon(v,Color("82a367"))
 var sprite_sizes: Dictionary={}
 func paving(points: Array) -> void:
  var v:=PackedVector2Array();var uv:=PackedVector2Array()
  for point: Vector2 in points:
   var at:=p(point.x,point.y);v.append(at);uv.append(at/512.0)
  if stone:draw_polygon(v,PackedColorArray([Color.WHITE]),uv,stone)
  else:draw_colored_polygon(v,Color("d8c9a8"))
  v.append(v[0]);draw_polyline(v,Color("9e9171"),2,true)
 func paving_rect(x: float,z: float,w: float,h: float) -> void:
  paving([Vector2(x,z),Vector2(x+w,z),Vector2(x+w,z+h),Vector2(x,z+h)])
 func p(x: float,z: float) -> Vector2:return Vector2(x*64,z*48)
 func polygon(points: Array,color: Color,outline: bool=true) -> void:
  var v:=PackedVector2Array()
  for point: Vector2 in points:v.append(p(point.x,point.y))
  draw_colored_polygon(v,color)
  if outline:v.append(v[0]);draw_polyline(v,Color("77785d"),2,true)
 func slab(x: float,z: float,w: float,h: float,color: Color) -> void:
  draw_rect(Rect2(p(x,z),Vector2(w*64,h*48)),color)
 func stones(x0: int,z0: int,x1: int,z1: int) -> void:
  for z: int in range(z0,z1):
   for x: int in range(x0,x1):
    var c: float=float(posmod(x*31+z*19,7))/7
    var shift: float=.45 if posmod(z,2)==0 else 0
    var xw: float=x+shift
    polygon([Vector2(xw+.05,z+.10),Vector2(xw+.83,z+.04),Vector2(xw+.97,z+.33),Vector2(xw+.90,z+.88),Vector2(xw+.2,z+.95),Vector2(xw+.02,z+.67)],Color("d8c9a8").lerp(Color("ece0bd"),c),false)
    draw_polyline(PackedVector2Array([p(xw+.1,z+.1),p(xw+.8,z+.04),p(xw+.94,z+.3)]),Color(1,.98,.87,.5),1.2,true)
 func _draw() -> void:
  slab(-120,-120,240,240,Color("2f8fa2"))
  for z: int in range(-50,50):
   var wave:=PackedVector2Array()
   for x: int in range(-50,51):wave.append(p(x,z)+Vector2(0,sin(x*.6+z)*4))
   draw_polyline(wave,Color(.73,.94,.91,.12),2,true)
  if location=="town":
   polygon([Vector2(-28,-28),Vector2(28,-28),Vector2(28,16),Vector2(18,16),Vector2(18,8),Vector2(9,8),Vector2(9,16),Vector2(-28,16)],Color("d6c8a1"))
   lawn_polygon([Vector2(-27,-27),Vector2(27,-27),Vector2(27,14),Vector2(18,14),Vector2(18,8),Vector2(9,8),Vector2(9,14),Vector2(-27,14)])
   paving_rect(-3.5,-24,7,39);paving_rect(-25,4,50,4)
   paving_rect(-19,-1,16,4);paving_rect(-19,10,16,3)
   paving_rect(3,-10,16,4);paving_rect(3,1,16,4)
   var circle: Array=[]
   for i: int in range(64):circle.append(Vector2(cos(i*TAU/64)*6,sin(i*TAU/64)*5))
   paving(circle)
   for side: int in [-1,1]:
    for z: int in range(-20,14,2):
     for x: int in [7,21,24]:
      var at:=p(side*x,z)
      draw_line(at+Vector2(-4,3),at+Vector2(-7,-7),Color("5e814d"),2,true)
      draw_line(at,at+Vector2(2,-11),Color("678c51"),2,true)
      if posmod(x+z,5)==0:
       draw_circle(at+Vector2(1,-9),3.5,Color("dea4a0"));draw_circle(at+Vector2(1,-9),1.4,Color("f1db9a"))
   slab(10,7,2,9,Color("896849"))
   for z: int in range(7,16):draw_line(p(10,z),p(12,z),Color("554e39"),2,true)
   for x: int in range(-25,8,3):
    slab(x,15.3,2.7,.6,Color("b5ac8c"));draw_line(p(x,15.3),p(x+2.7,15.3),Color("f6e8c3"),3,true)
  elif location in ["home","shop","center"]:
   slab(-9,-10,18,20,Color("cbb48b"))
   for z: int in range(-10,10):
    for x: int in range(-9,9,3):
     var shift: float=1.5 if posmod(z,2)==1 else 0
     slab(x+shift,z,2.94,.96,Color("cbb189").lightened(float(posmod(x+z,4))*.035))
     draw_line(p(x+shift+.15,z+.4),p(x+shift+2.7,z+.43),Color(.5,.36,.22,.2),1,true)
   polygon([Vector2(-9,-10),Vector2(9,-10),Vector2(9,-14),Vector2(-9,-14)],Color("e9ddbd"))
   for x: int in range(-9,10):draw_line(p(x,-10),p(x,-14),Color(.5,.47,.35,.15),1,true)
   draw_line(p(-9,-10),p(9,-10),Color("8b795b"),6,true)
  else:
   lawn(-16,-19,32,33)
   for z: int in range(-18,13):
    for x: int in range(-15,16):
     if abs(x)<3:continue
     var hue: Color=Color("4f7948") if location in ["trail","canopy"] else Color("87936b")
     var at:=p(x+.4,z+.5)
     draw_line(at+Vector2(-3,2),at+Vector2(-6,-4),hue,1.6,true);draw_line(at,at+Vector2(1,-8),hue,1.6,true);draw_line(at+Vector2(3,2),at+Vector2(7,-3),hue,1.6,true)
   slab(-2,-18,4,32,Color("c9ba93"));stones(-2,-18,2,13)
   if location=="canopy":slab(-12,2,7,7,Color("4cabb3"))
   if location=="springs":slab(-13,-6,9,7,Color("4cabb3"))
  for prop: Dictionary in props:
   var at: Array=prop.at
   var center: Vector2=p(float(at[0])+.3,float(at[2])+.35)
   var radius: float=float(sprite_sizes[prop.sprite].size[0])*.27
   draw_set_transform(center+Vector2(9,4),0,Vector2(1,.3))
   for ring: int in range(4,0,-1):draw_circle(Vector2.ZERO,radius*(.75+ring*.1),Color(0,0,0,.025))
   draw_set_transform(Vector2.ZERO)
func _ready() -> void:
 layer=10;process_priority=100
 data=JSON.parse_string(FileAccess.get_file_as_string(ROOT+"manifest.json"))
 stage=Node2D.new();stage.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR;add_child(stage)
 rebuild()
func project(at: Vector3) -> Vector2:return Vector2(at.x*64,at.z*48-at.y*64)
func texture(key: String) -> Texture2D:
 if not textures.has(key):textures[key]=load(data.sprites[key].path)
 return textures[key]
func sprite(parent: Node2D,key: String,color: Color=Color.WHITE) -> Sprite2D:
 var s:=Sprite2D.new();s.centered=false;parent.add_child(s)
 var material:=ShaderMaterial.new();material.shader=INK;material.set_shader_parameter("shirt",color);material.set_shader_parameter("recolor_shirt",color!=Color.WHITE);s.material=material
 set_frame(s,key);return s
func set_frame(s: Sprite2D,key: String) -> void:
 if s.get_meta("frame","")==key:return
 s.texture=texture(key);s.position=-Vector2(data.sprites[key].anchor[0],data.sprites[key].anchor[1]);s.set_meta("frame",key)
func skip_prop(row: Dictionary) -> bool:
 if game.state.location!="trail":return false
 for action: String in Expedition.ACTIONS:
  var at: Vector3={"cut":Vector3(-5,0,2),"rock-smash":Vector3(-6,0,-12),"strength":Vector3(8,0,-12)}[action]
  if Vector3(row.at[0],row.at[1],row.at[2]).is_equal_approx(at) and game.state.flags.has(Expedition.ACTIONS[action]):return true
 return false
func rebuild() -> void:
 for child: Node in stage.get_children():stage.remove_child(child);child.queue_free()
 var location: String=game.state.location;var layout: Dictionary=data.layouts[location]
 var floor:=Ground.new();floor.location=location;floor.props=layout.props;floor.sprite_sizes=data.sprites;floor.texture_repeat=CanvasItem.TEXTURE_REPEAT_MIRROR
 if ResourceLoader.exists(ROOT+"pavement.png"):floor.stone=load(ROOT+"pavement.png")
 if ResourceLoader.exists(ROOT+"grass.png"):floor.grass=load(ROOT+"grass.png")
 stage.add_child(floor)
 actors=Node2D.new();actors.y_sort_enabled=true;stage.add_child(actors)
 for row: Dictionary in layout.props:
  if skip_prop(row):continue
  var node:=Node2D.new();node.position=project(Vector3(row.at[0],row.at[1],row.at[2]));node.set_meta("prop_id",row.id);actors.add_child(node);sprite(node,row.sprite)
 for row: Dictionary in layout.npcs:
  if row.id=="roadblock" and not game.state.chapter.flags.has("started"):continue
  var node:=Node2D.new();node.name="NPC_"+row.id;node.position=project(Vector3(row.at[0],0,row.at[2]));actors.add_child(node)
  var color: Color=[Color("cc7d67"),Color("5f8ca5"),Color("9b83b9"),Color("bd9b50")][posmod(str(row.id).hash(),4)]
  sprite(node,"hero-0-idle-0",color)
  if game.owner_world.comfort.data.world_labels:
   var label:=Label.new();label.text=Guidance.title(row.id,game.locale);label.position=Vector2(-70,12);label.size=Vector2(140,25);label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.add_theme_font_size_override("font_size",15);label.add_theme_color_override("font_color",Color("383d30"));node.add_child(label)
 hero=Node2D.new();hero.name="Hero2D";actors.add_child(hero);hero_sprite=sprite(hero,"hero-0-idle-0");last_position=game.state.position
func _process(delta: float) -> void:
 if not game.active:return
 visible=not game.battle_panel.visible
 var key: String=game.state.location+JSON.stringify(game.state.flags)+JSON.stringify(game.state.chapter.flags)+game.locale+str(game.owner_world.comfort.data.world_labels)
 if key!=built_key:built_key=key;rebuild()
 var at: Vector3=game.state.position;var motion:=at-last_position
 var paused: bool=game.modal!=null or game.menu.visible or game.battle_panel.visible
 var moving: bool=motion.length()>.00001 and not paused
 if moving:
  if absf(motion.x)>absf(motion.z):direction=1 if motion.x>0 else 3
  else:direction=0 if motion.z>0 else 2
  phase+=delta*(12 if game.owner_world.comfort.wants_run() else 8)
 var clip: String="run" if moving and game.owner_world.comfort.wants_run() else ("walk" if moving else "idle")
 set_frame(hero_sprite,"hero-%d-%s-%d" % [direction,clip,int(phase)%8 if moving else 0])
 hero.position=project(at);last_position=at
 var zoom: float=get_viewport().get_visible_rect().size.y/1080.0*.72*18.0/game.world.camera.size
 stage.scale=Vector2.ONE*zoom;stage.position=get_viewport().get_visible_rect().size/2-project(at)*zoom
