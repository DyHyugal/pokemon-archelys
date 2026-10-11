extends RefCounted
## Solo command simulation. No renderer, networking or knowledge of future inputs.
const Mon=preload("res://scripts/domain/pokemon.gd")
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
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
func begin(owner: RefCounted, opponents: Array, trainer_id: String="") -> bool:
	if active or owner.in_battle or opponents.is_empty() or trainer_id not in ["","trainer-1","trainer-2"]:return false
	for mon: Variant in opponents:
		if not Mon.validate(mon) or mon.hp<=0:return false
	var first: int=-1
	for i: int in range(owner.team.size()):
		if owner.team[i].hp>0:first=i;break
	if first<0:return false
	adventure=owner;enemies=opponents.duplicate(true);trainer=trainer_id;player_index=first;enemy_index=0
	active=true;adventure.in_battle=true;result="";turn=0;events=[];stages=[{},{}];confusion=[0,0];participants={adventure.team[first].uid:true}
	say("%s apparaît !" % title(enemies[0]),"%s appeared!" % title(enemies[0],"en"));return true
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
	match command.get("kind"):
		"move":
			var value: Variant=command.get("slot")
			if not Mon.integer(value,-1,3):return false
			return (int(value)==-1 and available_moves(0).is_empty()) or int(value) in available_moves(0)
		"switch":return valid_switch(command.get("index"))
		"ball":return trainer.is_empty() and command.get("item") in ["poke-ball","great-ball"] and int(adventure.bag.get(command.item,0))>0 and adventure.team.size()+adventure.boxes.size()<246
		"item":
			if command.get("item") not in ["potion","antidote","paralyze-heal"] or not Mon.integer(command.get("index"),0,adventure.team.size()-1):return false
			var copy: Dictionary=adventure.snapshot();var probe=adventure.get_script().new();probe.restore(copy)
			return probe.use(command.item,int(probe.team[int(command.index)].uid))
		"run":return trainer.is_empty()
	return false
func valid_switch(index: Variant) -> bool:
	return Mon.integer(index,0,adventure.team.size()-1) and int(index)!=player_index and adventure.team[int(index)].hp>0
func replace_fainted(index: int) -> bool:
	if not active or current(0).hp>0 or not valid_switch(index):return false
	events=[];switch_player(index);return true
func switch_player(index: int) -> void:
	player_index=index;stages[0]={};confusion[0]=0;participants[current(0).uid]=true
	say("À toi, %s !" % title(current(0)),"Go, %s!" % title(current(0),"en"))
func choose_enemy_move() -> int:
	var choices:=available_moves(1)
	if choices.is_empty():return -1
	# Simple visible-type baseline. Difficult setter AI belongs to later block.
	var chosen: int=choices[0];var best: float=-1.0
	for slot: int in choices:
		var move:=move_for(1,slot)
		var score: float=float(move.power)*Catalog.effectiveness(move.type,Catalog.species(current(0).species).types)
		if move.category=="status":score=12.0 if current(0).status=="" else 0.0
		score*=rng.randf_range(0.8,1.2)
		if score>best:chosen=slot;best=score
	return chosen
func stat(side: int, key: String, critical: bool=false, attacker: bool=false) -> float:
	var mon:=current(side);var value: float=Mon.stats(mon)[key]
	var stage: int=int(stages[side].get(key,0))
	if critical and ((attacker and stage<0) or (not attacker and stage>0)):stage=0
	value*=float(2+stage)/2.0 if stage>=0 else 2.0/float(2-stage)
	if key=="speed" and mon.status=="paralysis":value*=0.5
	return value
func damage(side: int, move: Dictionary, critical: bool=false, roll: float=1.0) -> int:
	var attacker:=current(side);var target:=current(1-side)
	var neutral: bool=move.get("struggle",false)
	var effect: float=1.0 if neutral else Catalog.effectiveness(move.type,Catalog.species(target.species).types)
	if effect==0:return 0
	var physical: bool=move.category=="physical"
	var attack: float=stat(side,"attack" if physical else "special_attack",critical,true)
	var defense: float=stat(1-side,"defense" if physical else "special_defense",critical,false)
	var base: float=floorf(floorf((floorf(2.0*attacker.level/5.0)+2.0)*float(move.power)*attack/maxf(1.0,defense))/50.0)+2.0
	var stab: float=1.5 if not neutral and move.type in Catalog.species(attacker.species).types else 1.0
	var ability_type: String={"overgrow":"grass","blaze":"fire","torrent":"water"}.get(attacker.ability,"")
	var ability: float=1.5 if move.type==ability_type and attacker.hp<=Mon.stats(attacker).hp/3 else 1.0
	if physical and attacker.status=="burn" and attacker.ability!="guts":base*=0.5
	if physical and attacker.status!="" and attacker.ability=="guts":base*=1.5
	return maxi(1,int(base*stab*effect*ability*(1.5 if critical else 1.0)*roll))
func apply_status(side: int, status: String) -> bool:
	var target:=current(side);var types: Array=Catalog.species(target.species).types
	if target.status!="" or target.hp<=0:return false
	if (status=="burn" and "fire" in types) or (status=="paralysis" and "electric" in types) or (status=="poison" and ("poison" in types or "steel" in types)) or (status=="freeze" and "ice" in types):return false
	target.status=status;target.status_turns=rng.randi_range(1,3) if status=="sleep" else 0
	say("%s : %s." % [title(target),Catalog.text("status_names",status)],"%s: %s." % [title(target,"en"),Catalog.text("status_names",status,"en")]);return true
func ready_to_act(side: int) -> bool:
	var mon:=current(side)
	if mon.hp<=0:return false
	if flinched[side]:say("%s est apeuré." % title(mon),"%s flinched." % title(mon,"en"));return false
	if mon.status=="sleep":
		if mon.status_turns>0:
			mon.status_turns-=1;say("%s dort." % title(mon),"%s is asleep." % title(mon,"en"));return false
		mon.status="";say("%s se réveille." % title(mon),"%s woke up." % title(mon,"en"))
	if mon.status=="freeze":
		if rng.randf()<0.2:mon.status=""
		else:say("%s est gelé." % title(mon),"%s is frozen." % title(mon,"en"));return false
	if mon.status=="paralysis" and rng.randf()<0.25:say("%s est paralysé." % title(mon),"%s is fully paralyzed." % title(mon,"en"));return false
	if confusion[side]>0:
		confusion[side]-=1
		if rng.randf()<1.0/3.0:
			var raw: int=maxi(1,int(((2.0*mon.level/5.0+2.0)*40*stat(side,"attack")/stat(side,"defense"))/50.0)+2)
			mon.hp=maxi(0,int(mon.hp)-raw);say("%s se blesse dans sa confusion." % title(mon),"%s hurt itself in confusion." % title(mon,"en"));return false
	return true
func stage_change(side: int, key: String, change: int) -> void:
	var before: int=int(stages[side].get(key,0));stages[side][key]=clampi(before+change,-6,6)
	say("%s : %s %s." % [title(current(side)),Catalog.text("stat_names",key),"↑" if change>0 else "↓"],"%s: %s %s." % [title(current(side),"en"),Catalog.text("stat_names",key,"en"),"↑" if change>0 else "↓"])
func attack(side: int, slot: int) -> void:
	if not ready_to_act(side):return
	var attacker:=current(side);var defender:=current(1-side)
	var id:=move_id(side,slot);var move:=move_for(side,slot)
	if slot>=0:attacker.moves[slot].pp-=1
	say("%s utilise %s." % [title(attacker),Catalog.name_of(id)],"%s used %s." % [title(attacker,"en"),Catalog.name_of(id,"en")])
	var self_target: bool=move.get("self",false)
	var accuracy_stage: int=clampi(int(stages[side].get("accuracy",0))-int(stages[1-side].get("evasion",0)),-6,6)
	var accuracy: float=float(move.accuracy)*(float(3+accuracy_stage)/3.0 if accuracy_stage>=0 else 3.0/float(3-accuracy_stage))
	if move.accuracy>0 and not self_target and rng.randf()*100.0>=accuracy:say("L'attaque échoue.","The attack missed.");return
	if not self_target and not move.get("struggle",false) and ((move.category!="status" and Catalog.effectiveness(move.type,Catalog.species(defender.species).types)==0) or (id=="thunder-wave" and Catalog.effectiveness("electric",Catalog.species(defender.species).types)==0)):
		say("Cela n'affecte pas %s." % title(defender),"It does not affect %s." % title(defender,"en"));return
	if move.get("powder",false) and "grass" in Catalog.species(defender.species).types:say("Le Pokémon Plante est immunisé aux poudres.","Grass Pokémon are immune to powder moves.");return
	if move.category!="status":
		var critical: bool=rng.randf()<(1.0/8.0 if move.get("crit_stage",0)==1 else 1.0/24.0)
		var amount:=damage(side,move,critical,float(rng.randi_range(85,100))/100.0)
		defender.hp=maxi(0,int(defender.hp)-amount)
		say("%s perd %d PV%s." % [title(defender),amount," — critique" if critical else ""],"%s lost %d HP%s." % [title(defender,"en"),amount," — critical" if critical else ""])
		if move.get("struggle",false):attacker.hp=maxi(0,int(attacker.hp)-maxi(1,Mon.stats(attacker).hp/4))
		if move.get("contact",false) and defender.ability=="static" and rng.randf()<0.3:apply_status(side,"paralysis")
	if move.has("stage"):stage_change(side if self_target else 1-side,move.stage,int(move.change))
	if move.get("growth",false):stage_change(side,"attack",1);stage_change(side,"special_attack",1)
	if move.has("status") and rng.randf()*100<float(move.get("chance",100)):apply_status(1-side,move.status)
	if move.has("flinch") and rng.randf()*100<float(move.flinch):flinched[1-side]=true
	if move.has("confusion") and defender.hp>0 and confusion[1-side]==0 and rng.randf()*100<float(move.confusion):confusion[1-side]=rng.randi_range(2,5)
	for owner: int in [side,1-side]:check_berry(owner)
func check_berry(side: int) -> void:
	var mon:=current(side)
	if mon.hp>0 and mon.item=="oran-berry" and mon.hp<=Mon.stats(mon).hp/2:
		mon.hp=mini(Mon.stats(mon).hp,int(mon.hp)+10);mon.item=""
		say("%s mange sa Baie Oran." % title(mon),"%s ate its Oran Berry." % title(mon,"en"))
func end_turn() -> void:
	for side: int in [0,1]:
		var mon:=current(side)
		if mon.hp<=0:continue
		if mon.status in ["burn","poison"]:
			mon.hp=maxi(0,int(mon.hp)-maxi(1,Mon.stats(mon).hp/(16 if mon.status=="burn" else 8)))
			say("%s subit les dégâts de %s." % [title(mon),Catalog.text("status_names",mon.status)],"%s took %s damage." % [title(mon,"en"),Catalog.text("status_names",mon.status,"en")])
		if mon.hp>0 and mon.item=="leftovers":mon.hp=mini(Mon.stats(mon).hp,int(mon.hp)+maxi(1,Mon.stats(mon).hp/16))
		check_berry(side)
func capture_value(item: String) -> float:
	var target:=current(1);var total: float=Mon.stats(target).hp
	var modifier: float=2.5 if target.status in ["sleep","freeze"] else (1.5 if target.status!="" else 1.0)
	return minf(255.0,((3*total-2*target.hp)/(3*total))*float(Catalog.species(target.species).catch_rate)*(1.5 if item=="great-ball" else 1.0)*modifier)
func try_capture(item: String) -> bool:
	adventure.bag[item]-=1
	var value:=capture_value(item)
	var caught: bool=value>=255.0
	if not caught:
		var threshold: float=65536.0/pow(255.0/maxf(1.0,value),3.0/16.0)
		caught=true
		for shake: int in range(4):
			if rng.randi_range(0,65535)>=threshold:caught=false;break
	if not caught:say("Le Pokémon s'échappe de la Ball !","The Pokémon broke free!");return false
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
func check_faints() -> void:
	if not adventure.team.any(func(mon: Dictionary):return mon.hp>0):
		finish("lost");adventure.money=maxi(0,adventure.money-100);adventure.heal_team()
		say("Défaite : retour au point de soins du labo (-100 ₽ maximum).","Defeat: returned to the laboratory healing point (up to ₽100 lost).");return
	if current(1).hp<=0:
		say("%s est K.O." % title(current(1)),"%s fainted." % title(current(1),"en"));award_experience()
		enemy_index+=1
		if enemy_index>=enemies.size():
			enemy_index=enemies.size()-1;finish("won")
			if not trainer.is_empty() and not adventure.victories.has(trainer):
				adventure.victories[trainer]=true;adventure.raise_cap(18 if trainer=="trainer-1" else 36);adventure.money+=300
				say("Palier débloqué : niveau %d." % adventure.cap,"Unlocked level cap: %d." % adventure.cap)
			say("Victoire !","You won!")
		else:
			stages[1]={};confusion[1]=0;participants={current(0).uid:true}
			say("L'adversaire envoie %s." % title(current(1)),"The opponent sent out %s." % title(current(1),"en"))
	if current(0).hp<=0:
		say("%s est K.O." % title(current(0)),"%s fainted." % title(current(0),"en"))
		if not adventure.team.any(func(mon: Dictionary):return mon.hp>0):
			finish("lost");adventure.money=maxi(0,adventure.money-100);adventure.heal_team()
			say("Défaite : retour au point de soins du labo (-100 ₽ maximum).","Defeat: returned to the laboratory healing point (up to ₽100 lost).")
func execute(command: Dictionary) -> bool:
	if not valid_command(command):return false
	events=[];turn+=1;flinched=[false,false]
	var enemy_slot:=choose_enemy_move()
	match command.kind:
		"run":finish("escaped");say("Tu prends la fuite.","You escaped.");return true
		"switch":switch_player(int(command.index));attack(1,enemy_slot)
		"item":
			adventure.use(command.item,int(adventure.team[int(command.index)].uid))
			say("Objet utilisé : %s." % Catalog.name_of(command.item),"Used %s." % Catalog.name_of(command.item,"en"));attack(1,enemy_slot)
		"ball":
			if try_capture(command.item):return true
			attack(1,enemy_slot)
		"move":
			var slot: int=int(command.slot)
			var priority: int=int(move_for(0,slot).priority);var enemy_priority: int=int(move_for(1,enemy_slot).priority)
			var first: int=0
			if enemy_priority>priority or (enemy_priority==priority and (stat(1,"speed")>stat(0,"speed") or (stat(1,"speed")==stat(0,"speed") and rng.randf()<0.5))):first=1
			attack(first,slot if first==0 else enemy_slot)
			if current(0).hp>0 and current(1).hp>0:attack(1-first,enemy_slot if first==0 else slot)
	end_turn();check_faints();return true

func finish(outcome: String) -> void:
	active=false;result=outcome;adventure.in_battle=false
