extends RefCounted
## Laboratory incubator. Eggs are separate from the battle party until hatching.
const Mon=preload("res://scripts/domain/pokemon.gd")
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
const GIFTS=["bulbasaur","charmander","squirtle"]
const DISTANCE=20.0
var eggs: Array=[]
var received: Array=[]
func snapshot() -> Dictionary:
	return {"eggs":eggs.duplicate(true),"received":received.duplicate()}
static func validate(value: Variant) -> bool:
	if not value is Dictionary or not value.get("eggs") is Array or not value.get("received") is Array:return false
	if value.eggs.size()>3 or value.received.size()>3:return false
	var gifts: Array=[]
	for id: Variant in value.received:
		if id not in GIFTS or id in gifts:return false
		gifts.append(id)
	var ids: Array=[];var species: Array=[]
	for egg: Variant in value.eggs:
		if not egg is Dictionary or not Mon.validate(egg.get("mon")):return false
		var mon: Dictionary=egg.mon
		if mon.species not in gifts or mon.species in species or mon.uid in ids or mon.level!=1 or mon.item!="" or mon.status!="" or mon.hp!=Mon.stats(mon).hp:return false
		if mon.ev.any(func(v: Variant):return v!=0):return false
		if not egg.get("remaining") is float and not egg.get("remaining") is int:return false
		if not is_finite(float(egg.remaining)) or egg.remaining<0 or egg.remaining>DISTANCE:return false
		ids.append(mon.uid);species.append(mon.species)
	return true
func restore(value: Dictionary) -> void:
	eggs=value.eggs.duplicate(true);received=value.received.duplicate()
	for egg: Dictionary in eggs:egg.mon=Mon.normalize(egg.mon)
func receive(owner: RefCounted, id: String) -> bool:
	if owner.in_battle or id not in GIFTS or id in received:return false
	# Reserve identity immediately. Changing shiny settings or reloading cannot reroll it.
	var mon: Dictionary=Mon.make(id,1,owner.next_uid)
	for i: int in range(6):mon.iv[i]=owner.rng.randi_range(0,31)
	mon.nature=Mon.NATURES[owner.rng.randi_range(0,24)]
	mon.shiny=owner.rng.randi_range(1,owner.exploration.shiny_odds)==1
	mon.hp=Mon.stats(mon).hp
	owner.next_uid+=1;received.append(id)
	eggs.append({"mon":mon,"remaining":DISTANCE});return true
func walk(distance: float, blocked: bool=false) -> void:
	if blocked or not is_finite(distance) or distance<=0 or distance>1.0:return
	for egg: Dictionary in eggs:egg.remaining=maxf(0.0,float(egg.remaining)-distance)
func hatch(owner: RefCounted, uid: int) -> String:
	if owner.in_battle:return "blocked"
	for i: int in range(eggs.size()):
		var egg: Dictionary=eggs[i]
		if int(egg.mon.uid)!=uid:continue
		if egg.remaining>0:return "waiting"
		var target: String=owner.add(egg.mon.duplicate(true))
		if target in ["team","pc"]:eggs.remove_at(i)
		return target
	return "missing"
