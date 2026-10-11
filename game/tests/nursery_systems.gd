extends SceneTree
const Adventure=preload("res://scripts/domain/solo_adventure.gd")
const Mon=preload("res://scripts/domain/pokemon.gd")
const Menu=preload("res://scripts/ui/pause_menu.gd")
var checks:=0
var failures:=0
func check(value: bool, message: String) -> void:
	checks+=1
	if not value:failures+=1;push_error(message)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var a:=Adventure.new();a.initialize()
	check(a.nursery.receive(a,"charmander"),"receive gift")
	var uid: int=a.nursery.eggs[0].mon.uid
	var original: Dictionary=a.nursery.eggs[0].mon.duplicate(true)
	check(not a.nursery.receive(a,"charmander") and not a.nursery.receive(a,"charizard"),"no duplicate or invalid gifts")
	check(a.nursery.hatch(a,uid)=="waiting","no early hatch")
	a.nursery.walk(1,true);a.nursery.walk(100);a.nursery.walk(NAN)
	check(a.nursery.eggs[0].remaining==20,"pause, teleport and nonfinite movement ignored")
	for i: int in range(7):a.nursery.walk(1)
	var saved: Dictionary=JSON.parse_string(JSON.stringify(a.snapshot()))
	var b:=Adventure.new()
	check(b.restore(saved) and b.nursery.eggs[0].remaining==13,"JSON save preserves incubation")
	b.exploration.shiny_odds=1
	check(b.nursery.eggs[0].mon==original,"settings and reload do not reroll offspring")
	var invalid: Dictionary=saved.duplicate(true);invalid.nursery.eggs[0].mon.uid=invalid.team[0].uid
	check(not Adventure.validate(invalid),"reject conflicting identity")
	invalid=saved.duplicate(true);invalid.nursery.eggs[0].remaining=-1
	check(not Adventure.validate(invalid),"reject negative incubation")
	invalid=saved.duplicate(true);invalid.nursery.eggs[0].mon.level=2
	check(not Adventure.validate(invalid),"reject tampered egg")
	var old: Dictionary=saved.duplicate(true);old.erase("nursery")
	var legacy:=Adventure.new();check(legacy.restore(old) and legacy.nursery.eggs.is_empty(),"old campaigns remain readable")
	for i: int in range(13):b.nursery.walk(1)
	b.in_battle=true;check(b.nursery.hatch(b,uid)=="blocked","no hatch during combat")
	b.in_battle=false
	check(b.nursery.hatch(b,uid)=="team" and b.find(uid)==original,"hatch exact pre-generated individual")
	check(b.nursery.hatch(b,uid)=="missing" and b.nursery.eggs.is_empty(),"no repeated hatch")
	check(Adventure.validate(b.snapshot()),"valid campaign after hatch")
	var full:=Adventure.new();full.initialize();full.nursery.receive(full,"squirtle")
	var egg_uid: int=full.nursery.eggs[0].mon.uid
	for i: int in range(20):full.nursery.walk(1)
	while full.team.size()+full.boxes.size()<246:full.add(Mon.make("bulbasaur",8,full.next_uid))
	check(full.nursery.hatch(full,egg_uid)=="full" and full.nursery.eggs.size()==1,"full PC retains ready egg")
	full.boxes.pop_back()
	check(full.nursery.hatch(full,egg_uid)=="pc" and full.find(egg_uid).species=="squirtle","retry after capacity available delivers to PC")
	var menu:=Menu.new();menu.adventure=a;root.add_child(menu)
	await process_frame
	menu.open("nursery")
	check(menu.buttons.has("nursery") and menu.title.text.contains("Incubateur"),"incubator navigation visible")
	menu.locale="en";menu.render()
	check(menu.title.text.contains("Incubator"),"English navigation")
	menu.queue_free();await process_frame
	print("NURSERY SYSTEMS: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
