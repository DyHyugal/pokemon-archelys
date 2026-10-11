extends SceneTree
const Appearance=preload("res://scripts/domain/appearance.gd")
const Adventure=preload("res://scripts/domain/solo_adventure.gd")
const Comfort=preload("res://scripts/services/comfort_store.gd")
const InterfaceStyle=preload("res://scripts/ui/interface_style.gd")
const PhotoMode=preload("res://scripts/ui/photo_mode.gd")
var checks:=0
var failures:=0
func check(value: bool,message: String) -> void:
 checks+=1
 if not value:failures+=1;push_error(message)
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var a:=Adventure.new();a.initialize();var before: Dictionary=a.snapshot()
 check(a.set_appearance("skin",3) and a.set_appearance("style",2) and a.set_appearance("face",1),"Valid independent appearance selections")
 var restored:=Adventure.new();check(restored.restore(JSON.parse_string(JSON.stringify(a.snapshot()))) and restored.appearance==a.appearance,"Campaign JSON preserves appearance")
 var legacy: Dictionary=a.snapshot();legacy.erase("appearance")
 check(restored.restore(legacy) and restored.appearance==Appearance.DEFAULT,"Legacy campaign supplies initial appearance")
 check(not a.set_appearance("style",99) and not a.set_appearance("unknown",1),"Invalid selection rejected")
 var invalid: Dictionary=a.snapshot();invalid.appearance.skin=0.5;check(not Adventure.validate(invalid),"Fractional appearance invalidates corrupt save")
 invalid=a.snapshot();invalid.appearance.erase("hair");check(not Adventure.validate(invalid),"Incomplete selection rejected")
 a.in_battle=true;check(not a.set_appearance("skin",0),"Appearance locked in battle");a.in_battle=false
 check(a.team==before.team and a.bag==before.bag and a.cap==before.cap,"Cosmetics preserve combat and economy")
 var path: String="user://tests_presentation_comfort.json";DirAccess.remove_absolute(path)
 var prefs:=Comfort.new(path);var original: Dictionary=prefs.data.duplicate(true);original.erase("theme")
 var f:=FileAccess.open(path,FileAccess.WRITE);f.store_string(JSON.stringify(original));f.close()
 prefs=Comfort.new(path);check(prefs.data.theme=="dark" and prefs.data.keys==original.keys,"Legacy comfort settings merge theme default")
 check(prefs.set_theme("contrast")==OK and Comfort.new(path).data.theme=="contrast","Palette persists outside campaign")
 var content: String=FileAccess.get_file_as_string(path);check(prefs.set_theme("unrecognized")==ERR_INVALID_DATA and FileAccess.get_file_as_string(path)==content,"Invalid palette cannot replace settings")
 var theme:=Theme.new();InterfaceStyle.apply(theme,"light")
 check((theme.get_stylebox("panel","PanelContainer").bg_color.srgb_to_linear().get_luminance()+0.05)/(theme.get_color("font_color","Label").srgb_to_linear().get_luminance()+0.05)>7,"Light theme has actual dark text/light panels")
 InterfaceStyle.apply(theme,"contrast")
 check(theme.get_color("font_color","Label")==Color.WHITE and theme.get_stylebox("focus","Button").border_color==Color("ffdc49"),"High contrast has visible focus and white text")
 var photo:=PhotoMode.new();root.add_child(photo);photo.destination="user://tests_photos"
 var image:=Image.create(48,32,false,Image.FORMAT_RGBA8);image.fill(Color("58a090"))
 check(photo.write_png(image)==OK,"PNG export writes image on disk")
 var first: String=photo.last_file;var decoded:=Image.load_from_file(first)
 check(decoded!=null and decoded.get_size()==Vector2i(48,32) and decoded.get_pixel(10,10).is_equal_approx(Color("58a090")),"PNG is readable and preserves pixels/dimensions")
 check(photo.write_png(image)==OK and photo.last_file!=first and FileAccess.file_exists(first),"Repeated photo preserves prior file")
 check(photo.write_png(Image.new())==ERR_INVALID_DATA,"Empty capture refused")
 DirAccess.remove_absolute(first);DirAccess.remove_absolute(photo.last_file);photo.queue_free();await process_frame
 print("PRESENTATION SYSTEMS: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
