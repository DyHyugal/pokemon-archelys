extends Control
## Actual demo route graph and visited/unlocked states, no final region illustration.
const Chapter=preload("res://scripts/domain/demo_chapter.gd")
var state: RefCounted
var locale: String="fr"
const PLACES={"town":Vector2(.12,.65),"trail":Vector2(.32,.65),"canopy":Vector2(.52,.45),"springs":Vector2(.76,.18),"post":Vector2(.82,.70)}
func _ready() -> void:
 custom_minimum_size=Vector2(480,160);size_flags_horizontal=Control.SIZE_EXPAND_FILL;mouse_filter=Control.MOUSE_FILTER_IGNORE
func _draw() -> void:
 if not state:return
 for id: String in PLACES:
  for next: String in Chapter.ROUTES.get(id,[]):
   if PLACES.has(next):draw_line(PLACES[id]*size,PLACES[next]*size,Color("86a59b"),3)
 for id: String in PLACES:
  var pos: Vector2=PLACES[id]*size;var enabled: bool=Chapter.LOCATIONS.has(id) and state.chapter.accessible(id) and state.chapter.flags.has("started")
  var seen: bool=id in state.chapter.visited if id in Chapter.LOCATIONS else {"town":"isle-port","trail":"isle-jungle"}[id] in state.campaign.adventure.exploration.visited
  var color: Color=Color("ecba57") if id==state.location else (Color("7fae99") if seen else (Color("b1bbc2") if enabled else Color("4a5960")))
  draw_circle(pos,8,color);draw_string(get_theme_default_font(),pos+Vector2(-45,24),Chapter.name_of(id,locale),HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("e6edee"))
