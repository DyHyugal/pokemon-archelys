extends RefCounted
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
const STATS=["hp","attack","defense","special_attack","special_defense","speed"]
const NATURES=["hardy","lonely","brave","adamant","naughty","bold","docile","relaxed","impish","lax","timid","hasty","serious","jolly","naive","modest","mild","quiet","bashful","rash","calm","gentle","sassy","careful","quirky"]
static func integer(value: Variant, low: int, high: int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value)==floorf(float(value)) and value>=low and value<=high
static func experience(level: int, group: String) -> int:
	if level<=1:return 0
	if group=="slow":return int(5*level*level*level/4)
	if group=="fast":return int(4*level*level*level/5)
	if group=="medium-slow":return maxi(0,int(6.0*pow(level,3)/5.0)-15*level*level+100*level-140)
	return level*level*level
static func make(id: String, level: int, uid: int) -> Dictionary:
	var record:=Catalog.species(id)
	var mon: Dictionary={"uid":uid,"species":id,"level":level,"experience":experience(level,record.growth),"iv":[15,15,15,15,15,15],"ev":[0,0,0,0,0,0],"nature":"hardy","ability":record.ability,"item":"","status":"","status_turns":0,"moves":[],"hp":1}
	for learned: Dictionary in record.learnset:
		if int(learned.level)<=level and not mon.moves.any(func(slot: Dictionary):return slot.id==learned.move):
			mon.moves.append({"id":learned.move,"pp":int(Catalog.move(learned.move).pp)})
	while mon.moves.size()>4:mon.moves.pop_front()
	mon.hp=stats(mon).hp
	return mon
static func stats(mon: Dictionary) -> Dictionary:
	var base: Array=mon.get("battle_form",Catalog.species(mon.species)).stats
	var result: Dictionary={}
	var nature: int=NATURES.find(mon.nature)
	for index: int in range(6):
		var raw: int=int((2*int(base[index])+int(mon.iv[index])+int(mon.ev[index])/4)*int(mon.level)/100)
		if index==0:result.hp=raw+int(mon.level)+10
		else:
			var multiplier: float=1.0
			if nature/5 != nature%5:
				if index==[1,2,5,3,4][nature/5]:multiplier=1.1
				if index==[1,2,5,3,4][nature%5]:multiplier=0.9
			result[STATS[index]]=int((raw+5)*multiplier)
	return result
static func hidden_power(mon: Dictionary) -> String:
	var order: Array=[0,1,2,5,3,4]
	var total: int=0
	for i: int in range(6): total+=(int(mon.iv[order[i]])%2)*(1<<i)
	return ["fighting","flying","poison","ground","rock","bug","ghost","steel","fire","water","grass","electric","psychic","ice","dragon","dark"][int(total*15/63)]
static func legal_move(mon: Dictionary, move_id: String) -> bool:
	var id: String=mon.species
	while not id.is_empty():
		if move_id in Catalog.species(id).get("machines",[]):return true
		if Catalog.species(id).learnset.any(func(entry: Dictionary):return entry.move==move_id and entry.level<=mon.level):return true
		id=Catalog.species(id).get("previous","")
	return false
static func validate(mon: Variant) -> bool:
	if not mon is Dictionary or mon.has("battle_form") or not integer(mon.get("uid"),1,1000000) or not mon.get("species") is String or Catalog.species(mon.species).is_empty():return false
	if not integer(mon.get("level"),1,100) or not integer(mon.get("experience"),0,2000000):return false
	if int(mon.level)<int(Catalog.species(mon.species).get("minimum_level",1)):return false
	var minimum:=experience(int(mon.level),Catalog.species(mon.species).growth)
	if mon.experience<minimum or (mon.level<100 and mon.experience>=experience(int(mon.level)+1,Catalog.species(mon.species).growth)):return false
	for field: String in ["iv","ev"]:
		if not mon.get(field) is Array or mon[field].size()!=6:return false
		for value: Variant in mon[field]:
			if not integer(value,0,31 if field=="iv" else 252):return false
	if mon.ev.reduce(func(a: float,b: Variant):return a+float(b),0.0)>510:return false
	if mon.get("nature") not in NATURES or mon.get("ability") not in Catalog.species(mon.species).get("abilities",[Catalog.species(mon.species).ability]):return false
	if mon.has("shiny") and not mon.shiny is bool:return false
	if mon.get("item") not in ["","oran-berry","leftovers","lucky-egg","venusaurite","charizardite-x","charizardite-y","blastoisinite"]:return false
	if mon.get("status") not in ["","burn","poison","paralysis","sleep","freeze"] or not integer(mon.get("status_turns"),0,3):return false
	if not mon.get("moves") is Array or mon.moves.is_empty() or mon.moves.size()>4:return false
	var known: Array=[]
	for slot: Variant in mon.moves:
		if not slot is Dictionary or not slot.get("id") is String or Catalog.move(slot.id).is_empty() or slot.id in known or not legal_move(mon,slot.id):return false
		if not integer(slot.get("pp"),0,int(Catalog.move(slot.id).pp)):return false
		known.append(slot.id)
	return integer(mon.get("hp"),0,stats(mon).hp)
static func heal(mon: Dictionary) -> void:
	mon.hp=stats(mon).hp;mon.status="";mon.status_turns=0
	for slot: Dictionary in mon.moves:slot.pp=int(Catalog.move(slot.id).pp)
static func edit(mon: Dictionary, iv: Array, ev: Array, nature: String) -> bool:
	if iv.size()!=6 or ev.size()!=6 or nature not in NATURES:return false
	for i: int in range(6):
		if not integer(iv[i],0,31) or not integer(ev[i],0,252):return false
	var candidate:=mon.duplicate(true);candidate.iv=iv.duplicate();candidate.ev=ev.duplicate();candidate.nature=nature
	var damage: int=stats(mon).hp-int(mon.hp)
	candidate.hp=0 if mon.hp==0 else maxi(1,stats(candidate).hp-damage)
	if not validate(candidate):return false
	mon.merge(candidate,true);return true
static func evolve(mon: Dictionary, target: String) -> void:
	var damage: int=stats(mon).hp-int(mon.hp)
	mon.species=target;mon.ability=Catalog.species(target).ability
	mon.hp=0 if mon.hp==0 else maxi(1,stats(mon).hp-damage)

static func normalize(mon: Dictionary) -> Dictionary:
	var result:=mon.duplicate(true)
	for key: String in ["uid","level","experience","hp","status_turns"]:result[key]=int(result[key])
	for key: String in ["iv","ev"]:
		for i: int in range(6):result[key][i]=int(result[key][i])
	for slot: Dictionary in result.moves:slot.pp=int(slot.pp)
	return result
