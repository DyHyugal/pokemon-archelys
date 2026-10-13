extends CanvasLayer
## Fixed drawn backgrounds, independent native 2D actors; no live 3D scenery.
const Layouts=preload("res://scripts/world/drawn_layouts.gd")
const Guidance=preload("res://scripts/domain/demo_guidance.gd")
const Expedition=preload("res://scripts/domain/demo_expedition.gd")
const INK=preload("res://assets/hd2d/ink.gdshader")
var game: Node
var stage: Node2D
var hero: Sprite2D
var backdrop: Sprite2D
var built_key: String=""
var textures: Dictionary={}
var hero_texture: Texture2D
var hero_bounds: Rect2
var hero_ratio: float
var size:=Vector2.ZERO
var origin:=Vector2.ZERO
func _ready() -> void:
 layer=10;process_priority=100
 stage=Node2D.new();stage.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR;add_child(stage)
 hero_texture=load(Layouts.ROOT+"hero.png")
 hero_bounds=hero_texture.get_image().get_used_rect();hero_ratio=95.0/hero_bounds.size.y
 rebuild()
func project(at: Vector3) -> Vector2:return Vector2(at.x*64,at.z*48)
func actor(id: String,at: Vector3,color: Color) -> Sprite2D:
 var sprite:=Sprite2D.new();sprite.name=id;sprite.texture=hero_texture;sprite.region_enabled=true;sprite.region_rect=hero_bounds;sprite.centered=false;sprite.scale=Vector2.ONE*hero_ratio
 sprite.offset=Vector2(-hero_bounds.size.x/2,-hero_bounds.size.y)
 sprite.position=project(at)
 if color!=Color.WHITE:
  var material:=ShaderMaterial.new();material.shader=INK;material.set_shader_parameter("recolor_shirt",true);material.set_shader_parameter("shirt",color);sprite.material=material
 stage.add_child(sprite)
 return sprite
func rebuild() -> void:
 for child: Node in stage.get_children():stage.remove_child(child);child.queue_free()
 var layout: Dictionary=Layouts.layout(game.state.location)
 size=Vector2(layout.size[0],layout.size[1]);origin=Vector2(layout.origin[0],layout.origin[1])
 backdrop=Sprite2D.new();backdrop.centered=false
 var path: String=Layouts.ROOT+layout.texture+".png"
 if not textures.has(path):textures[path]=load(path)
 var texture: Texture2D=textures[path]
 if layout.has("cell"):
  var atlas:=AtlasTexture.new();atlas.atlas=texture;var half:=Vector2(texture.get_width(),texture.get_height())/2
  atlas.region=Rect2(Vector2(layout.cell[0],layout.cell[1])*half,half);atlas.filter_clip=true;backdrop.texture=atlas
 else:backdrop.texture=texture
 backdrop.position=-origin;backdrop.scale=size/Vector2(backdrop.texture.get_width(),backdrop.texture.get_height());stage.add_child(backdrop)
 for row: Dictionary in layout.npcs:
  actor("NPC_"+row.id,Layouts.vector(row.at),Color(row.color))
  if game.owner_world.comfort.data.world_labels:
   var label:=Label.new();label.text=Guidance.title(row.id,game.locale);label.position=project(Layouts.vector(row.at))+Vector2(-60,6);label.size=Vector2(120,25);label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.add_theme_font_size_override("font_size",15);label.add_theme_color_override("font_outline_color",Color("19382b"));label.add_theme_constant_override("outline_size",4);stage.add_child(label)
 if game.state.location=="trail":
  for id: String in Expedition.ACTIONS:
   if game.state.flags.has(Expedition.ACTIONS[id]):continue
   var marker:=Label.new();marker.name="Obstacle_"+id;marker.text={"cut":"✦","rock-smash":"◆","strength":"●"}[id];marker.position=project(Layouts.vector(layout.points[id]))-Vector2(14,25);marker.add_theme_font_size_override("font_size",34);marker.add_theme_color_override("font_color",Color("699463") if id=="cut" else Color("927e64"));marker.add_theme_color_override("font_outline_color",Color("445c3b"));marker.add_theme_constant_override("outline_size",3);stage.add_child(marker)
 hero=actor("HeroDrawn",game.state.position,Color.WHITE)
func _process(_delta: float) -> void:
 if not game.active:return
 visible=not game.battle_panel.visible
 var key: String=game.state.location+JSON.stringify(game.state.flags)+game.locale+str(game.owner_world.comfort.data.world_labels)
 if key!=built_key:built_key=key;rebuild()
 hero.position=project(game.state.position)
 var viewport: Vector2=get_viewport().get_visible_rect().size
 var fit: float=maxf(viewport.x/size.x,viewport.y/size.y)
 var zoom: float=fit*18/game.world.camera.size
 stage.scale=Vector2.ONE*zoom
 var offset: Vector2=viewport/2-project(game.state.position)*zoom
 for axis: int in range(2):
  if size[axis]*zoom>=viewport[axis]:offset[axis]=clampf(offset[axis],viewport[axis]-(size[axis]-origin[axis])*zoom,origin[axis]*zoom)
  else:offset[axis]=(viewport[axis]-size[axis]*zoom)/2+origin[axis]*zoom
 stage.position=offset
