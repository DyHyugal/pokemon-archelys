extends "res://scripts/domain/pokemon_battle.gd"
## Genuine four-actor turn queue. Current catalogue: single-target attacks.
var double_mode: bool=true
var player_slots: Array=[0,1]
var enemy_slots: Array=[0,1]
var selected_player: int=0
var selected_enemy: int=0
var queued: Dictionary={}
var volatile_state: Dictionary={}
var rewarded: Dictionary={}
func begin(owner: RefCounted,opponents: Array,trainer_id: String="weather-test") -> bool:
	var seen: Array=[]
	for mon: Dictionary in owner.team+owner.boxes+opponents:
		if mon.uid in seen:return false
		seen.append(mon.uid)
	var ready: Array=[]
	for index: int in range(owner.team.size()):
		if owner.team[index].hp>0 and owner.exploration.can_heal(owner.team[index]):ready.append(index)
	if ready.size()<2 or opponents.size()<2 or trainer_id.is_empty():return false
	player_slots=[ready[0],ready[1]];enemy_slots=[0,1];selected_player=0;selected_enemy=0
	queued={};volatile_state={};rewarded={}
	if not super.begin(owner,opponents,trainer_id):return false
	bind_pair(1,1);enter_field(0);enter_field(1)
	selected_player=0;selected_enemy=0;bind_pair(0,0);return true
func current(side: int) -> Dictionary:
	if adventure==null:return {}
	return adventure.team[int(player_slots[selected_player])] if side==0 else enemies[int(enemy_slots[selected_enemy])]
func bind_pair(player: int,enemy: int) -> void:
	selected_player=player;selected_enemy=enemy
	for side: int in [0,1]:
		var state: Dictionary=volatile_state.get(int(current(side).uid),{})
		stages[side]=state.get("stages",{}).duplicate();confusion[side]=int(state.get("confusion",0));charging[side]=int(state.get("charging",-1));flinched[side]=state.get("flinched",false)
func store_pair() -> void:
	for side: int in [0,1]:volatile_state[int(current(side).uid)]={"stages":stages[side].duplicate(),"confusion":confusion[side],"charging":charging[side],"flinched":flinched[side]}
func valid_switch(index: Variant) -> bool:
	if not Mon.integer(index,0,adventure.team.size()-1) or int(index) in player_slots or adventure.team[int(index)].hp<=0 or not adventure.exploration.can_heal(adventure.team[int(index)]):return false
	for command: Dictionary in queued.values():
		if command.kind=="switch" and int(command.index)==int(index):return false
	return true
func switch_player(index: int) -> void:
	volatile_state.erase(int(current(0).uid));player_slots[selected_player]=index
	stages[0]={};confusion[0]=0;charging[0]=-1;flinched[0]=false;participants[current(0).uid]=true;enter_field(0)
	say("À toi, %s !" % title(current(0)),"Go, %s!" % title(current(0),"en"))
	store_pair()
func valid_command(command: Dictionary) -> bool:
	if command.get("kind") not in ["move","switch"] or queued.has(selected_player):return false
	if command.kind=="move":
		if not Mon.integer(command.get("target"),0,1) or enemies[int(enemy_slots[int(command.target)])].hp<=0:return false
		for entry: Dictionary in queued.values():
			if command.get("mega",false) and entry.get("mega",false):return false
	return super.valid_command(command)
func execute(command: Dictionary) -> bool:
	if not valid_command(command):return false
	queued[selected_player]=command.duplicate(true)
	for index: int in range(2):
		if adventure.team[int(player_slots[index])].hp>0 and not queued.has(index):bind_pair(index,0 if enemies[int(enemy_slots[0])].hp>0 else 1);events=[];return true
	return resolve_double_turn()
func resolve_double_turn() -> bool:
	events=[];turn+=1
	for state: Dictionary in volatile_state.values():state.flinched=false
	var orders: Array=[]
	# Enemy planning reads current public battlefield, never queued player choices.
	for slot: int in range(2):
		bind_pair(0 if adventure.team[int(player_slots[0])].hp>0 else 1,slot)
		if current(1).hp<=0:continue
		var target: int=rng.randi_range(0,1)
		if adventure.team[int(player_slots[target])].hp<=0:target=1-target
		bind_pair(target,slot)
		var attack_slot:=choose_enemy_move()
		orders.append({"side":1,"actor":slot,"target":target,"kind":"move","slot":attack_slot,"priority":int(move_for(1,attack_slot).priority),"speed":stat(1,"speed"),"tie":rng.randf(),"uid":int(current(1).uid)})
	for slot: int in queued:
		var command: Dictionary=queued[slot].duplicate(true)
		bind_pair(slot,int(command.get("target",0)))
		if command.get("mega",false):mega(0)
		command.merge({"side":0,"actor":slot,"priority":6 if command.kind=="switch" else int(move_for(0,int(command.slot)).priority),"speed":stat(0,"speed"),"tie":rng.randf(),"uid":int(current(0).uid)})
		orders.append(command);store_pair()
	queued.clear()
	orders.sort_custom(func(a: Dictionary,b: Dictionary):return a.priority>b.priority if a.priority!=b.priority else (a.speed>b.speed if a.speed!=b.speed else a.tie>b.tie))
	for order: Dictionary in orders:
		var side: int=int(order.side);var target: int=int(order.get("target",0))
		var targets: Array=enemy_slots if side==0 else player_slots
		var members: Array=enemies if side==0 else adventure.team
		if members[int(targets[target])].hp<=0:target=1-target
		bind_pair(int(order.actor) if side==0 else target,target if side==0 else int(order.actor))
		if current(side).hp<=0 or int(current(side).uid)!=int(order.uid):continue
		if order.kind=="switch":switch_player(int(order.index))
		elif current(1-side).hp>0:attack(side,int(order.slot));store_pair()
	# Residuals once per actor; field timers once per global turn.
	for side: int in [0,1]:
		for slot: int in range(2):
			bind_pair(slot if side==0 else 0,slot if side==1 else 0)
			var mon:=current(side)
			if mon.hp<=0:continue
			if mon.status in ["burn","poison"]:mon.hp=maxi(0,int(mon.hp)-maxi(1,Mon.stats(mon).hp/(16 if mon.status=="burn" else 8)))
			if mon.hp>0 and ability(side)=="solar-power" and field.weather=="sun":mon.hp=maxi(0,int(mon.hp)-maxi(1,Mon.stats(mon).hp/8))
			if mon.hp>0 and ability(side)=="rain-dish" and field.weather=="rain":mon.hp=mini(Mon.stats(mon).hp,int(mon.hp)+maxi(1,Mon.stats(mon).hp/16))
			if mon.hp>0 and grounded(side) and field.terrain=="grass":mon.hp=mini(Mon.stats(mon).hp,int(mon.hp)+maxi(1,Mon.stats(mon).hp/16))
			if mon.hp>0 and field.weather=="sand" and not types(side).any(func(type: String):return type in ["rock","ground","steel"]):mon.hp=maxi(0,int(mon.hp)-maxi(1,Mon.stats(mon).hp/16))
			if mon.hp>0 and mon.item=="leftovers":mon.hp=mini(Mon.stats(mon).hp,int(mon.hp)+maxi(1,Mon.stats(mon).hp/16))
			check_berry(side)
	for ended: String in field.tick():say("Fin du champ/climat : %s." % ended,"Field/weather ended: %s." % ended)
	adventure.exploration.record_deaths(adventure.team)
	for slot: int in range(2):
		bind_pair(0,slot)
		if current(1).hp==0 and not rewarded.has(current(1).uid):rewarded[current(1).uid]=true;award_experience()
		if current(1).hp==0:
			for index: int in range(enemies.size()):
				if index not in enemy_slots and enemies[index].hp>0:enemy_slots[slot]=index;bind_pair(0,slot);enter_field(1);break
	if not adventure.team.any(func(mon: Dictionary):return mon.hp>0):finish("lost");adventure.money=maxi(0,adventure.money-100);adventure.heal_team()
	elif not enemies.any(func(mon: Dictionary):return mon.hp>0):finish("won");say("Victoire en double !","Double battle won!")
	var player: int=0
	for slot: int in range(2):
		if adventure.team[int(player_slots[slot])].hp==0 and adventure.team.any(func(mon: Dictionary):return mon.hp>0 and adventure.team.find(mon) not in player_slots):player=slot;break
	bind_pair(player,0 if enemies[int(enemy_slots[0])].hp>0 else 1)
	return true
func replacement_needed() -> bool:
	return current(0).hp<=0 and adventure.team.any(func(mon: Dictionary):return mon.hp>0 and adventure.team.find(mon) not in player_slots)
func next_actor() -> void:
	for slot: int in range(2):
		if adventure.team[int(player_slots[slot])].hp>0:bind_pair(slot,0 if enemies[int(enemy_slots[0])].hp>0 else 1);return
func replace_fainted(index: int) -> bool:
	if not active or not replacement_needed() or not valid_switch(index):return false
	events=[];switch_player(index)
	for slot: int in range(2):
		bind_pair(slot,selected_enemy)
		if replacement_needed():return true
	next_actor();return true

func enter_field(side: int) -> void:
	super.enter_field(side);store_pair()
	if ability(side)=="intimidate":
		var player: int=selected_player;var enemy: int=selected_enemy
		bind_pair(player,1-enemy) if side==0 else bind_pair(1-player,enemy)
		if current(1-side).hp>0:stage_change(1-side,"attack",-1);store_pair()
		bind_pair(player,enemy)
