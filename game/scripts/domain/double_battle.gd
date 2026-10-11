extends "res://scripts/domain/pokemon_battle.gd"
## Legacy comparison fixture only; never instantiated by the playable world.
## Four actors, one turn: single/area attacks, ally support and Protect.
var double_mode: bool=true
var sandbox: bool=false
var player_slots: Array=[0,1]
var enemy_slots: Array=[0,1]
var selected_player: int=0
var selected_enemy: int=0
var queued: Dictionary={}
var volatile_state: Dictionary={}
var rewarded: Dictionary={}
var target_override: Dictionary={}
var override_side: int=-1
var acted: Dictionary={}
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
	queued={};volatile_state={};rewarded={};acted={};target_override={};override_side=-1
	if not super.begin(owner,opponents,trainer_id):return false
	bind_pair(1,1);enter_field(0);enter_field(1)
	selected_player=0;selected_enemy=0;bind_pair(0,0);return true
func current(side: int) -> Dictionary:
	if side==override_side and not target_override.is_empty():return target_override
	if adventure==null:return {}
	return adventure.team[int(player_slots[selected_player])] if side==0 else enemies[int(enemy_slots[selected_enemy])]
func bind_pair(player: int,enemy: int) -> void:
	target_override={};override_side=-1
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
	protected.erase(int(current(0).uid));protect_chain.erase(int(current(0).uid));helping.erase(int(current(0).uid))
	volatile_state.erase(int(current(0).uid));player_slots[selected_player]=index
	stages[0]={};confusion[0]=0;charging[0]=-1;flinched[0]=false;participants[current(0).uid]=true;enter_field(0)
	say("À toi, %s !" % title(current(0)),"Go, %s!" % title(current(0),"en"))
	store_pair()
func valid_command(command: Dictionary) -> bool:
	if not active or adventure==null:return false
	if command.get("kind") not in ["move","switch"] or queued.has(selected_player):return false
	if command.kind=="move":
		if not Mon.integer(command.get("slot"),-1,3) or not Mon.integer(command.get("target",0),0,1) or not Mon.integer(command.get("target_side",1),0,1):return false
		var attack_slot: int=int(command.slot)
		if attack_slot>=current(0).moves.size():return false
		var move:=move_for(0,attack_slot)
		var target_kind: String=move.get("target","self" if move.get("self",false) else "single")
		if target_kind=="ally":
			if adventure.team[int(player_slots[1-selected_player])].hp<=0:return false
		elif target_kind=="single":
			if not Mon.integer(command.get("target"),0,1) or not Mon.integer(command.get("target_side",1),0,1):return false
			var target_side: int=int(command.get("target_side",1));var target_slot: int=int(command.target)
			if target_side==0 and (target_slot==selected_player or attack_slot==-1):return false
			var members: Array=adventure.team if target_side==0 else enemies
			var positions: Array=player_slots if target_side==0 else enemy_slots
			if members[int(positions[target_slot])].hp<=0:return false
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
	events=[];turn+=1;acted.clear();protected.clear();helping.clear()
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
		orders.append({"side":1,"actor":slot,"target":target,"target_side":0,"kind":"move","slot":attack_slot,"priority":int(move_for(1,attack_slot).priority),"speed":stat(1,"speed"),"tie":rng.randf(),"uid":int(current(1).uid)})
	for slot: int in queued:
		var command: Dictionary=queued[slot].duplicate(true)
		bind_pair(slot,int(command.get("target",0)) if int(command.get("target_side",1))==1 else 0)
		if command.get("mega",false):mega(0)
		command.merge({"side":0,"actor":slot,"priority":6 if command.kind=="switch" else int(move_for(0,int(command.slot)).priority),"speed":stat(0,"speed"),"tie":rng.randf(),"uid":int(current(0).uid)})
		orders.append(command);store_pair()
	queued.clear()
	orders.sort_custom(func(a: Dictionary,b: Dictionary):return a.priority>b.priority if a.priority!=b.priority else (a.speed>b.speed if a.speed!=b.speed else a.tie>b.tie))
	for order_index: int in range(orders.size()):
		var order: Dictionary=orders[order_index]
		protect_has_following_action=false
		for later: Dictionary in orders.slice(order_index+1):
			var roster: Array=adventure.team if later.side==0 else enemies
			var positions_later: Array=player_slots if later.side==0 else enemy_slots
			var actor_later: Dictionary=roster[int(positions_later[int(later.actor)])]
			if actor_later.hp>0 and int(actor_later.uid)==int(later.uid):protect_has_following_action=true;break
		var side: int=int(order.side);var target: int=int(order.get("target",0))
		var target_side: int=int(order.get("target_side",1-side))
		var members: Array=enemies if target_side==1 else adventure.team
		var positions: Array=enemy_slots if target_side==1 else player_slots
		if target_side!=side and members[int(positions[target])].hp<=0:target=1-target
		bind_pair(int(order.actor) if side==0 else (target if target_side==0 else 0),(target if target_side==1 else 0) if side==0 else int(order.actor))
		if current(side).hp<=0 or int(current(side).uid)!=int(order.uid):continue
		if order.kind=="switch":switch_player(int(order.index))
		else:
			var move:=move_for(side,int(order.slot))
			var individual: bool=move.get("target","")=="single" or (not move.has("target") and not move.get("self",false))
			if individual and target_side==side:bind_ally(side,int(order.actor),target)
			attack(side,int(order.slot))
			store_pair()
		acted[int(order.uid)]=true
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
	protected.clear();helping.clear()
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

func target_is_opponent() -> bool:return target_override.is_empty()
func bind_ally(side: int,actor: int,ally: int) -> void:
	bind_pair(actor if side==0 else 0,actor if side==1 else 0)
	override_side=1-side
	target_override=adventure.team[int(player_slots[ally])] if side==0 else enemies[int(enemy_slots[ally])]
	var state: Dictionary=volatile_state.get(int(target_override.uid),{})
	stages[1-side]=state.get("stages",{}).duplicate();confusion[1-side]=int(state.get("confusion",0));charging[1-side]=int(state.get("charging",-1));flinched[1-side]=state.get("flinched",false)
func attack(side: int,slot: int) -> void:
	var move:=move_for(side,slot);var id:=move_id(side,slot)
	var actor: int=selected_player if side==0 else selected_enemy
	var player: int=selected_player;var enemy: int=selected_enemy
	if not start_attack(side,slot):store_pair();return
	if move.get("helping_hand",false):
		store_pair();bind_ally(side,actor,1-actor)
		var ally:=current(1-side)
		if ally.hp<=0 or acted.has(int(ally.uid)):say("Coup d’Main échoue.","Helping Hand failed.")
		else:
			helping[int(ally.uid)]=true
			say("%s soutient %s." % [title(current(side)),title(ally)],"%s is helping %s." % [title(current(side),"en"),title(ally,"en")])
		store_pair();bind_pair(player,enemy);return
	var target_kind: String=move.get("target","")
	if target_kind not in ["opponents","all-adjacent"]:
		resolve_hit(side,move,id);return
	store_pair()
	# Snapshot living targets before damage: protection/immunity still counts.
	var targets: Array=[]
	var members: Array=enemies if side==0 else adventure.team
	var positions: Array=enemy_slots if side==0 else player_slots
	for target: int in range(2):
		if members[int(positions[target])].hp>0:targets.append({"ally":false,"slot":target})
	var allies: Array=adventure.team if side==0 else enemies
	var ally_slots: Array=player_slots if side==0 else enemy_slots
	if target_kind=="all-adjacent" and allies[int(ally_slots[1-actor])].hp>0:targets.append({"ally":true,"slot":1-actor})
	spread_multiplier=0.75 if targets.size()>1 and move.category!="status" else 1.0
	for target: Dictionary in targets:
		if target.ally:bind_ally(side,actor,int(target.slot))
		else:bind_pair(actor if side==0 else int(target.slot),int(target.slot) if side==0 else actor)
		resolve_hit(side,move,id);store_pair()
	spread_multiplier=1.0;bind_pair(player,enemy)
