extends RefCounted
## Adventure-only combat rules: captures, bag permissions, rewards and final campaign state.
## No attack, damage, status, ability, item-held or residual calculation.
const Mon=preload("res://scripts/domain/pokemon.gd")
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
const Field=preload("res://scripts/domain/battle_field.gd")
var field:=Field.new()
var mega_used: Array=[false,false]
var charging: Array=[-1,-1]
# Combat-only state keyed by identity, never serialized into campaign saves.
var protected: Dictionary={}
var protect_chain: Dictionary={}
var helping: Dictionary={}
var spread_multiplier: float=1.0
var protect_has_following_action: bool=true
var encounter_zone: String="village"
var observed_move: String=""
var adventure: RefCounted
var enemies: Array=[]
var player_index: int=0
var enemy_index: int=0
var trainer: String=""
var active: bool=false
var result: String=""
var turn: int=0
var events: Array=[]
var stages: Array=[{},{}]
var confusion: Array=[0,0]
var flinched: Array=[false,false]
var participants: Dictionary={}
var rng:=RandomNumberGenerator.new()
func _init() -> void:rng.randomize()
func say(fr: String, en: String) -> void:events.append({"fr":fr,"en":en})
func title(mon: Dictionary, lang: String="fr") -> String:return Catalog.name_of(mon.species,lang)
func current(side: int) -> Dictionary:return adventure.team[player_index] if side==0 else enemies[enemy_index]
func available_moves(side: int) -> Array:
	var choices: Array=[]
	for i: int in range(current(side).moves.size()):
		if current(side).moves[i].pp>0:choices.append(i)
	return choices
func move_for(side: int, slot: int) -> Dictionary:
	return Catalog.move("struggle") if slot==-1 else Catalog.move(current(side).moves[slot].id)
func move_id(side: int, slot: int) -> String:
	return "struggle" if slot==-1 else current(side).moves[slot].id
func valid_command(command: Dictionary) -> bool:
	if not active or current(0).hp<=0:return false
	if command.get("mega",false) and not can_mega(0):return false
	if charging[0]>=0 and (command.get("kind")!="move" or command.get("slot")!=charging[0]):return false
	match command.get("kind"):
		"move":
			var value: Variant=command.get("slot")
			if not Mon.integer(value,-1,3):return false
			return (int(value)==-1 and available_moves(0).is_empty()) or int(value) in available_moves(0)
		"switch":return valid_switch(command.get("index"))
		"ball":return trainer.is_empty() and (current(1).get("shiny",false) or adventure.exploration.may_capture(encounter_zone,int(current(1).uid)) or (not adventure.exploration.claims.has(encounter_zone) and family_duplicate(current(1).species))) and command.get("item") in ["poke-ball","great-ball"] and int(adventure.bag.get(command.item,0))>0 and adventure.team.size()+adventure.boxes.size()<246
		"item":
			if not adventure.exploration.bag_healing:return false
			if command.get("item") not in ["potion","antidote","paralyze-heal"] or not Mon.integer(command.get("index"),0,adventure.team.size()-1):return false
			var copy: Dictionary=adventure.snapshot();var probe=adventure.get_script().new();probe.restore(copy)
			return probe.use(command.item,int(probe.team[int(command.index)].uid))
		"run":return trainer.is_empty()
	return false
func valid_switch(index: Variant) -> bool:
	return Mon.integer(index,0,adventure.team.size()-1) and int(index)!=player_index and adventure.team[int(index)].hp>0 and adventure.exploration.can_heal(adventure.team[int(index)])
func capture_value(item: String) -> float:
	var target:=current(1);var total: float=Mon.stats(target).hp
	var modifier: float=2.5 if target.status in ["sleep","freeze"] else (1.5 if target.status!="" else 1.0)
	return minf(255.0,((3*total-2*target.hp)/(3*total))*float(Catalog.species(target.species).catch_rate)*(1.5 if item=="great-ball" else 1.0)*modifier)
func try_capture(item: String) -> bool:
	if not current(1).get("shiny",false) and not adventure.exploration.claims.has(encounter_zone):adventure.exploration.reserve_encounter(encounter_zone,int(current(1).uid))
	adventure.bag[item]-=1
	var value:=capture_value(item)
	var caught: bool=value>=255.0
	if not caught:
		var threshold: float=65536.0/pow(255.0/maxf(1.0,value),3.0/16.0)
		caught=true
		for shake: int in range(4):
			if rng.randi_range(0,65535)>=threshold:caught=false;break
	if not caught:
		if not current(1).get("shiny",false):adventure.exploration.settle_encounter(encounter_zone,int(current(1).uid),false)
		say("Le Pokémon s'échappe de la Ball !","The Pokémon broke free!");return false
	var mon:=current(1).duplicate(true);mon.uid=adventure.next_uid
	award_experience(false)
	var destination: String=adventure.add(mon)
	if destination in ["full","duplicate"]:return false
	say("%s capturé — %s." % [title(mon),"équipe" if destination=="team" else "PC"],"Caught %s — %s." % [title(mon,"en"),"party" if destination=="team" else "PC"])
	finish("captured");return true
func award_experience(grant_effort: bool=true) -> void:
	var defeated:=current(1)
	for mon: Dictionary in adventure.team:
		if mon.hp<=0:continue
		var share: float=1.0 if participants.has(mon.uid) else 0.5
		var amount: int=int((float(Catalog.species(defeated.species).base_exp)*defeated.level/5.0)*pow((2.0*defeated.level+10.0)/(defeated.level+mon.level+10.0),2.5)*share+1)
		if mon.item=="lucky-egg":amount=int(amount*1.5)
		var before: int=int(mon.experience)
		var changes: Array=adventure.gain_experience(int(mon.uid),amount)
		var gained: int=int(mon.experience)-before
		if gained>0:say("%s gagne %d EXP." % [title(mon),gained],"%s gained %d EXP." % [title(mon,"en"),gained])
		for change: String in changes:
			if change=="cap":say("%s a atteint le cap %d." % [title(mon),adventure.cap],"%s reached level cap %d." % [title(mon,"en"),adventure.cap])
			else:say("%s passe au niveau %s." % [title(mon),change.trim_prefix("level:")],"%s reached level %s." % [title(mon,"en"),change.trim_prefix("level:")])
		if grant_effort:
			var effort: Array=Catalog.species(defeated.species).get("effort",[0,0,0,0,0,0])
			for i: int in range(6):
				var total: int=0
				for v: Variant in mon.ev:total+=int(v)
				mon.ev[i]=mini(252,int(mon.ev[i])+mini(510-total,int(effort[i])))
func finish(outcome: String) -> void:
	if trainer.is_empty() and not enemies[0].get("shiny",false):adventure.exploration.settle_encounter(encounter_zone,int(enemies[0].uid),outcome=="captured")
	for mon: Dictionary in adventure.team+enemies:
		if mon.has("battle_form"):
			var old_max: int=Mon.stats(mon).hp
			mon.erase("battle_form")
			mon.hp=0 if mon.hp==0 else maxi(1,Mon.stats(mon).hp-(old_max-int(mon.hp)))
	protected.clear();helping.clear();protect_chain.clear()
	active=false;result=outcome;adventure.in_battle=false
func can_mega(side: int) -> bool:
	var mon:=current(side)
	return not mega_used[side] and Catalog.data().mega_forms.has(mon.item) and Catalog.data().mega_forms[mon.item].base==mon.species and mon.hp>0
func family_duplicate(id: String) -> bool:
	if adventure.exploration.nuzlocke!="on":return false
	var base: String=id
	while not Catalog.species(base).get("previous","").is_empty():base=Catalog.species(base).previous
	for mon: Dictionary in adventure.team+adventure.boxes:
		var owned: String=mon.species
		while not Catalog.species(owned).get("previous","").is_empty():owned=Catalog.species(owned).previous
		if owned==base:return true
	return false
