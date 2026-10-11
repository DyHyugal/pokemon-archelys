extends SceneTree
const Mon=preload("res://scripts/domain/pokemon.gd")
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
const Adventure=preload("res://scripts/domain/solo_adventure.gd")
const Battle=preload("res://scripts/domain/pokemon_battle.gd")
const Campaign=preload("res://scripts/domain/campaign.gd")
const Store=preload("res://scripts/services/save_store.gd")
var checks: int=0
var failures: int=0
func check(ok: bool,label: String) -> void:
	checks+=1
	if not ok:failures+=1;push_error(label)
func owner() -> RefCounted:
	var a:=Adventure.new();a.initialize();return a
func simulator(a: RefCounted,id: String="rattata",level: int=8,trainer: String="") -> RefCounted:
	var b:=Battle.new();b.rng.seed=42;b.begin(a,[Mon.make(id,level,900000)],trainer);return b
func _initialize() -> void:
	var a:=owner();var mon: Dictionary=a.team[0]
	check(a.team.size()==3 and a.next_uid==4 and Adventure.validate(a.snapshot()),"Initial test roster valid, unique IDs and equipment state")
	a.initialize();check(a.team.size()==3 and a.bag["poke-ball"]==20,"Initializing twice does not grant duplicate roster or items")
	var perfect:=Mon.make("bulbasaur",50,20);perfect.iv=[31,31,31,31,31,31]
	check(Mon.stats(perfect)=={"hp":120,"attack":69,"defense":69,"special_attack":85,"special_defense":85,"speed":65},"Independent known level-50 stat fixture")
	check(Mon.edit(perfect,[31,31,31,31,31,31],[0,252,0,0,0,252],"adamant") and Mon.stats(perfect).attack==111 and Mon.stats(perfect).special_attack==76,"Nature and EV affect real calculated stats")
	var before:=perfect.duplicate(true)
	check(not Mon.edit(perfect,[31,31,31,31,31,31],[252,252,252,0,0,0],"hardy") and perfect==before,"Over-510 EV rejected atomically")
	check(not Mon.edit(perfect,[32,0,0,0,0,0],[0,0,0,0,0,0],"hardy") and not Mon.edit(perfect,[],[],"hardy"),"Out-of-range IV and malformed arrays rejected")
	perfect.iv=[0,0,0,0,0,0];check(Mon.hidden_power(perfect)=="fighting","Zero IVs supported; Hidden Power Fighting parity fixture")
	perfect.iv=[31,31,31,31,31,31];check(Mon.hidden_power(perfect)=="dark","Hidden Power Dark perfect parity fixture")
	check(Catalog.effectiveness("electric",["ground"])==0 and Catalog.effectiveness("ice",["grass","flying"])==4 and Catalog.effectiveness("normal",["rock","steel"])==0.25,"Type immunity and dual-type multipliers")
	check(Catalog.legal_species("bulbasaur",36)=="venusaur" and Catalog.legal_species("charizard",18)=="charmeleon" and Catalog.legal_species("rattata",25)=="raticate" and Catalog.legal_species("pikachu",80)=="pikachu","Wild evolution legality up/down; item evolution stays player's choice")
	check(a.reorder(0,2) and a.team[0].species=="squirtle","Party order changes the lead")
	check(a.deposit(0) and a.team.size()==2 and a.boxes[0].species=="squirtle" and a.withdraw(0),"PC deposit and withdrawal preserve identity")
	a.team[0].hp=0;a.team[1].hp=0;check(not a.deposit(2),"Cannot deposit the last battle-ready Pokémon")
	a.heal_team();check(a.equip(int(a.team[0].uid),"leftovers") and a.bag.leftovers==0,"Equipping consumes bag quantity")
	check(not a.equip(int(a.team[1].uid),"leftovers") and a.equip(int(a.team[0].uid),"") and a.bag.leftovers==1,"Unavailable held item cannot duplicate; removal returns it")
	var uid: int=a.team[0].uid;var count: int=a.bag.potion
	check(not a.use("potion",uid) and a.bag.potion==count,"No-effect healing does not consume potion")
	a.team[0].hp=1;check(a.use("potion",uid) and a.team[0].hp==21 and a.bag.potion==count-1,"Potion changes real HP and consumes exactly one")
	a.team[0].status="poison";check(a.use("antidote",uid) and a.team[0].status=="","Status medicine actually cures")
	a=owner();uid=int(a.team[0].uid)
	a.gain_experience(uid,100000);check(a.team[0].level==10 and a.team[0].experience<Mon.experience(11,"medium-slow"),"Level cap prevents levelling and stored overflow")
	a.raise_cap(18);a.raise_cap(10);check(a.cap==18 and a.team[0].level==10,"Cap cannot decrease; raising does not release banked levels")
	a.gain_experience(uid,100000);check(a.team[0].level==18 and a.pending.any(func(c: Dictionary):return c.kind=="evolution"),"Level progression queues evolution and new attacks")
	while not a.pending.is_empty():a.resolve_choice(0,0 if a.pending[0].kind=="evolution" else -1)
	check(a.team[0].species=="ivysaur" and Mon.validate(a.team[0]),"Evolution changes species/stats/ability while preserving legal inherited moves")
	a.raise_cap(36);a.gain_experience(uid,100000)
	while not a.pending.is_empty():a.resolve_choice(0,0 if a.pending[0].kind=="evolution" else -1)
	check(a.team[0].species=="venusaur" and a.team[0].level==36,"Further evolution follows level progression")
	check(a.relearn(uid,"sleep-powder",0) and a.team[0].moves[0].id=="sleep-powder" and not a.relearn(uid,"thunderbolt",1),"Free reminder accepts inherited legal moves and rejects incompatible move")
	var electric:=Mon.make("pikachu",10,a.next_uid);a.add(electric)
	check(a.use("thunder-stone",int(electric.uid)) and electric.species=="raichu" and a.bag["thunder-stone"]==0,"Item evolution consumes stone and preserves individual")
	var corrupted: Dictionary=a.snapshot();corrupted.team[1].uid=corrupted.team[0].uid
	check(not Adventure.validate(corrupted),"Duplicate persistent IDs rejected")
	corrupted=a.snapshot();corrupted.team[0].moves[0].pp=999
	check(not Adventure.validate(corrupted),"Save with impossible PP rejected")
	var fresh:=Adventure.new();check(fresh.restore(JSON.parse_string(JSON.stringify(a.snapshot()))) and fresh.team==a.team,"Party/PC/items/preferences survive JSON round-trip")
	a=owner();var b:=simulator(a,"squirtle")
	var neutral: int=b.damage(0,Catalog.move("tackle"));var effective: int=b.damage(0,Catalog.move("vine-whip"))
	check(effective>neutral,"STAB and super-effective attack materially increase damage")
	b.stages[0].attack=-6;var normal: int=b.damage(0,Catalog.move("tackle"));var critical: int=b.damage(0,Catalog.move("tackle"),true)
	check(critical>normal*2,"Critical damage ignores negative attacking stages")
	var hp: int=b.current(1).hp;var pp: int=b.current(0).moves[2].pp
	check(b.execute({"kind":"move","slot":2}) and b.current(1).hp<hp and b.current(0).moves[2].pp==pp-1,"Command resolves damage and consumes exactly one PP")
	var state: Dictionary=a.snapshot();var turn: int=b.turn
	check(not b.execute({"kind":"move","slot":99}) and a.snapshot()==state and b.turn==turn,"Invalid command changes no battle or campaign state")
	a=owner();b=simulator(a,"rattata");b.current(1).hp=1
	hp=int(b.current(0).hp);b.current(0).moves=[{"id":"quick-attack","pp":30}]
	check(b.execute({"kind":"move","slot":0}) and b.result=="won" and b.current(1).moves[0].pp==Catalog.move(b.current(1).moves[0].id).pp,"Priority KO cancels the opponent's attack")
	a=owner();b=simulator(a,"pikachu");check(not b.apply_status(1,"paralysis"),"Electric Pokémon immune to paralysis")
	check(b.apply_status(0,"paralysis") and b.stat(0,"speed")==Mon.stats(b.current(0)).speed*0.5,"Paralysis halves actual speed")
	b.current(0).status="sleep";b.current(0).status_turns=1
	check(not b.ready_to_act(0) and b.current(0).status_turns==0 and b.ready_to_act(0),"One-turn sleep skips an action then wakes, never zero skipped turns")
	a=owner();b=simulator(a,"rattata");b.current(0).status="burn";hp=int(b.current(0).hp);b.end_turn()
	check(b.current(0).hp==hp-maxi(1,Mon.stats(b.current(0)).hp/16),"Burn residual uses 1/16 HP")
	b.current(0).status="";b.current(0).hp=1;b.current(0).item="oran-berry";b.check_berry(0)
	check(b.current(0).hp==11 and b.current(0).item=="","Oran Berry activates once and is consumed")
	b.current(0).item="leftovers";hp=int(b.current(0).hp);b.end_turn()
	check(b.current(0).hp>hp,"Leftovers heals real HP at end of turn")
	a=owner();b=simulator(a)
	for slot: Dictionary in b.current(0).moves:slot.pp=0
	check(b.available_moves(0).is_empty() and b.valid_command({"kind":"move","slot":-1}) and not b.valid_command({"kind":"move","slot":0}),"No PP enables only Struggle")
	hp=int(b.current(0).hp);b.execute({"kind":"move","slot":-1});check(b.current(0).hp<hp,"Struggle applies recoil")
	a=owner();b=simulator(a);b.stages[0].attack=6;b.confusion[0]=3
	check(b.execute({"kind":"switch","index":1}) and b.player_index==1 and b.stages[0].is_empty() and b.confusion[0]==0,"Switch resets stages/confusion and costs a turn")
	b.current(0).hp=0;turn=b.turn
	check(not b.execute({"kind":"move","slot":0}) and b.replace_fainted(2) and b.turn==turn,"Fainted Pokémon requires a free replacement, no illegal command")
	a=owner();b=simulator(a,"rattata",8,"trainer-1");count=int(a.bag["poke-ball"])
	check(not b.execute({"kind":"ball","item":"poke-ball"}) and a.bag["poke-ball"]==count and not b.execute({"kind":"run"}),"Trainer capture and escape rejected without consumption")
	a=owner();b=simulator(a)
	check(b.capture_value("great-ball")>b.capture_value("poke-ball"),"Great Ball and status modify capture chance")
	b.current(1).hp=1;b.current(1).status="sleep"
	count=int(a.bag["poke-ball"]);b.rng.seed=1
	var caught: bool=false
	for attempt: int in range(20):
		if not b.active:break
		b.current(1).hp=1;b.current(1).status="sleep";b.current(1).status_turns=3
		b.execute({"kind":"ball","item":"poke-ball"})
		if b.result=="captured":caught=true;break
	check(caught and a.team.size()==4 and a.next_uid==5 and a.bag["poke-ball"]<count,"Real seeded capture consumes ball and creates unique persistent party member")
	for id: String in ["rattata","pikachu"]:a.add(Mon.make(id,8,a.next_uid))
	b=simulator(a);b.current(1).hp=1;b.current(1).status="sleep";b.current(1).status_turns=3;b.rng.seed=1
	b.execute({"kind":"ball","item":"great-ball"})
	check(b.result=="captured" and a.team.size()==6 and a.boxes.size()==1,"Capture routes to PC when team has six members")
	check(not a.withdraw(0),"Cannot withdraw into full party")
	while a.boxes.size()<240:a.boxes.append(Mon.make("rattata",8,a.next_uid));a.next_uid+=1
	b=simulator(a);count=int(a.bag["poke-ball"])
	check(not b.execute({"kind":"ball","item":"poke-ball"}) and a.bag["poke-ball"]==count,"Full party and PC block capture without losing ball")
	a=owner();b=simulator(a);check(b.execute({"kind":"run"}) and b.result=="escaped","Wild escape terminates battle")
	a=owner();b=simulator(a,"rattata",2,"trainer-1");b.current(1).hp=1;b.current(0).moves=[{"id":"quick-attack","pp":30}]
	b.execute({"kind":"move","slot":0});check(a.cap==18 and a.money==3300 and a.victories.has("trainer-1"),"Boss victory raises cap and grants reward")
	b=simulator(a,"rattata",2,"trainer-1");b.current(1).hp=1;b.execute({"kind":"move","slot":0})
	check(a.cap==18 and a.money==3300,"Rematch does not lower cap or duplicate first-victory reward")
	a=owner();b=simulator(a,"rattata",8,"trainer-1")
	for m: Dictionary in a.team:m.hp=0
	b.current(1).hp=0;b.check_faints()
	check(b.result=="lost" and a.cap==10 and a.money==2900 and a.team.all(func(m: Dictionary):return m.hp==Mon.stats(m).hp),"Total KO including simultaneous final KO loses, heals and grants no boss reward")
	var campaign:=Campaign.new();campaign.add_player(1,"Test");campaign.adventure=a
	var v2:=campaign.snapshot();v2.schema=2;v2.erase("adventure");v2.laboratory={"completed":{"crate":true},"tokens":1}
	var restored:=Campaign.new();check(restored.restore(v2) and restored.laboratory.tokens==1 and not restored.adventure.initialized,"Old v2 restores legacy inventory without claiming a roster")
	restored.adventure.initialize();check(restored.adventure.team.size()==3 and restored.laboratory.tokens==1,"Migration initializes test roster once without losing old token")
	var path:="user://tests_loop_save.json"
	for suffix: String in ["",".backup",".v2.backup",".tmp"]:DirAccess.remove_absolute(path+suffix)
	Store.write_snapshot(path,v2);var original:=FileAccess.get_file_as_string(path)
	check(Store.write_snapshot(path,restored.snapshot())==OK and FileAccess.get_file_as_string(path+".v2.backup")==original,"v2 to v3 migration preserves original bytes")
	var saved:=Store.read_snapshot(path);check(restored.restore(saved) and restored.adventure.team.size()==3,"Schema3 full party survives disk save/load")
	saved.adventure.team[0].iv[0]=-1;before=restored.snapshot()
	check(not restored.restore(saved) and restored.snapshot()==before,"Corrupt Pokémon save rejected before any campaign mutation")
	# Rules not exercised by the happy-path UI deserve direct adverse checks.
	a=owner();b=simulator(a,"squirtle")
	var normal_damage: int=b.damage(0,Catalog.move("vine-whip"))
	b.current(0).hp=1
	check(b.damage(0,Catalog.move("vine-whip"))>normal_damage,"Overgrow boosts Grass damage below one-third HP")
	check(not b.apply_status(0,"poison"),"Poison-type Pokémon cannot be poisoned")
	a=owner();b=simulator(a,"charmander")
	check(not b.apply_status(1,"burn"),"Fire-type Pokémon cannot be burned")
	b.stages[0].attack=6;b.stage_change(0,"attack",2)
	check(b.stages[0].attack==6,"Stage boosts cannot exceed +6")
	var impossible:=Mon.make("charizard",18,200)
	check(not Mon.validate(impossible),"Persisted evolved form below its legal level rejected")
	a=owner();a.raise_cap(36);a.gain_experience(1,100000)
	while not a.pending.is_empty():a.resolve_choice(0,0 if a.pending[0].kind=="evolution" else -1)
	check(a.team[0].species=="venusaur","Multiple evolution stages resolve even when one EXP reward crosses both thresholds")
	a=owner();a.raise_cap(18);a.gain_experience(1,100000)
	var pending_copy:=Adventure.new()
	check(pending_copy.restore(JSON.parse_string(JSON.stringify(a.snapshot()))) and pending_copy.pending==a.pending,"Unresolved move/evolution choices survive JSON save/load")
	while not a.pending.is_empty():a.resolve_choice(0,-1)
	check(a.team[0].species=="bulbasaur" and a.pending.is_empty(),"Declining evolution retains the player's chosen form")
	a=owner();b=simulator(a);a.bag["poke-ball"]=0
	check(not b.execute({"kind":"ball","item":"poke-ball"}),"Absent capture item cannot create negative bag quantities")
	a=owner();b=simulator(a,"rattata",8,"trainer-1")
	b.enemies.append(Mon.make("pikachu",8,900001));b.current(1).hp=1;b.current(0).moves=[{"id":"quick-attack","pp":30}]
	b.execute({"kind":"move","slot":0})
	check(b.active and b.enemy_index==1 and b.current(1).species=="pikachu","Trainer sends next opponent after a KO instead of ending battle")
	a=owner();a.raise_cap(36);b=simulator(a,"rattata",2,"trainer-1");b.current(1).hp=1;b.current(0).moves=[{"id":"quick-attack","pp":30}];b.execute({"kind":"move","slot":0})
	check(a.cap==36,"Earlier boss cannot reduce a later unlocked level cap")
	a=owner();b=simulator(a)
	check(not a.edit(1,[31,31,31,31,31,31],[0,0,0,0,0,0],"hardy") and not a.deposit(0) and not a.equip(1,"leftovers") and not a.reorder(0,1),"Domain rejects editing, PC changes and equipment during battle")
	b.execute({"kind":"run"});check(a.edit(1,[31,31,31,31,31,31],[0,0,0,0,0,0],"hardy"),"Ending battle unlocks outside-battle editing")
	print("POKEMON SYSTEMS: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
