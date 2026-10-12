extends SceneTree
const Solo=preload("res://scripts/domain/solo_adventure.gd")
const Island=preload("res://scripts/domain/island.gd")
const Comfort=preload("res://scripts/services/comfort_store.gd")
const Controller=preload("res://scripts/services/controller_input.gd")
var checks:=0
var failures:=0
func check(ok: bool,label: String) -> void:
 checks+=1
 if not ok:failures+=1;push_error(label)
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var a:=Solo.new();a.initialize();var before:=a.snapshot()
 check(not a.purchase_wardrobe("shirt",1) and a.snapshot()==before,"Clothes transaction outside shop is atomic")
 a.island.start(a);a.exploration.location="isle-shop";a.exploration.visited.append("isle-shop")
 before=a.snapshot()
 for invalid: Array in [["skin",1],["shirt",99],["pants",-1],["shirt",0]]:
  check(not a.purchase_wardrobe(invalid[0],invalid[1]) and a.snapshot()==before,"Invalid or unchanged garment cannot charge money")
 a.money=99;before=a.snapshot();check(not a.purchase_wardrobe("shirt",1) and a.snapshot()==before,"Insufficient funds leave all state unchanged")
 a.money=100;a.in_battle=true;before=a.snapshot();check(not a.purchase_wardrobe("shirt",1) and a.snapshot()==before,"Battle blocks wardrobe mutations")
 a.in_battle=false;check(a.purchase_wardrobe("shirt",1) and a.money==0 and a.appearance.shirt==1,"Successful clothing purchase changes only chosen palette and price")
 var copy:=Solo.new();check(copy.restore(a.snapshot()) and copy.appearance.shirt==1 and copy.money==0,"Clothing survives validated campaign restore")
 for id: String in Island.OBSTACLES:
  var data: Dictionary=Island.OBSTACLES[id];a.exploration.location=data.location
  var point:=Vector2(data.position.x,data.position.z)
  before=a.snapshot();check(a.island.blocked(point,data.location) and not a.island.clear_field(a,id) and a.snapshot()==before,"Story-locked obstacle stays blocked "+id)
  a.island.flags.started=true;a.island.flags.checkpoint=true
  if data.flag=="keeper":a.island.flags["relay-west"]=true;a.island.flags["relay-east"]=true;a.island.flags.keeper=true
  a.in_battle=true;check(not a.island.clear_field(a,id),"Battle cannot clear field obstacle "+id);a.in_battle=false
  # Compatibility deliberately absent: fields are narrative capabilities.
  a.team=[preload("res://scripts/domain/pokemon.gd").make("magikarp",8,1)]
  check(a.island.clear_field(a,id) and not a.island.blocked(point,data.location),"Narrative unlock clears obstacle without a compatible Pokemon "+id)
  before=a.snapshot();check(not a.island.clear_field(a,id) and a.snapshot()==before,"Repeated obstacle interaction is idempotent "+id)
  a.island.flags.erase("checkpoint");a.island.flags.erase("keeper");a.island.flags.erase("relay-west");a.island.flags.erase("relay-east");a.island.cleared={}
 var legacy: Dictionary={"flags":{},"collected":{},"caches":{}}
 check(Island.validate(legacy),"Old island snapshot without clearances remains readable")
 var island:=Island.new();island.restore(legacy);check(island.cleared.is_empty(),"Old snapshot migrates to closed obstacles")
 var bad:=legacy.duplicate(true);bad.cleared={"field-strength":true};check(not Island.validate(bad),"Forged clearance without story flag rejected")
 bad.cleared={"invented":true};check(not Island.validate(bad),"Unknown obstacle rejected")
 var path: String="user://tests_atlas_preferences.json";DirAccess.remove_absolute(path)
 var prefs:=Comfort.new(path)
 for pair: Array in [["resolution","1920x1080"],["window_mode","fullscreen"],["fps_limit",60],["vsync",false],["combat_animations",false],["reduced_motion",true],["world_labels",false]]:
  check(prefs.set_option(pair[0],pair[1])==OK and Comfort.new(path).data[pair[0]]==pair[1],"Display/comfort option persists "+pair[0])
 var file_before:=FileAccess.get_file_as_string(path)
 for pair: Array in [["resolution","99999x99999"],["fps_limit",17],["window_mode","exclusive"],["reduced_motion",1],["vsync","true"]]:
  check(prefs.set_option(pair[0],pair[1])==ERR_INVALID_DATA and FileAccess.get_file_as_string(path)==file_before,"Invalid option cannot overwrite local preferences")
 var old: Dictionary={"keys":{},"master":75,"music":60,"effects":40,"text_size":20,"theme":"light"}
 var file:=FileAccess.open(path,FileAccess.WRITE);file.store_string(JSON.stringify(old));file.close()
 var migrated:=Comfort.new(path)
 check(migrated.data.resolution=="1280x720" and migrated.data.window_mode=="windowed" and migrated.data.music==60 and migrated.data.theme=="light","Preference migration keeps older audio/theme and display defaults")
 check(Controller.stick(Vector2(0.2,0.0))==Vector2.ZERO and Controller.stick(Vector2(0.3,0)).x>0 and Controller.stick(Vector2(1,1)).length()<=1.0001,"Analog deadzone prevents drift and caps diagonal movement")
 print("ATLAS SERVICES: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
