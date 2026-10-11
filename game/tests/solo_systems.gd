extends SceneTree
const World=preload("res://scripts/domain/world_rules.gd")
const Campaign=preload("res://scripts/domain/campaign.gd")
const Progress=preload("res://scripts/domain/laboratory_progress.gd")
const Preferences=preload("res://scripts/services/preferences_store.gd")
const Store=preload("res://scripts/services/save_store.gd")
var checks: int=0
var failures: int=0
func check(value: bool, label: String) -> void:
	checks+=1
	if not value:
		failures+=1;push_error(label)
func _initialize() -> void:
	check(not World.walkable(Vector2(6,6)) and not World.walkable(Vector2(-3,-3)) and not World.walkable(Vector2(3,3)) and World.walkable(Vector2.ZERO),"Interactable objects block movement while paths remain accessible")
	check(World.can_step(Vector2(3,3),Vector2(3.1,3)) and not World.can_step(Vector2(3.6,3),Vector2(3.2,3)),"Legacy position inside new object can exit, but outside movement cannot enter it")
	var progress:=Progress.new()
	check(progress.complete("crate") and progress.tokens==1,"First crate grants one token")
	check(not progress.complete("crate") and progress.tokens==1,"Repeated interaction cannot duplicate reward")
	check(not progress.complete("unknown"),"Unknown objective rejected")
	var bad:=progress.snapshot();bad.tokens=2
	check(not Progress.validate(bad),"Invalid inventory amount rejected")
	var restored:=Progress.new()
	check(restored.restore(progress.snapshot()) and restored.completed.has("crate") and restored.tokens==1,"Inventory and objectives round-trip")
	check(not restored.restore(bad) and restored.tokens==1,"Invalid restore preserves state")
	var old:=Campaign.new();old.add_player(1,"Test");old.players[1].position=[2.0,0.0,4.0]
	var v1:=old.snapshot();v1.schema=1;v1.erase("laboratory")
	var current:=Campaign.new()
	check(current.restore(v1) and current.players[1].position==[2.0,0.0,4.0] and current.laboratory.tokens==0,"Old save migrates in memory without losing position")
	current.laboratory.complete("crate")
	var copy:=Campaign.new()
	check(copy.restore(current.snapshot()) and copy.laboratory.tokens==1,"New save persists laboratory state")
	var invalid:=current.snapshot();invalid.laboratory.tokens=0
	check(not copy.restore(invalid) and copy.laboratory.tokens==1,"Inconsistent save rejected atomically")
	var prefs_path:="user://tests_preferences.json"
	check(Preferences.write({"language":"en","camera_size":13.5},prefs_path)==OK,"Preferences write")
	check(Preferences.read(prefs_path).language=="en" and Preferences.read(prefs_path).camera_size==13.5,"Fresh read restores language and camera")
	check(Preferences.write({"language":"bad","camera_size":INF},prefs_path)==ERR_INVALID_DATA and Preferences.read(prefs_path).language=="en","Invalid preference update cannot replace valid data")
	var file:=FileAccess.open(prefs_path,FileAccess.WRITE);file.store_string("{bad");file.close()
	check(Preferences.read(prefs_path)==Preferences.DEFAULTS,"Corrupted preferences recover to defaults")
	var path:="user://tests_migration.json"
	for suffix:String in ["",".backup",".v1.backup",".tmp"]:DirAccess.remove_absolute(path+suffix)
	Store.write_snapshot(path,v1)
	var original:=FileAccess.get_file_as_string(path)
	check(Store.write_snapshot(path,current.snapshot())==OK and FileAccess.get_file_as_string(path+".v1.backup")==original,"Migration preserves original v1 bytes")
	current.laboratory.complete("sign")
	check(Store.write_snapshot(path,current.snapshot())==OK and FileAccess.get_file_as_string(path+".v1.backup")==original,"Later saves preserve migration backup")
	invalid=current.snapshot();invalid.schema=6
	check(not Campaign.validate(invalid),"Future unknown schema rejected")
	print("SOLO SYSTEMS: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
