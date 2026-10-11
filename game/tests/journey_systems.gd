extends SceneTree
const Adventure=preload("res://scripts/domain/solo_adventure.gd")
const Journey=preload("res://scripts/domain/journey.gd")
const Mon=preload("res://scripts/domain/pokemon.gd")
const World=preload("res://scripts/domain/world_rules.gd")
var checks:=0
var failures:=0
func check(value: bool,message: String) -> void:
	checks+=1
	if not value:failures+=1;push_error(message)
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var a:=Adventure.new();a.initialize()
	check(not a.travel("trail") and not a.travel("trial"),"gates enforce progression before briefing")
	check(a.journey.begin(a) and a.bag['poke-ball']==25 and a.bag.potion==13,"starting supplies granted exactly once")
	var original: Dictionary=a.snapshot()
	check(not a.journey.begin(a) and a.snapshot()==original,"starting again cannot farm supplies")
	check(not a.travel("trail"),"main scene must complete before departure")
	a.records.scenes['slice-prologue']=true
	check(a.travel("trail") and a.journey.flags.has("trail"),"completed briefing opens persistent trail")
	check(not a.travel("trial"),"trial remains gated until beacon")
	check(a.journey.beacon(a) and not a.journey.beacon(a),"beacon activates once at correct location")
	check(a.travel("trial"),"beacon opens trial")
	check(World.local_walkable(Vector2(0,3),"trail") and not World.local_walkable(Vector2(-7,-2),"trail"),"route collisions align with actual rocks")
	check(not a.journey.won(a,"trainer-1") and not a.journey.flags.has("boss"),"unrelated trainer cannot complete trial")
	a.raise_cap(36);var money: int=a.money
	check(a.journey.won(a,"slice-boss") and a.cap==36 and a.money==money+500,"milestone preserves higher caps and grants one reward")
	original=a.snapshot()
	check(not a.journey.won(a,"slice-boss") and a.snapshot()==original,"repeated win cannot duplicate reward")
	check(not a.journey.finish(a),"ending flag waits for actual scene completion")
	a.records.scenes['slice-ending']=true
	check(a.journey.finish(a) and not a.journey.finish(a),"ending completes exactly once")
	var b:=Adventure.new();check(b.restore(JSON.parse_string(JSON.stringify(a.snapshot()))) and b.journey.flags.has("ending") and b.exploration.location=="trial","JSON restores complete route and location")
	var invalid: Dictionary=a.snapshot();invalid.journey.flags.erase("beacon")
	check(not Adventure.validate(invalid),"out-of-order quest state rejected")
	var old: Dictionary=original.duplicate(true);old.erase("journey");old.exploration.location="village"
	check(b.restore(old) and b.journey.flags.is_empty(),"legacy campaign without journey reads safely")
	print("JOURNEY SYSTEMS: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
