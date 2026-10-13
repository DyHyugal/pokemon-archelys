extends CanvasLayer
## Static drawn portraits and 2D battle platforms; rules remain in Showdown.
const IDS=["bulbasaur","charmander","squirtle","rattata","pikachu","magikarp"]
var game: Node
var enemy: TextureRect
var player: TextureRect
var enemy_name: Label
var player_name: Label
var sheet: Texture2D
class Field extends Control:
 func _draw() -> void:
  for i: int in range(32):
   draw_rect(Rect2(0,size.y*i/32,size.x,size.y/32+1),Color("e3eddb").lerp(Color("88bbaa"),i/31.0))
  for row: Array in [[.25,.66,.20,.045],[.73,.52,.16,.032]]:
   draw_set_transform(Vector2(size.x*row[0],size.y*row[1]),0,Vector2(size.x*row[2],size.y*row[3]))
   draw_circle(Vector2.ZERO,1,Color("6eaa88"));draw_circle(Vector2(0,-.10),.94,Color("b8d3a0"));draw_set_transform(Vector2.ZERO)
func _ready() -> void:
 layer=44;sheet=load("res://assets/drawn/pokemon.png")
 var field:=Field.new();field.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(field)
 enemy=TextureRect.new();player=TextureRect.new()
 player.flip_h=true
 for picture: TextureRect in [enemy,player]:picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;add_child(picture)
 enemy_name=Label.new();player_name=Label.new()
 for label: Label in [enemy_name,player_name]:label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.add_theme_font_size_override("font_size",30);add_child(label)
func portrait(picture: TextureRect,label: Label,id: String) -> void:
 var index: int=IDS.find(id)
 # Never pretend a missing/evolved species is represented by its pre-evolution.
 picture.visible=index>=0;label.visible=index<0
 if index<0:label.text=preload("res://scripts/domain/pokemon_catalog.gd").name_of(id,game.locale);return
 var atlas:=AtlasTexture.new();atlas.atlas=sheet
 var cell:=Vector2(sheet.get_width()/3.0,sheet.get_height()/2.0)
 # The lower-row ears protrude slightly above the uniform cell boundary.
 # Keep them without importing the small lower-row pixels into top portraits.
 var top: float=10 if index<3 else -22
 var bottom: float=20 if index<3 else 10
 atlas.region=Rect2(Vector2(index%3,index/3)*cell+Vector2(8,top),cell-Vector2(16,top+bottom));atlas.filter_clip=true;picture.texture=atlas
func _process(_delta: float) -> void:
 visible=game.active and game.battle_panel.visible
 if not visible or not game.battle:return
 var screen: Vector2=get_viewport().get_visible_rect().size
 var side: float=minf(screen.y*.30,screen.x*.23)
 player.size=Vector2.ONE*side;player.position=Vector2(screen.x*.25-side/2,screen.y*.66-side)
 enemy.size=Vector2.ONE*side;enemy.position=Vector2(screen.x*.73-side/2,screen.y*.52-side)
 enemy_name.position=enemy.position;enemy_name.size=enemy.size;player_name.position=player.position;player_name.size=player.size
 portrait(player,player_name,game.battle.current(0).species);portrait(enemy,enemy_name,game.battle.current(1).species)
