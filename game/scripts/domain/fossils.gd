extends RefCounted
## Original solo acquisition service; restoration site and level are lab fixtures.
const RECIPES={"helix-fossil":"omanyte","dome-fossil":"kabuto","old-amber":"aerodactyl"}
const LEVEL=5
static func available(owner: RefCounted) -> bool:
	return owner.initialized and not owner.in_battle and owner.exploration.location=="center" and owner.exploration.nuzlocke!="on"
static func grant_samples(owner: RefCounted) -> bool:
	if not available(owner) or owner.fossil_samples_received:return false
	for item: String in RECIPES:
		if int(owner.bag.get(item,0))>=999:return false
	for item: String in RECIPES:owner.bag[item]=int(owner.bag.get(item,0))+1
	owner.fossil_samples_received=true
	return true
static func restore_fossil(owner: RefCounted,item: String) -> Dictionary:
	if not available(owner):return {"result":"unavailable"}
	if item not in RECIPES or int(owner.bag.get(item,0))<=0:return {"result":"missing"}
	# Check both independent capacities before generating or changing campaign state.
	if (owner.team.size()>=6 and owner.boxes.size()>=240) or owner.next_uid>=1000000:return {"result":"full"}
	var mon: Dictionary=owner.wild(LEVEL,RECIPES[item])
	mon.origin={"kind":"fossil","item":item,"location":"village"}
	var destination: String=owner.add(mon)
	if destination not in ["team","pc"]:return {"result":"full"}
	owner.bag[item]-=1
	return {"result":destination,"uid":mon.uid,"species":mon.species}
