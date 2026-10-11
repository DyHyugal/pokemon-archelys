extends SceneTree
const Adventure=preload("res://scripts/domain/solo_adventure.gd")
const Mon=preload("res://scripts/domain/pokemon.gd")
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
const Battle=preload("res://scripts/domain/pokemon_battle.gd")
const Doubles=preload("res://scripts/domain/double_battle.gd")
const Campaign=preload("res://scripts/domain/campaign.gd")
const Store=preload("res://scripts/services/save_store.gd")
const Field=preload("res://scripts/domain/battle_field.gd")
var checks: int=0
var failures: int=0
func check(ok: bool,label: String) -> void:
	checks+=1
	if not ok:failures+=1;push_error(label)
func owner() -> RefCounted:
	var a:=Adventure.new();a.initialize();return a
func sun_team() -> Array:
	var foes: Array=[Mon.make("ninetales",36,900000),Mon.make("venusaur",36,900001),Mon.make("vulpix",36,900002)]
	foes[0].ability="drought";foes[1].ability="chlorophyll";foes[2].ability="drought";return foes
func _initialize() -> void:
	check(Mon.experience(50,"slow")==156250 and Mon.experience(50,"fast")==100000,"Slow and fast growth use independent known level-50 fixtures")
	var a:=owner();var before: Dictionary=a.snapshot()
	check(not a.purchase("potion",0) and not a.purchase("unknown",1) and not a.purchase("thunder-stone",2) and a.snapshot()==before,"Invalid and unaffordable purchases preserve money and bag")
	check(a.purchase("potion",5) and a.money==2000 and a.bag.potion==15,"Five potions debit exact laboratory price")
	check(a.purchase("potion",1,true) and a.money==2100 and a.bag.potion==14,"Selling consumes exact quantity at half price")
	a.bag.potion=999;before=a.snapshot();check(not a.purchase("potion",1) and a.snapshot()==before,"Bag capacity cannot debit money")
	check(not a.travel("cove",true),"Unvisited Fly destination blocked")
	check(a.travel("cove") and not a.travel("village",true),"Walking records visit but does not grant Fly")
	a.victories["trainer-1"]=true;check(a.travel("village",true),"Story flag permits Fly without any Flying-type party member")
	check(a.exploration.field_unlocked("flash",{}) and a.exploration.field_unlocked("fish",{}) and not a.exploration.field_unlocked("surf",{}),"Flash/fishing available early, Surf requires story flag")
	check(a.exploration.field_unlocked("surf",a.victories) and a.exploration.field_unlocked("climb",a.victories),"Field unlocks depend on story rather than party compatibility")
	a=owner();a.exploration.cap_enabled=false;a.gain_experience(1,50000);var level: int=a.team[0].level
	check(level>10,"Cap OFF permits experience beyond stored cap")
	a.exploration.cap_enabled=true;before=a.team[0].duplicate(true);a.gain_experience(1,50000)
	check(a.team[0]==before and a.cap==10,"Re-enabling cap neither lowers levels nor banks experience")
	a.raise_cap(100);a.gain_experience(1,50000);check(a.team[0].level>level,"Experience resumes after cap overtakes prior level")
	a=owner();check(a.set_ability(1,"chlorophyll") and not a.set_ability(1,"drought"),"Only actual species ability choices accepted")
	check(a.teach_machine(1,"sunny-day",0) and Mon.validate(a.team[0]),"Reusable legal TM remains valid in saves")
	check(not a.teach_machine(1,"electric-terrain",0),"Incompatible TM cannot silently become legal")
	check(Catalog.legal_species("magikarp",25)=="gyarados" and Catalog.legal_species("gyarados",10)=="magikarp","Fishing respects both upward and downward evolution legality")
	a.exploration.shiny_odds=1;var wild: Dictionary=a.wild(10,"magikarp");a.exploration.shiny_odds=4096
	check(wild.shiny and Mon.validate(wild),"Shiny generated at encounter creation remains fixed after option changes")
	var field:=Field.new();field.set_weather("sun");field.set_terrain("electric")
	check(is_equal_approx(field.power("fire",true,true),1.5) and is_equal_approx(field.power("water",true,true),0.5),"Sun modifies Fire/Water power by actual rule")
	check(is_equal_approx(field.power("electric",true,true),1.3) and field.power("electric",false,true)==1.0,"Terrain boost applies only to grounded attacker")
	field.set_terrain("misty");check(field.power("dragon",true,true)==0.5 and field.power("dragon",true,false)==1.0,"Misty reduction applies only to grounded defender")
	for i: int in range(4):field.tick()
	check(field.weather=="sun" and field.weather_turns==1,"Weather persists through fourth global turn")
	field.tick();check(field.weather=="" and field.terrain=="","Weather and terrain expire after five global turns")
	a=owner();a.team[0]=Mon.make("bulbasaur",36,1);a.exploration.difficulty="hard";var b:=Battle.new()
	check(b.begin(a,sun_team(),"weather-test") and b.field.weather=="sun","Drought triggers entry weather")
	var command:=b.choose_enemy_command();check(command.kind=="switch" and command.index==1,"Setter switches to beneficiary after completing role")
	var hidden: Dictionary=a.team[0].duplicate(true);a.team[0].iv=[31,31,31,31,31,31];a.team[0].ev=[0,0,252,0,252,0];a.team[0].moves=[{"id":"hydro-pump","pp":5}]
	check(b.choose_enemy_command()==command,"Hard AI choice is independent of hidden player IV/EV and unrevealed moves")
	a.team[0]=hidden;b.switch_enemy(1);b.field.weather="";b.field.weather_turns=0
	command=b.choose_enemy_command();check(command.kind=="switch" and command.index==0,"Missing weather sends living setter before next damage dealer")
	b.enemies[0].hp=0;command=b.choose_enemy_command();check(command.kind=="switch" and command.index==2,"Second setter renews weather after first setter fainted")
	b.finish("won");check(not a.in_battle,"Support test ends without locking party")
	a=owner();a.exploration.difficulty="hard";b=Battle.new();var electric: Array=[]
	for id: String in ["raichu","pikachu","raichu"]:electric.append(Mon.make(id,36,900000+electric.size()))
	for i: int in [0,2]:electric[i].moves[0]={"id":"electric-terrain","pp":10}
	check(b.begin(a,electric,"terrain-test"),"Electric terrain test team is legal")
	command=b.choose_enemy_command();check(command.kind=="move" and command.slot==0,"Setter prioritizes absent Electric Terrain over non-KO attacks")
	b.attack(1,0);command=b.choose_enemy_command();check(b.field.terrain=="electric" and command.kind=="switch" and command.index==1,"Electric setter hands off once terrain exists")
	b.switch_enemy(1);b.field.terrain="";b.enemies[0].hp=0;command=b.choose_enemy_command()
	check(command.kind=="switch" and command.index==2,"Expired Electric Terrain sends second setter, not a beneficiary")
	b.field.set_terrain("electric");check(not b.apply_status(0,"sleep"),"Electric Terrain prevents sleep for grounded target")
	b.field.set_terrain("misty");check(not b.apply_status(0,"burn"),"Misty Terrain prevents grounded status")
	b.finish("won")
	a=owner();a.team=[Mon.make("charizard",36,1),Mon.make("venusaur",36,2)];a.next_uid=3;a.team[0].item="charizardite-y";a.team[1].item="venusaurite"
	b=Battle.new();b.begin(a,[Mon.make("rattata",36,900000)],"weather-test")
	var old_stats:=Mon.stats(a.team[0]);check(b.mega(0) and Mon.stats(a.team[0]).special_attack>old_stats.special_attack and b.field.weather=="sun","Mega Y uses actual form stats and Drought")
	b.switch_player(1);check(not b.can_mega(0),"One Mega budget applies across all team members")
	b.finish("won");check(not a.team[0].has("battle_form") and Mon.stats(a.team[0])==old_stats and Adventure.validate(a.snapshot()),"Transient Mega cleaned before save with original stats restored")
	a=owner();check(a.exploration.enable_challenge() and not a.exploration.enable_challenge(),"Challenge activation is explicit and cannot reset quotas")
	a.team[0].hp=0;a.exploration.record_deaths(a.team);a.heal_team()
	check(a.team[0].hp==0 and not a.use("potion",1),"Center and medicine cannot resurrect dead challenge Pokémon")
	check(not a.exploration.game_over(a.team,a.boxes),"One KO does not trigger game over while another survivor exists")
	for mon: Dictionary in a.team:mon.hp=0
	a.exploration.record_deaths(a.team);a.boxes.append(Mon.make("magikarp",10,a.next_uid));a.next_uid+=1
	check(not a.exploration.game_over(a.team,a.boxes),"Living PC Pokémon prevents challenge game over")
	a.boxes[0].hp=0;a.exploration.record_deaths(a.boxes);check(a.exploration.game_over(a.team,a.boxes),"Game over requires party AND PC without survivors")
	check(a.exploration.retire_challenge() and not a.exploration.enable_challenge(),"Retiring challenge prevents reactivation")
	a.heal_team();check(a.team.all(func(mon: Dictionary):return mon.hp>0),"Normal continuation permits healing after retired challenge")
	a=owner();a.exploration.enable_challenge();b=Battle.new();b.begin(a,[Mon.make("magikarp",10,900000)])
	check(b.valid_command({"kind":"ball","item":"poke-ball"}),"First eligible zone encounter permits capture")
	b.finish("escaped");b=Battle.new();b.begin(a,[Mon.make("magikarp",10,900001)])
	check(not b.valid_command({"kind":"ball","item":"poke-ball"}),"Failed or escaped zone encounter consumes quota")
	b.finish("escaped");var shiny:=Mon.make("magikarp",10,900002);shiny.shiny=true;b=Battle.new();b.begin(a,[shiny])
	check(b.valid_command({"kind":"ball","item":"poke-ball"}),"Shiny clause permits capture outside used quota")
	b.finish("escaped");a.exploration.enter("cove");b=Battle.new();b.begin(a,[Mon.make("ivysaur",16,900003)])
	check(not a.exploration.claims.has("cove"),"Owned family duplicate is ignorable and does not consume fresh zone")
	b.finish("escaped")
	a=owner();a.exploration.enable_challenge();b=Battle.new();b.begin(a,[Mon.make("gyarados",30,900000)]);b.rng.seed=2
	check(not b.try_capture("poke-ball") and a.exploration.claims.village.result=="failed" and not b.valid_command({"kind":"ball","item":"poke-ball"}),"Failed first Ball consumes Nuzlocke quota immediately")
	b.finish("escaped")
	a=owner();b=Battle.new();b.begin(a,[Mon.make("rattata",8,900000)]);b.field.set_terrain("psychic");a.team[0].moves=[{"id":"quick-attack","pp":30}];var target_hp: int=b.current(1).hp;b.attack(0,0)
	check(b.current(1).hp==target_hp and a.team[0].moves[0].pp==29,"Psychic Terrain prevents grounded priority damage and consumes PP")
	b.finish("escaped")
	a=owner();a.team=[Mon.make("charizard",36,1),Mon.make("charizard",36,2)];a.team[0].item="charizardite-x";a.team[1].item="charizardite-y";a.next_uid=3;b=Battle.new();b.begin(a,[Mon.make("rattata",36,900000)],"weather-test");b.mega(0);a.team[0].hp=0;b.switch_player(1)
	check(not b.can_mega(0),"Fainted Mega cannot refund one-Mega budget")
	b.finish("lost")
	a=owner();var one:=Doubles.new();a.team[1].hp=0;a.team[2].hp=0
	check(not one.begin(a,[Mon.make("rattata",8,900000),Mon.make("pikachu",8,900001)]) and not a.in_battle,"Double battle refuses one survivor without locking adventure")
	a=owner();a.team[0]=Mon.make("charmander",36,1);var fox:=Mon.make("vulpix",36,900000);b=Battle.new();b.begin(a,[fox]);a.team[0].moves=[{"id":"ember","pp":25}];var hp_before: int=b.current(1).hp;var fire_before: int=b.damage(1,Catalog.move("ember"));b.attack(0,0)
	check(b.current(1).hp==hp_before and b.damage(1,Catalog.move("ember"))>fire_before,"Flash Fire absorbs Fire and enables its offensive boost")
	b.finish("escaped")
	a=owner();var pika:=Mon.make("pikachu",36,900000);pika.ability="lightning-rod";b=Battle.new();b.begin(a,[pika]);a.team[0].moves=[{"id":"thunderbolt","pp":15}];hp_before=b.current(1).hp;b.attack(0,0)
	check(b.current(1).hp==hp_before and b.stages[1].special_attack==1,"Lightning Rod absorbs Electric and boosts Special Attack")
	b.finish("escaped")
	a=owner();a.team[0].ability="chlorophyll";b=Battle.new();b.begin(a,[Mon.make("magikarp",10,900000)]);var speed_before: float=b.stat(1,"speed");b.field.set_weather("rain")
	check(b.stat(1,"speed")==speed_before*2,"Swift Swim doubles actual speed in rain")
	b.finish("escaped")
	a=owner();a.team[2].ability="rain-dish";b=Battle.new();b.begin(a,[Mon.make("magikarp",10,900000)]);b.switch_player(2);b.field.set_weather("rain");a.team[2].hp=1;b.end_turn()
	check(a.team[2].hp>1,"Rain Dish heals during residual phase")
	b.finish("escaped")
	a=owner();b=Battle.new();b.begin(a,[Mon.make("gyarados",20,900000)]);check(b.stages[0].attack==-1,"Intimidate applies entry Attack drop")
	b.finish("escaped")
	a=owner();var intimidate_double:=Doubles.new();intimidate_double.begin(a,[Mon.make("gyarados",20,900000),Mon.make("magikarp",20,900001)]);intimidate_double.bind_pair(0,0);var stage_first: int=int(intimidate_double.stages[0].get("attack",0));intimidate_double.bind_pair(1,0)
	check(stage_first==-1 and intimidate_double.stages[0].get("attack",0)==-1,"Double Intimidate targets both opponents and survives pair binding")
	intimidate_double.finish("won")
	# Schema3 migration keeps all prior party/inventory and preserves original file.
	var campaign:=Campaign.new();campaign.add_player(1,"Test");campaign.adventure=owner()
	var old:=campaign.snapshot();old.schema=3;old.adventure.erase("exploration")
	check(campaign.restore(old) and campaign.adventure.team.size()==3 and campaign.adventure.exploration.location=="village","Old schema3 migrates to default exploration state")
	var path:="user://tests_schema4.json"
	for suffix: String in ["",".backup",".v3.backup",".tmp"]:DirAccess.remove_absolute(path+suffix)
	Store.write_snapshot(path,old);var bytes:=FileAccess.get_file_as_string(path);campaign.adventure.exploration.enter("shop")
	check(Store.write_snapshot(path,campaign.snapshot())==OK and FileAccess.get_file_as_string(path+".v3.backup")==bytes,"Migration preserves schema3 original bytes before overwrite")
	var restored:=Campaign.new();check(restored.restore(Store.read_snapshot(path)) and restored.adventure.exploration.location=="shop","Interior location survives disk save/load")
	var corrupt:=restored.snapshot();corrupt.adventure.exploration.visited.append("unknown");before=restored.snapshot()
	check(not restored.restore(corrupt) and restored.snapshot()==before,"Malformed new state rejected before existing campaign mutation")
	# Multiple switches and targeting must not act with old or fainted actors.
	a=owner();var speed_test:=Doubles.new();speed_test.begin(a,[Mon.make("rattata",2,900000),Mon.make("rattata",2,900001)])
	speed_test.enemies[0].hp=1;speed_test.enemies[1].hp=1
	a.team[0].moves=[{"id":"quick-attack","pp":30}];a.team[1].moves=[{"id":"quick-attack","pp":30}]
	speed_test.execute({"kind":"move","slot":0,"target":0});speed_test.execute({"kind":"move","slot":0,"target":1})
	check(speed_test.result=="won" and not a.in_battle and speed_test.enemies.all(func(mon: Dictionary):return mon.hp==0),"Four-actor turn cancels fainted enemies and ends with both targets defeated")
	# Four actors share one turn, each player command queued before execution.
	a=owner();var d:=Doubles.new();check(d.begin(a,[Mon.make("rattata",8,900000),Mon.make("pikachu",8,900001)]),"Actual two-on-two starts with two ready party members")
	var pp0: int=a.team[0].moves[0].pp;var pp1: int=a.team[1].moves[0].pp
	check(d.execute({"kind":"move","slot":0,"target":0}) and d.turn==0 and a.team[0].moves[0].pp==pp0,"First double action waits; no premature PP use or enemy turn")
	check(d.execute({"kind":"move","slot":0,"target":1}) and d.turn==1 and a.team[0].moves[0].pp==pp0-1 and a.team[1].moves[0].pp==pp1-1,"Both queued actions execute in one global double turn")
	check(d.field.weather_turns==0 and a.in_battle,"Double simulation remains active and preserves battle lock")
	d.field.set_weather("sun");d.execute({"kind":"move","slot":0,"target":0});d.execute({"kind":"move","slot":0,"target":1});check(d.field.weather_turns==4,"Double battle decrements weather once per four-actor turn")
	d.finish("won");a=owner();d=Doubles.new();d.begin(a,[Mon.make("rattata",8,900000),Mon.make("pikachu",8,900001)])
	check(d.execute({"kind":"switch","index":2}) and not d.valid_command({"kind":"switch","index":2}),"Two double slots cannot reserve the same incoming Pokémon")
	d.finish("won")
	print("EXPLORATION COMBAT: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
