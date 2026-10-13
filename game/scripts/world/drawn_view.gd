extends CanvasLayer
## One world metric, foot-anchored frames and independently sorted scenery.
const Layouts=preload("res://scripts/world/drawn_layouts.gd")
const Guidance=preload("res://scripts/domain/demo_guidance.gd")
const Expedition=preload("res://scripts/domain/demo_expedition.gd")
const INK=preload("res://assets/hd2d/ink.gdshader")
const SURFACE=preload("res://assets/drawn/calibration/surface.gdshader")
const FOLIAGE=preload("res://assets/drawn/calibration/foliage.gdshader")
const ROOT=Layouts.ROOT+"calibration/"
var game: Node
var stage: Node2D
var actors: Node2D
var hero: Sprite2D
var backdrop: Sprite2D
var built_key: String=""
var textures: Dictionary={}
var surfaces: Dictionary={}
var frames: Dictionary
var hero_texture: Texture2D
var kit_texture: Texture2D
var size:=Vector2.ZERO
var origin:=Vector2.ZERO
var direction:=0
var stride:=0.0
var last_position:=Vector3.ZERO
var real_clock:=0.0
var surface_mode: String="water"
var water_material: ShaderMaterial
var water: Polygon2D
var trees: Array[Sprite2D]=[]
var grid_visible:=false
var animations_enabled:=true
var surface_notice: Label
class Bank extends Node2D:
 var grid_visible:=false
 func _draw() -> void:
  draw_line(Vector2(-768,512),Vector2(768,512),Color("8d8b76"),14,true)
  draw_line(Vector2(-768,504),Vector2(768,504),Color("e8d8ac"),10,true)
  if grid_visible:
   for x: int in range(-12,13):draw_line(Vector2(x*64,-576),Vector2(x*64,512),Color(1,1,1,.23),1,true)
   for z: int in range(-9,9):draw_line(Vector2(-768,z*64),Vector2(768,z*64),Color(1,1,1,.23),1,true)
var bank: Bank
func _ready() -> void:
 layer=10;process_priority=100
 var background:=ColorRect.new();background.color=Color("142a31");background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);background.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(background)
 stage=Node2D.new();stage.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR;add_child(stage)
 surface_notice=Label.new();surface_notice.text="APERÇU LAVE — HORS SCÉNARIO / LAVA PREVIEW";surface_notice.position=Vector2(24,135);surface_notice.add_theme_font_size_override("font_size",17);surface_notice.add_theme_color_override("font_outline_color",Color.BLACK);surface_notice.add_theme_constant_override("outline_size",4);add_child(surface_notice)
 frames=JSON.parse_string(FileAccess.get_file_as_string(ROOT+"frames.json"))
 hero_texture=load(ROOT+"hero-sheet.png");kit_texture=load(ROOT+"kit.png")
 var ground: Image=load(ROOT+"ground.png").get_image()
 var half:=Vector2i(ground.get_width()/2,ground.get_height()/2)
 for i: int in range(4):
  # Repeat independent textures, not the full atlas containing other biomes.
  surfaces[["grass","path","water","lava"][i]]=ImageTexture.create_from_image(ground.get_region(Rect2i(Vector2i(i%2,i/2)*half,half)))
 rebuild()
func project(at: Vector3) -> Vector2:return Vector2(at.x,at.z)*Layouts.TILE_PIXELS
func texture(key: String) -> Texture2D:
 if not textures.has(key):textures[key]=load(key)
 return textures[key]
func preview_texture() -> Texture2D:
 var row: Array=frames.hero[0];var atlas:=AtlasTexture.new();atlas.atlas=hero_texture;atlas.region=Rect2(row[0],row[1],row[2],row[3]);atlas.filter_clip=true;return atlas
func set_frame(sprite: Sprite2D,heading: int,column: int) -> void:
 var index: int=heading*3+column
 var row: Array=frames.hero[index]
 sprite.texture=hero_texture;sprite.region_enabled=true;sprite.region_rect=Rect2(row[0],row[1],row[2],row[3]);sprite.centered=false
 sprite.offset=Vector2(-row[2]/2.0,-row[3]);sprite.scale=Vector2.ONE*Layouts.HERO_HEIGHT/row[3]
 sprite.set_meta("frame",index)
func actor(id: String,at: Vector3,color: Color) -> Sprite2D:
 var sprite:=Sprite2D.new();sprite.name=id;set_frame(sprite,0,0);sprite.position=project(at);actors.add_child(sprite)
 if color!=Color.WHITE:
  var material:=ShaderMaterial.new();material.shader=INK;material.set_shader_parameter("recolor_shirt",true);material.set_shader_parameter("shirt",color);sprite.material=material
 return sprite
func plane(id: String,rect: Rect2) -> Polygon2D:
 var surface:=Polygon2D.new();surface.name=id;surface.texture=surfaces[id];surface.texture_repeat=CanvasItem.TEXTURE_REPEAT_MIRROR
 surface.polygon=PackedVector2Array([rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)])
 var uv:=PackedVector2Array()
 for point: Vector2 in surface.polygon:uv.append(point*surface.texture.get_width()/384.0)
 surface.uv=uv;stage.add_child(surface);return surface
func prop(row: Dictionary,index: int) -> void:
 var bounds: Array=frames.kit[row.kind]
 var sprite:=Sprite2D.new();sprite.name="Scenery_"+str(index);sprite.texture=kit_texture;sprite.region_enabled=true;sprite.region_rect=Rect2(bounds[0],bounds[1],bounds[2],bounds[3]);sprite.centered=false
 sprite.offset=Vector2(-bounds[2]/2.0,-bounds[3]);sprite.scale=Vector2.ONE*float(row.width)/bounds[2];sprite.position=project(Layouts.vector(row.at));sprite.set_meta("kind",row.kind);actors.add_child(sprite)
 if row.kind=="tree":
  var material:=ShaderMaterial.new();material.shader=FOLIAGE;material.set_shader_parameter("height",float(bounds[3]));material.set_shader_parameter("phase",float(index)*1.37);sprite.material=material;trees.append(sprite)
func modular_floor(layout: Dictionary) -> void:
 plane("grass",Rect2(-1920,-1920,3840,2432))
 for rect: Rect2 in [Rect2(-80,-576,160,1088),Rect2(-704,-52,1408,152),Rect2(-352,-154,312,120),Rect2(40,-154,380,120),Rect2(40,294,360,115)]:plane("path",rect)
 water=plane("water",Rect2(-1920,512,3840,1920));water_material=ShaderMaterial.new();water_material.shader=SURFACE;water.material=water_material
 bank=Bank.new();bank.grid_visible=grid_visible;stage.add_child(bank)
 actors=Node2D.new();actors.name="DepthSortedActors";actors.y_sort_enabled=true;stage.add_child(actors)
 for i: int in range(layout.props.size()):prop(layout.props[i],i)
 set_surface_mode(surface_mode)
func rebuild() -> void:
 for child: Node in stage.get_children():stage.remove_child(child);child.queue_free()
 trees.clear();water=null;water_material=null;bank=null
 var layout: Dictionary=Layouts.layout(game.state.location)
 size=Vector2(layout.size[0],layout.size[1]);origin=Vector2(layout.origin[0],layout.origin[1])
 if layout.texture=="modular":modular_floor(layout)
 else:
  backdrop=Sprite2D.new();backdrop.centered=false;var full: Texture2D=texture(Layouts.ROOT+layout.texture+".png")
  var atlas:=AtlasTexture.new();atlas.atlas=full;var half:=Vector2(full.get_width(),full.get_height())/2;atlas.region=Rect2(Vector2(layout.cell[0],layout.cell[1])*half,half);atlas.filter_clip=true;backdrop.texture=atlas
  backdrop.position=-origin;backdrop.scale=size/Vector2(backdrop.texture.get_width(),backdrop.texture.get_height());stage.add_child(backdrop)
  actors=Node2D.new();actors.name="DepthSortedActors";actors.y_sort_enabled=true;stage.add_child(actors)
 for row: Dictionary in layout.npcs:
  actor("NPC_"+row.id,Layouts.vector(row.at),Color(row.color))
  if game.owner_world.comfort.data.world_labels:
   var label:=Label.new();label.text=Guidance.title(row.id,game.locale);label.position=project(Layouts.vector(row.at))+Vector2(-60,6);label.size=Vector2(120,25);label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.add_theme_font_size_override("font_size",15);label.add_theme_color_override("font_outline_color",Color("19382b"));label.add_theme_constant_override("outline_size",4);stage.add_child(label)
 if game.state.location=="trail":
  for id: String in Expedition.ACTIONS:
   if game.state.flags.has(Expedition.ACTIONS[id]):continue
   var marker:=Label.new();marker.name="Obstacle_"+id;marker.text={"cut":"✦","rock-smash":"◆","strength":"●"}[id];marker.position=project(Layouts.vector(layout.points[id]))-Vector2(14,25);marker.add_theme_font_size_override("font_size",34);marker.add_theme_color_override("font_color",Color("699463") if id=="cut" else Color("927e64"));marker.add_theme_color_override("font_outline_color",Color("445c3b"));marker.add_theme_constant_override("outline_size",3);stage.add_child(marker)
 hero=actor("HeroDrawn",game.state.position,Color.WHITE);last_position=game.state.position;stride=0
func set_surface_mode(mode: String) -> void:
 surface_mode=mode if mode in ["water","lava"] else "water"
 if water:
  water.texture=surfaces[surface_mode];water_material.set_shader_parameter("lava",surface_mode=="lava")
func set_grid(value: bool) -> void:
 grid_visible=value
 if bank:bank.grid_visible=value;bank.queue_redraw()
func zoom_for(viewport: Vector2) -> float:
 # Identical pixel density in all locations; never fit each map separately.
 return viewport.y/1080.0*1.15*18.0/game.world.camera.size
func _process(delta: float) -> void:
 if not game.active:return
 visible=not game.battle_panel.visible
 var key: String=game.state.location+JSON.stringify(game.state.flags)+game.locale+str(game.owner_world.comfort.data.world_labels)
 if key!=built_key:built_key=key;rebuild()
 var motion: Vector3=game.state.position-last_position
 var paused: bool=game.modal!=null or game.menu.visible or game.battle_panel.visible
 if motion.length()>.00001 and not paused:
  if absf(motion.x)>absf(motion.z):direction=3 if motion.x>0 else 1
  else:direction=0 if motion.z>0 else 2
  stride+=motion.length()/float(frames.walk_stride_tiles)
  set_frame(hero,direction,[1,0,2,0][int(stride*4)%4])
 else:set_frame(hero,direction,0)
 hero.position=project(game.state.position);last_position=game.state.position
 real_clock+=delta/maxf(Engine.time_scale,.01)
 surface_notice.visible=surface_mode=="lava" and game.state.location=="town"
 var flowing: bool=animations_enabled and not game.owner_world.comfort.data.reduced_motion
 if water_material:water_material.set_shader_parameter("clock",real_clock);water_material.set_shader_parameter("flowing",flowing)
 for tree: Sprite2D in trees:
  var material: ShaderMaterial=tree.material;material.set_shader_parameter("clock",real_clock);material.set_shader_parameter("flowing",flowing)
  var behind: bool=absf(hero.position.x-tree.position.x)<75 and hero.position.y<tree.position.y and hero.position.y>tree.position.y-170
  material.set_shader_parameter("opacity",.72 if behind else 1.0)
 var viewport: Vector2=get_viewport().get_visible_rect().size;var zoom: float=zoom_for(viewport);stage.scale=Vector2.ONE*zoom
 var offset: Vector2=viewport/2-project(game.state.position)*zoom
 for axis: int in range(2):
  if size[axis]*zoom>=viewport[axis]:offset[axis]=clampf(offset[axis],viewport[axis]-(size[axis]-origin[axis])*zoom,origin[axis]*zoom)
  else:offset[axis]=(viewport[axis]-size[axis]*zoom)/2+origin[axis]*zoom
 stage.position=offset
