extends SceneTree
const Adventure=preload("res://scripts/domain/solo_adventure.gd")
const Fossils=preload("res://scripts/domain/fossils.gd")
const Mon=preload("res://scripts/domain/pokemon.gd")
const Menu=preload("res://scripts/ui/pause_menu.gd")
const Adapter=preload("res://scripts/services/showdown_battle.gd")
var checks:=0
var failures:=0
func check(value: bool,message: String) -> void:
	checks+=1
	if not value:failures+=1;push_error(message)
func press(menu: CanvasLayer,text: String) -> bool:
	for node: Node in menu.body.get_children():
		if node is Button and node.text.contains(text):
			if node.disabled:return false
			node.pressed.emit();return true
	return false
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var a:=Adventure.new();a.initialize()
	var original: Dictionary=a.snapshot()
	check(not Fossils.grant_samples(a) and a.snapshot()==original,"no restoration or samples outside center")
	a.exploration.enter("center")
	check(Fossils.grant_samples(a) and a.bag['helix-fossil']==1,"grant sample trio once")
	original=a.snapshot()
	check(not Fossils.grant_samples(a) and a.snapshot()==original,"sample gift never repeats")
	check(not a.records.seen.has("omanyte"),"fossil item does not discover species")
	check(Fossils.restore_fossil(a,"invalid").result=="missing" and a.snapshot()==original,"unknown item is atomic rejection")
	a.in_battle=true
	check(Fossils.restore_fossil(a,"helix-fossil").result=="unavailable" and a.snapshot()==original,"no restoration during battle")
	a.in_battle=false
	var restored: Dictionary=Fossils.restore_fossil(a,"helix-fossil")
	check(restored.result=="team" and a.bag['helix-fossil']==0,"one fossil consumed after actual delivery")
	var mon: Dictionary=a.find(restored.uid)
	check(mon.species=="omanyte" and mon.level==5 and mon.hp==Mon.stats(mon).hp and Mon.validate(mon),"legal healthy specimen with battle moves")
	check(mon.origin.location=="village" and a.records.caught.has("omanyte"),"restoration origin and dex recorded")
	original=a.snapshot()
	check(Fossils.restore_fossil(a,"helix-fossil").result=="missing" and a.snapshot()==original,"empty bag cannot duplicate specimen")
	var saved: Dictionary=JSON.parse_string(JSON.stringify(a.snapshot()));var loaded:=Adventure.new()
	check(loaded.restore(saved) and loaded.fossil_samples_received and loaded.find(restored.uid).origin==mon.origin,"JSON preserves consumed fossil, sample flag and origin")
	check(not Fossils.grant_samples(loaded),"reload cannot regrant samples")
	var legacy: Dictionary=saved.duplicate(true);legacy.erase("fossil_samples_received")
	check(loaded.restore(legacy) and not loaded.fossil_samples_received,"old campaigns read with absent flag")
	var invalid: Dictionary=saved.duplicate(true);invalid.fossil_samples_received=1
	check(not Adventure.validate(invalid),"malformed sample flag rejected")
	var full:=Adventure.new();full.initialize();full.exploration.enter("center");Fossils.grant_samples(full)
	while full.team.size()+full.boxes.size()<246:full.add(Mon.make("bulbasaur",8,full.next_uid))
	original=full.snapshot()
	check(Fossils.restore_fossil(full,"dome-fossil").result=="full" and full.snapshot()==original,"full party and PC preserve all resources and UID")
	full.boxes.pop_back();restored=Fossils.restore_fossil(full,"dome-fossil")
	check(restored.result=="pc" and full.find(restored.uid).species=="kabuto" and full.bag['dome-fossil']==0,"retry delivers to PC and consumes once")
	full.exploration.nuzlocke="on";original=full.snapshot()
	check(Fossils.restore_fossil(full,"old-amber").result=="unavailable" and full.snapshot()==original,"deferred challenge acquisition does not bypass quotas")
	var evolving: Dictionary=Mon.make("omanyte",39,900)
	Mon.evolve(evolving,"omastar");evolving.level=40;evolving.experience=Mon.experience(40,"medium");Mon.heal(evolving)
	# Growth group and threshold must come from the imported catalogue.
	evolving.experience=Mon.experience(40,Adventure.Catalog.species("omastar").growth)
	check(Mon.validate(evolving) and Adventure.Catalog.legal_species("kabuto",40)=="kabutops","both fossil families evolve legally at level40")
	var ui_owner:=Adventure.new();ui_owner.initialize();ui_owner.exploration.enter("center")
	var menu:=Menu.new();menu.adventure=ui_owner;root.add_child(menu);await process_frame
	menu.open("services")
	check(press(menu,"trois fossiles") and ui_owner.bag['old-amber']==1,"actual service button grants samples")
	check(press(menu,"Vieil Ambre") and ui_owner.team[-1].species=="aerodactyl","actual restoration button produces Aerodactyl")
	menu.locale="en";menu.render()
	check(press(menu,"Helix Fossil") and ui_owner.team[-1].species=="omanyte","English restoration controls work")
	menu.queue_free();await process_frame
	ui_owner.team=[ui_owner.team[-1]]
	var battle:=Adapter.new()
	check(battle.begin(ui_owner,[Mon.make("rattata",5,900000)]),"restored specimen starts actual Showdown battle")
	var deadline: int=Time.get_ticks_msec()+12000
	while battle.busy and Time.get_ticks_msec()<deadline:await create_timer(0.01).timeout
	check(not battle.busy and battle.active and ui_owner.team[0].species=="omanyte","Showdown accepts restored stats, moves and ability")
	battle.finish("flee")
	print("FOSSIL SYSTEMS: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
