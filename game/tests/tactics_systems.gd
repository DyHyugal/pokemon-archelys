extends SceneTree
const Mon=preload("res://scripts/domain/pokemon.gd")
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
const Adventure=preload("res://scripts/domain/solo_adventure.gd")
const Battle=preload("res://scripts/domain/pokemon_battle.gd")
const Double=preload("res://scripts/domain/double_battle.gd")
var checks:=0
var failures:=0
func check(ok: bool,label: String) -> void:
 checks+=1
 if not ok:failures+=1;push_error(label)
func moves(mon: Dictionary,ids: Array) -> void:
 mon.moves=[]
 for id: String in ids:mon.moves.append({"id":id,"pp":int(Catalog.move(id).pp)})
func owner() -> RefCounted:
 var a:=Adventure.new();a.initialize();a.team=[Mon.make("blastoise",50,1),Mon.make("venusaur",50,2),Mon.make("charizard",50,3)];a.next_uid=4;a.cap=100
 moves(a.team[0],["surf","protect","rock-slide","water-pulse"]);moves(a.team[1],["helping-hand","protect","razor-leaf","growth"])
 return a
func doubles(a: RefCounted) -> RefCounted:
 var d:=Double.new();d.rng.seed=41
 d.begin(a,[Mon.make("raticate",50,900000),Mon.make("raticate",50,900001)])
 return d
func _initialize() -> void:
 check(not Double.new().valid_command({"kind":"move","slot":0,"target":0}),"Inactive double simulator rejects commands without accessing missing actors")
 var a:=owner();check(Adventure.validate(a.snapshot()),"Tactics roster and moves are legal, not arbitrary save exceptions")
 check(Catalog.move("protect").priority==4 and Catalog.move("helping-hand").priority==5 and Catalog.move("surf").power==90 and Catalog.move("rock-slide").accuracy==90,"Official move parameters from pinned source")
 var b:=Battle.new();b.rng.seed=41;b.begin(a,[Mon.make("raticate",50,900000)],"weather-test")
 b.attack(0,1);check(b.protected.has(1) and a.team[0].moves[1].pp==9,"First Protect succeeds, consumes one PP")
 var hp: int=a.team[0].hp;b.attack(1,0);check(a.team[0].hp==hp,"Protect blocks opposing damaging moves")
 b.enemies[0].moves=[{"id":"tail-whip","pp":30}];b.attack(1,0);check(b.stages[0].get("defense",0)==0,"Protect blocks opposing stat reductions")
 b.enemies[0].moves=[{"id":"thunder-wave","pp":20}];b.attack(1,0);check(a.team[0].status=="","Protect blocks status infliction")
 a.team[0].status="poison";b.end_turn();check(a.team[0].hp<hp and b.protected.is_empty(),"Protect permits poison residuals and expires after the turn")
 a.team[0].status="";b.attack(1,0);check(a.team[0].status=="paralysis","Expired Protect no longer blocks status")
 a.team[0].status="";b.attack(0,0);check(not b.protect_chain.has(1),"A different move resets the consecutive Protect chain")
 var successes: int=0
 for i: int in range(300):
  b.protect_chain[1]=1;a.team[0].moves[1].pp=10;b.attack(0,1)
  if b.protected.has(1):successes+=1
  b.protected.clear()
 check(successes>=75 and successes<=125,"Deterministic sample rejects both guaranteed or near-zero consecutive Protect")
 b.protect_chain[1]=6;b.rng.seed=7;b.attack(0,1)
 check(not b.protected.has(1) and not b.protect_chain.has(1),"Failed repeated Protect resets the chain")
 b.attack(0,1);check(b.protected.has(1),"Protect after failure succeeds without retaining penalty")
 b.switch_player(1);check(not b.protect_chain.has(1),"Switching clears previous user's Protect streak")
 b.attack(0,0);check(b.helping.is_empty() and a.team[1].moves[0].pp==19,"Helping Hand in singles fails but consumes PP")
 b.finish("escaped");check(Adventure.validate(a.snapshot()),"No Protect or support state leaks into campaign")
 a=owner();var d:=doubles(a)
 check(d.damage(0,Catalog.move("surf"),false,1.0)==72,"Independent level50 Surf damage fixture: 97 SpA against 82 SpD, 90 power, STAB")
 d.spread_multiplier=0.75;check(d.damage(0,Catalog.move("surf"),false,1.0)==54,"Multi-target damage applies 0.75 modifier")
 d.helping[1]=true;check(d.damage(0,Catalog.move("surf"),false,1.0)==81,"Helping Hand and spread modifiers combine")
 d.helping.clear();d.spread_multiplier=1.0;var first: int=d.enemies[0].hp;var second: int=d.enemies[1].hp;var ally: int=a.team[1].hp
 d.attack(0,0)
 check(d.enemies[0].hp<first and d.enemies[1].hp<second and a.team[1].hp<ally and a.team[0].hp==146,"Surf hits both opponents and ally, never its caster")
 check(a.team[0].moves[0].pp==14 and d.events.filter(func(e: Dictionary):return e.en.contains("used Surf")).size()==1,"Spread attack consumes PP and announces exactly once")
 check(d.spread_multiplier==1.0 and d.target_override.is_empty(),"Spread resolution restores pair and temporary modifier")
 d.finish("escaped")
 a=owner();d=doubles(a);d.bind_pair(1,0);d.attack(0,1);d.store_pair();d.bind_pair(0,0);ally=a.team[1].hp;d.attack(0,0)
 check(a.team[1].hp==ally and d.enemies.all(func(m: Dictionary):return m.hp<Mon.stats(m).hp),"Protected ally avoids Surf while both enemies are hit")
 d.finish("escaped")
 a=owner();d=doubles(a);d.attack(0,2)
 check(a.team[1].hp==147 and d.enemies.all(func(m: Dictionary):return m.hp<122),"Rock Slide targets only opponents, not ally")
 d.finish("escaped")
 a=owner();d=doubles(a);moves(a.team[1],["growl"]);d.bind_pair(1,0);d.attack(0,0)
 d.bind_pair(0,0);var drop: int=d.stages[1].get("attack",0);d.bind_pair(0,1)
 check(drop==-1 and d.stages[1].get("attack",0)==-1 and d.stages[0].get("attack",0)==0,"Growl affects both opponents, never allies, persists across pair binding")
 d.finish("escaped")
 a=owner();d=doubles(a);d.bind_pair(1,0);d.field.set_terrain("psychic");d.protected[1]=true;d.attack(0,0)
 check(d.helping.has(1) and not d.helping.has(2),"Helping Hand supports ally through Psychic Terrain and its Protect")
 d.acted[1]=true;d.helping.clear();d.attack(0,0);check(d.helping.is_empty(),"Support cannot retroactively boost an ally that has already acted")
 d.finish("escaped")
 a=owner();d=doubles(a);d.bind_ally(0,0,1);moves(a.team[0],["water-pulse"]);ally=a.team[1].hp;first=d.enemies[0].hp;d.attack(0,0);d.store_pair()
 check(a.team[1].hp<ally and d.enemies[0].hp==first,"Explicit single-target ally attack damages that ally, not an opponent")
 d.bind_pair(0,0);check(not d.valid_command({"kind":"move","slot":0,"target":0,"target_side":0}),"A single-target attack cannot target its own caster")
 check(not d.valid_command({"kind":"move","slot":9,"target":0}) and not d.valid_command({"kind":"move","slot":0,"target":5}) and not d.valid_command({"kind":"move","slot":0,"target":0,"target_side":9}),"Malformed slots and targeting rejected without indexing errors")
 d.finish("escaped")
 a=owner();d=doubles(a);moves(d.enemies[0],["splash"]);moves(d.enemies[1],["splash"])
 check(d.execute({"kind":"move","slot":0,"target":0}) and d.turn==0 and a.team[0].moves[0].pp==15,"Area command queues without early PP or damage")
 check(d.execute({"kind":"move","slot":1,"target":0}) and d.turn==1 and a.team[1].hp==147 and a.team[0].moves[0].pp==14,"Priority4 Protect executes before slower Surf in genuine four-actor queue")
 check(d.protected.is_empty() and d.helping.is_empty(),"Turn-end clears temporary shields and support")
 d.finish("escaped")
 a=owner();d=doubles(a);moves(d.enemies[0],["splash"]);moves(d.enemies[1],["splash"])
 d.execute({"kind":"move","slot":0,"target":0});d.execute({"kind":"move","slot":0,"target":0})
 check(d.events.any(func(e: Dictionary):return e.en.contains("is helping Blastoise")) and a.team[1].moves[0].pp==19 and a.team[0].moves[0].pp==14,"Priority5 ally support executes before spread move, PP once per actor")
 d.finish("escaped")
 a=owner();d=doubles(a);moves(d.enemies[0],["splash"]);moves(d.enemies[1],["splash"]);d.enemies[0].hp=1;d.enemies[1].hp=1
 d.execute({"kind":"move","slot":0,"target":0});d.execute({"kind":"move","slot":1,"target":0})
 check(d.result=="won" and d.rewarded.size()==2 and not a.in_battle,"Area double KO rewards each distinct enemy once and ends battle")
 a=owner();d=doubles(a);a.team[0].status="sleep";a.team[0].status_turns=2;d.attack(0,0)
 check(a.team[0].moves[0].pp==15 and d.enemies.all(func(m: Dictionary):return m.hp==122) and a.team[0].status_turns==1,"Spread checks sleep once, consumes neither PP nor target damage when unable to act")
 d.finish("escaped")
 a=owner();d=doubles(a);moves(d.enemies[0],["surf"]);var ally_enemy: int=d.enemies[1].hp;first=a.team[0].hp;second=a.team[1].hp;d.attack(1,0)
 check(a.team[0].hp<first and a.team[1].hp<second and d.enemies[1].hp<ally_enemy and d.enemies[0].hp==122,"Enemy Surf follows symmetric targeting including its own ally")
 d.finish("escaped")
 a=owner();d=doubles(a);d.bind_pair(0,1);moves(d.enemies[1],["protect"]);d.attack(1,0);d.store_pair();d.bind_pair(0,0);d.attack(0,0)
 check(d.enemies[1].hp==122 and d.enemies[0].hp<122 and a.team[1].hp<147,"Protected enemy is skipped independently, other Surf targets still hit")
 check(122-int(d.enemies[0].hp)<=81,"Protected target still counts for spread reduction, even on critical damage")
 d.finish("escaped")
 a=owner();d=doubles(a);d.enemies[1].hp=0;d.rng.seed=22;d.attack(0,2);var double_hp: int=d.enemies[0].hp
 var solo_owner:=owner();b=Battle.new();b.begin(solo_owner,[Mon.make("raticate",50,900000)],"weather-test");b.rng.seed=22;b.attack(0,2)
 check(double_hp==b.enemies[0].hp,"Area move with only one living target uses full single-target damage, not 0.75")
 b.finish("escaped");d.finish("escaped")
 a=owner();d=doubles(a);moves(a.team[0],["quick-attack"]);d.field.set_terrain("psychic");d.bind_ally(0,0,1);ally=a.team[1].hp;d.attack(0,0)
 check(a.team[1].hp<ally,"Psychic Terrain does not block priority attacking one's own ally")
 d.bind_pair(0,0);first=d.enemies[0].hp;d.attack(0,0);check(d.enemies[0].hp==first,"The same priority attack is blocked against grounded opponent")
 d.finish("escaped")
 a=owner();d=doubles(a);moves(a.team[0],["rock-slide"]);var partial_miss:=false
 for seed_value: int in range(1,50):
  d.enemies[0].hp=122;d.enemies[1].hp=122;d.rng.seed=seed_value;a.team[0].moves[0].pp=10;d.attack(0,0)
  if (d.enemies[0].hp<122)!=(d.enemies[1].hp<122):partial_miss=true;break
 check(partial_miss,"Area accuracy is rolled separately: one target can dodge while the other is hit")
 d.finish("escaped")
 a=owner();d=doubles(a)
 for entry: Dictionary in a.team[0].moves:entry.pp=0
 check(d.valid_command({"kind":"move","slot":-1,"target":0}) and not d.valid_command({"kind":"move","slot":-1,"target":1,"target_side":0}),"Struggle remains available with empty PP but cannot be aimed at ally")
 d.finish("escaped")
 a=owner();b=Battle.new();b.begin(a,[Mon.make("raticate",50,900000)],"weather-test");moves(b.enemies[0],["protect"])
 b.execute({"kind":"move","slot":1})
 check(b.events.any(func(e: Dictionary):return e.en=="Protect failed.") and b.protect_chain.has(900000) and not b.protect_chain.has(1),"Slower Protect in singles fails when opponent already acted, even on first use")
 b.finish("escaped")
 a=owner();d=doubles(a);moves(d.enemies[0],["protect"]);moves(d.enemies[1],["protect"])
 d.execute({"kind":"move","slot":1});d.execute({"kind":"move","slot":1})
 check(d.events.filter(func(e: Dictionary):return e.en=="Protect failed.").size()==1 and not d.protect_chain.has(1),"Four Protect users: exactly last live actor fails, three earlier users succeed")
 d.finish("escaped")
 print("TACTICS SYSTEMS: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
