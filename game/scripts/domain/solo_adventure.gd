extends RefCounted
const Mon=preload("res://scripts/domain/pokemon.gd")
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
const Exploration=preload("res://scripts/domain/exploration.gd")
const Records=preload("res://scripts/domain/journey_records.gd")
const Journey=preload("res://scripts/domain/journey.gd")
const Appearance=preload("res://scripts/domain/appearance.gd")
var appearance: Dictionary=Appearance.DEFAULT.duplicate()
var journey:=Journey.new()
const Nursery=preload("res://scripts/domain/nursery.gd")
var nursery:=Nursery.new()
var records:=Records.new()
var exploration:=Exploration.new()
var team: Array=[]
const Storage=preload("res://scripts/domain/storage.gd")
var storage_slots: Dictionary={}
var boxes: Array=[]
var bag: Dictionary={}
var next_uid: int=1
var cap: int=10
var money: int=3000
var victories: Dictionary={}
var pending: Array=[]
var fossil_samples_received: bool=false
var initialized: bool=false
var in_battle: bool=false
var encounter_steps: float=0.0
var rng:=RandomNumberGenerator.new()
func _init() -> void:
	rng.randomize()
func initialize() -> void:
	if initialized:return
	initialized=true
	bag={"poke-ball":20,"great-ball":5,"potion":10,"antidote":5,"paralyze-heal":5,"oran-berry":3,"leftovers":1,"lucky-egg":1,"thunder-stone":1}
	for id: String in ["bulbasaur","charmander","squirtle"]:add(Mon.make(id,8,next_uid))
func add(mon: Dictionary) -> String:
	if not Mon.validate(mon) or team.size()+boxes.size()>=246:return "full"
	for owned: Dictionary in team+boxes:
		if int(owned.uid)==int(mon.uid):return "duplicate"
	records.observe(mon.species,true)
	next_uid=maxi(next_uid,int(mon.uid)+1)
	if team.size()<6:team.append(mon);return "team"
	boxes.append(mon);_sync_storage();return "pc"
func find(uid: int) -> Dictionary:
	for mon: Dictionary in team+boxes:
		if int(mon.uid)==uid:return mon
	return {}
func reorder(index: int, target: int) -> bool:
	if in_battle:return false
	if index<0 or target<0 or index>=team.size() or target>=team.size():return false
	var mon: Dictionary=team[index];team[index]=team[target];team[target]=mon;return true
func deposit(index: int) -> bool:
	if in_battle:return false
	if index<0 or index>=team.size() or team.size()<=1 or boxes.size()>=240:return false
	if team[index].hp>0 and not team.any(func(mon: Dictionary):return mon!=team[index] and mon.hp>0):return false
	boxes.append(team.pop_at(index));_sync_storage();return true
func withdraw(index: int) -> bool:
	if in_battle:return false
	if index<0 or index>=boxes.size() or team.size()>=6:return false
	var mon: Dictionary=boxes.pop_at(index);storage_slots.erase(str(int(mon.uid)));team.append(mon);_sync_storage();return true
func equip(uid: int, item: String) -> bool:
	if in_battle:return false
	var mon:=find(uid)
	if mon.is_empty() or item not in ["","oran-berry","leftovers","lucky-egg","venusaurite","charizardite-x","charizardite-y","blastoisinite"]:return false
	if mon.item==item:return true
	if item!="" and int(bag.get(item,0))<=0:return false
	if item!="":bag[item]-=1
	if mon.item!="":bag[mon.item]=int(bag.get(mon.item,0))+1
	mon.item=item;return true
func use(item: String, uid: int) -> bool:
	if in_battle and not exploration.bag_healing:return false
	if in_battle and item in ["thunder-stone","fire-stone"]:return false
	var mon:=find(uid)
	if mon.is_empty() or not exploration.can_heal(mon) or int(bag.get(item,0))<=0 or mon.hp<=0:return false
	if item=="potion":
		if mon.hp==Mon.stats(mon).hp:return false
		mon.hp=mini(Mon.stats(mon).hp,int(mon.hp)+20)
	elif item=="antidote" and mon.status=="poison":mon.status="";mon.status_turns=0
	elif item=="paralyze-heal" and mon.status=="paralysis":mon.status="";mon.status_turns=0
	elif item in ["thunder-stone","fire-stone"] and Catalog.species(mon.species).get("evolution",{}).get("item")==item:
		Mon.evolve(mon,Catalog.species(mon.species).evolution.target)
		records.observe(mon.species,true)
	else:return false
	bag[item]-=1;return true
func edit(uid: int, iv: Array, ev: Array, nature: String) -> bool:
	if in_battle:return false
	var mon:=find(uid)
	return not mon.is_empty() and Mon.edit(mon,iv,ev,nature)
func heal_team() -> void:
	for mon: Dictionary in team:
		if exploration.can_heal(mon):Mon.heal(mon)
func raise_cap(value: int) -> void:
	cap=maxi(cap,clampi(value,1,100))
func gain_experience(uid: int, amount: int) -> Array:
	var events: Array=[]
	var mon:=find(uid)
	if mon.is_empty() or mon.hp<=0 or amount<=0:return events
	var ceiling:=maxi(cap if exploration.cap_enabled else 100,int(mon.level))
	var group: String=Catalog.species(mon.species).growth
	var before: int=mon.level
	if before>=ceiling:return ["cap"]
	var maximum:=Mon.experience(ceiling+1,group)-1 if ceiling<100 else Mon.experience(100,group)
	mon.experience=mini(maximum,int(mon.experience)+amount*exploration.exp_multiplier)
	while mon.level<ceiling and mon.experience>=Mon.experience(int(mon.level)+1,group):
		var previous_hp: int=Mon.stats(mon).hp
		mon.level+=1;mon.hp+=Mon.stats(mon).hp-previous_hp
		events.append("level:%d" % mon.level)
		for learned: Dictionary in Catalog.species(mon.species).learnset:
			if int(learned.level)==int(mon.level) and not mon.moves.any(func(slot: Dictionary):return slot.id==learned.move):
				if not pending.any(func(choice: Dictionary):return choice.uid==uid and choice.kind=="move" and choice.target==learned.move):
					pending.append({"kind":"move","uid":uid,"target":learned.move})
	var evolution: Dictionary=Catalog.species(mon.species).get("evolution",{})
	if evolution.has("level") and mon.level>=evolution.level and mon.level>before:
		if not pending.any(func(choice: Dictionary):return choice.uid==uid and choice.kind=="evolution"):
			pending.append({"kind":"evolution","uid":uid,"target":evolution.target})
	return events
func resolve_choice(index: int, slot: int) -> bool:
	if in_battle:return false
	if index<0 or index>=pending.size():return false
	var choice: Dictionary=pending[index];var mon:=find(int(choice.uid))
	if mon.is_empty():return false
	if choice.kind=="evolution":
		if slot==0:
			Mon.evolve(mon,choice.target)
			records.observe(mon.species,true)
			var next: Dictionary=Catalog.species(mon.species).get("evolution",{})
			if next.has("level") and mon.level>=next.level:pending.append({"kind":"evolution","uid":mon.uid,"target":next.target})
		elif slot!=-1:return false
	else:
		if slot>=0:
			if mon.moves.any(func(entry: Dictionary):return entry.id==choice.target):return false
			if slot>mon.moves.size() or slot>=4:return false
			var move: Dictionary={"id":choice.target,"pp":int(Catalog.move(choice.target).pp)}
			if slot==mon.moves.size():mon.moves.append(move)
			else:mon.moves[slot]=move
		elif slot!=-1:return false
	pending.remove_at(index);return true
func wild(level: int=-1, species_id: String="") -> Dictionary:
	if level<0:level=rng.randi_range(maxi(2,cap-4),cap)
	if species_id.is_empty():species_id=Catalog.WILD_BASES[rng.randi_range(0,Catalog.WILD_BASES.size()-1)]
	var mon:=Mon.make(Catalog.legal_species(species_id,level),level,next_uid)
	for i: int in range(6):mon.iv[i]=rng.randi_range(0,31)
	mon.shiny=rng.randi_range(1,exploration.shiny_odds)==1
	mon.nature=Mon.NATURES[rng.randi_range(0,24)];mon.hp=Mon.stats(mon).hp
	return mon
func snapshot() -> Dictionary:
	_sync_storage()
	return {"storage_slots":storage_slots.duplicate(),"appearance":appearance.duplicate(),"journey":journey.snapshot(),"fossil_samples_received":fossil_samples_received,"nursery":nursery.snapshot(),"records":records.snapshot(),"team":team.duplicate(true),"boxes":boxes.duplicate(true),"bag":bag.duplicate(true),"next_uid":next_uid,"cap":cap,"money":money,"victories":victories.duplicate(true),"pending":pending.duplicate(true),"initialized":initialized,"exploration":exploration.snapshot()}
static func validate(value: Variant) -> bool:
	if not value is Dictionary:return false
	if value.has("journey") and not Journey.validate(value.journey):return false
	if value.has("appearance") and not Appearance.validate(value.appearance):return false
	if value.has("fossil_samples_received") and not value.fossil_samples_received is bool:return false
	if value.has("nursery") and not Nursery.validate(value.nursery):return false
	if value.has("records") and not Records.validate(value.records):return false
	if value.has("exploration") and not Exploration.validate(value.exploration):return false
	if not value.get("initialized") is bool or not value.get("team") is Array or not value.get("boxes") is Array or not value.get("bag") is Dictionary or not value.get("pending") is Array or not value.get("victories") is Dictionary:return false
	if value.team.size()>6 or value.boxes.size()>240 or not Mon.integer(value.get("next_uid"),1,1000000) or not Mon.integer(value.get("cap"),10,100) or not Mon.integer(value.get("money"),0,999999):return false
	if value.initialized and value.team.is_empty():return false
	if not value.initialized and (not value.team.is_empty() or not value.boxes.is_empty() or not value.bag.is_empty() or not value.pending.is_empty() or not value.victories.is_empty()):return false
	var ids: Array=[]
	for mon: Variant in value.team+value.boxes:
		if not Mon.validate(mon) or mon.uid in ids or mon.uid>=value.next_uid:return false
		ids.append(mon.uid)
	if value.has("storage_slots") and not Storage.valid(value.storage_slots,value.boxes):return false
	var egg_ids: Array=[]
	if value.has("nursery"):
		for egg: Dictionary in value.nursery.eggs:
			if egg.mon.uid in ids or egg.mon.uid in egg_ids or egg.mon.uid>=value.next_uid:return false
			egg_ids.append(egg.mon.uid)
	for key: Variant in value.bag:
		if not key is String or not Catalog.data().items.has(key) or not Mon.integer(value.bag[key],0,999):return false
	for key: Variant in value.victories:
		if key not in ["trainer-1","trainer-2"] or value.victories[key]!=true:return false
	if value.has("exploration"):
		for uid: Variant in value.exploration.dead:
			if uid not in ids:return false
			for mon: Dictionary in value.team+value.boxes:
				if value.exploration.nuzlocke=="on" and mon.uid==uid and mon.hp!=0:return false
	var choices: Array=[]
	if value.pending.size()>100:return false
	for choice: Variant in value.pending:
		if not choice is Dictionary or not Mon.integer(choice.get("uid"),1,1000000) or choice.uid not in ids or choice.get("kind") not in ["move","evolution"] or not choice.get("target") is String:return false
		var key: String=str(choice.uid)+choice.kind+choice.target
		if key in choices:return false
		choices.append(key)
		var mon: Dictionary={}
		for entry: Dictionary in value.team+value.boxes:
			if entry.uid==choice.uid:mon=entry
		if choice.kind=="move":
			if not Mon.legal_move(mon,choice.target):return false
		else:
			var evolution: Dictionary=Catalog.species(mon.species).get("evolution",{})
			if evolution.get("target")!=choice.target or not evolution.has("level") or evolution.level>mon.level:return false
	return true
func restore(value: Dictionary) -> bool:
	if not validate(value):return false
	appearance=Appearance.normalized(value.appearance) if value.has("appearance") else Appearance.DEFAULT.duplicate()
	journey=Journey.new()
	if value.has("journey"):journey.restore(value.journey)
	fossil_samples_received=value.get("fossil_samples_received",false)
	nursery=Nursery.new()
	if value.has("nursery"):nursery.restore(value.nursery)
	records=Records.new()
	if value.has("records"):records.restore(value.records)
	exploration=Exploration.new()
	if value.has("exploration"):exploration.restore(value.exploration)
	team=[];boxes=[];bag={}
	for mon: Dictionary in value.team:team.append(Mon.normalize(mon))
	for mon: Dictionary in value.boxes:boxes.append(Mon.normalize(mon))
	storage_slots=Storage.reconcile(boxes,value.get("storage_slots",{}))
	for mon: Dictionary in team+boxes:records.observe(mon.species,true)
	for key: String in value.bag:bag[key]=int(value.bag[key])
	next_uid=int(value.next_uid);cap=int(value.cap);money=int(value.money);victories=value.victories.duplicate(true);pending=value.pending.duplicate(true);initialized=value.initialized
	for choice: Dictionary in pending:choice.uid=int(choice.uid)
	return true
func relearn(uid: int, move_id: String, slot: int) -> bool:
	if in_battle:return false
	var mon:=find(uid)
	if mon.is_empty() or slot<0 or slot>mon.moves.size() or slot>=4 or mon.moves.any(func(entry: Dictionary):return entry.id==move_id):return false
	var id: String=mon.species;var legal: bool=false
	while not id.is_empty():
		if Catalog.species(id).learnset.any(func(entry: Dictionary):return entry.move==move_id and entry.level<=mon.level):legal=true
		id=Catalog.species(id).get("previous","")
	if not legal:return false
	var learned: Dictionary={"id":move_id,"pp":int(Catalog.move(move_id).pp)}
	if slot==mon.moves.size():mon.moves.append(learned)
	else:mon.moves[slot]=learned
	return true

func purchase(item: String, quantity: int, sell: bool=false) -> bool:
	if in_battle or item not in Exploration.PRICES or quantity<1 or quantity>99:return false
	var count: int=int(bag.get(item,0))
	var price: int=int(Exploration.PRICES[item])
	if sell:
		if quantity>count or money+price/2*quantity>999999:return false
		bag[item]=count-quantity;money+=price/2*quantity
	else:
		if money<price*quantity or count+quantity>999:return false
		money-=price*quantity;bag[item]=count+quantity
	return true
func travel(target: String, flight: bool=false) -> bool:
	if in_battle:return false
	if flight and (target not in exploration.visited or target not in ["village","cove","district"] or not exploration.field_unlocked("fly",victories)):return false
	if not journey.can_enter(self,target):return false
	if not exploration.enter(target):return false
	journey.entered(target);return true
func teach_machine(uid: int, move_id: String, slot: int) -> bool:
	if in_battle:return false
	var mon:=find(uid)
	if mon.is_empty() or move_id not in Catalog.species(mon.species).get("machines",[]) or slot<0 or slot>=4 or slot>mon.moves.size():return false
	if mon.moves.any(func(entry: Dictionary):return entry.id==move_id):return false
	var learned: Dictionary={"id":move_id,"pp":int(Catalog.move(move_id).pp)}
	if slot==mon.moves.size():mon.moves.append(learned)
	else:mon.moves[slot]=learned
	return true
func set_ability(uid: int, ability: String) -> bool:
	if in_battle:return false
	var mon:=find(uid)
	if mon.is_empty() or ability not in Catalog.species(mon.species).get("abilities",[]):return false
	mon.ability=ability;return true

func grant_mega_kit() -> bool:
	# Explicit laboratory helper. Preserve existing individuals and held items.
	if in_battle or exploration.nuzlocke=="on":return false
	raise_cap(36)
	for pair: Array in [["venusaur","venusaurite"],["charizard","charizardite-y"],["blastoise","blastoisinite"]]:
		if not (team+boxes).any(func(mon: Dictionary):return mon.species==pair[0]):
			if team.size()+boxes.size()<246:add(Mon.make(pair[0],36,next_uid))
		for mon: Dictionary in team+boxes:
			if mon.species!=pair[0]:continue
			# Keep a compatible Mega stone, including Charizard X.
			if Catalog.data().mega_forms.get(mon.item,{}).get("base")==mon.species:continue
			var stone: String=pair[1]
			bag[stone]=int(bag.get(stone,0))+1
			equip(int(mon.uid),stone)
	for stone: String in ["venusaurite","charizardite-x","charizardite-y","blastoisinite"]:bag[stone]=maxi(1,int(bag.get(stone,0)))
	return true

func set_appearance(field: String,index: int) -> bool:
	if in_battle or not Appearance.DEFAULT.has(field):return false
	var next:=appearance.duplicate();next[field]=index
	if not Appearance.validate(next):return false
	appearance=next;return true

func _sync_storage() -> void:
	storage_slots=Storage.reconcile(boxes,storage_slots)
func stored_uid(slot: int) -> int:
	_sync_storage();return Storage.uid_at(storage_slots,slot)
func move_stored(uid: int,slot: int) -> bool:
	if in_battle or slot<0 or slot>=Storage.CAPACITY:return false
	_sync_storage()
	var key: String=str(uid)
	if not storage_slots.has(key):return false
	var current: int=int(storage_slots[key]);var other: int=Storage.uid_at(storage_slots,slot)
	storage_slots[key]=slot
	if other!=0:storage_slots[str(other)]=current
	return true
func exchange_with_party(uid: int,index: int) -> bool:
	if in_battle or index<0 or index>=team.size():return false
	var incoming: Dictionary=find(uid)
	if incoming.is_empty() or incoming not in boxes:return false
	var next: Array=team.duplicate();next[index]=incoming
	if not next.any(func(mon: Dictionary):return mon.hp>0 and exploration.can_heal(mon)):return false
	_sync_storage()
	var boxed_index: int=boxes.find(incoming);var outgoing: Dictionary=team[index]
	var slot: int=int(storage_slots[str(uid)])
	boxes[boxed_index]=outgoing;team[index]=incoming
	storage_slots.erase(str(uid));storage_slots[str(int(outgoing.uid))]=slot
	return true

func move_options(uid: int,source: String) -> Array:
	var mon:=find(uid)
	if mon.is_empty():return []
	if source=="machine":return Catalog.species(mon.species).get("machines",[]).duplicate()
	if source!="reminder":return []
	var result: Array=[];var id: String=mon.species
	while not id.is_empty():
		for entry: Dictionary in Catalog.species(id).learnset:
			if entry.level<=mon.level and entry.move not in result:result.append(entry.move)
		id=Catalog.species(id).get("previous","")
	return result
func reorder_moves(uid: int,from: int,to: int) -> bool:
	if in_battle:return false
	var mon:=find(uid)
	if mon.is_empty() or from<0 or to<0 or from>=mon.moves.size() or to>=mon.moves.size():return false
	var first: Dictionary=mon.moves[from];mon.moves[from]=mon.moves[to];mon.moves[to]=first;return true

func set_battle_options(style: String,healing: bool) -> bool:
	if in_battle or style not in ["set","shift"]:return false
	exploration.battle_style=style;exploration.bag_healing=healing;return true
