extends SceneTree
const Adapter=preload("res://scripts/services/showdown_battle.gd")
const Adventure=preload("res://scripts/domain/solo_adventure.gd")
const Mon=preload("res://scripts/domain/pokemon.gd")
var checks: int=0
var failures: int=0
func check(value: bool,label: String) -> void:
 checks+=1
 if not value:failures+=1;push_error(label)
func settle(battle: RefCounted) -> void:
 var deadline: int=Time.get_ticks_msec()+12000
 while battle.busy and Time.get_ticks_msec()<deadline:await create_timer(0.01).timeout
 check(not battle.busy,"Asynchronous response completes within deadline")
func owner() -> RefCounted:
 var a:=Adventure.new();a.initialize();a.cap=100;a.team=[Mon.make("blastoise",50,1),Mon.make("venusaur",50,2),Mon.make("charizard",50,3)];a.next_uid=4
 for mon: Dictionary in a.team:a.records.observe(mon.species,true)
 return a
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var a:=owner();a.team[0].hp=50;a.team[0].moves=[{"id":"surf","pp":3},{"id":"protect","pp":10}]
 a.team[1].hp=20
 # Harmless opponent isolates the item/PP boundary from random combat KOs.
 var opponent: Dictionary=Mon.make("magikarp",100,900000);opponent.moves=[{"id":"splash","pp":40}]
 var b:=Adapter.new();check(b.begin(a,[opponent]),"Real packaged bridge starts")
 var pid: int=int(b.transport.child.pid)
 var frames: int=0
 while b.busy and frames<200:frames+=1;await create_timer(0.01).timeout
 check(frames>0 and not b.busy and b.last_error.is_empty(),"Main scene keeps ticking while worker waits")
 check(a.team[0].hp==50 and a.team[0].moves[0].pp==3,"Damaged HP and depleted PP imported without healing")
 var count: int=int(a.bag.potion)
 check(b.execute({"kind":"item","item":"potion","index":1}),"Bench potion sent to simulator")
 check(int(a.bag.potion)==count,"Bag not spent before acknowledgement")
 await settle(b)
 check(a.team[1].hp==40 and int(a.bag.potion)==count-1 and a.team[0].moves[0].pp==3,"Acknowledged item updates bench, bag and costs action only")
 check(b.execute({"kind":"move","slot":0}),"Real attack accepted");await settle(b)
 check(a.team[0].moves[0].pp==2 and b.turn==2,"Adapter maps move and global turn from simulator")
 b.finish("escaped")
 check(not a.in_battle and (OS.get_name()!="Linux" or not DirAccess.dir_exists_absolute("/proc/"+str(pid))),"Exit unlocks campaign and terminates process")
 check(Adventure.validate(a.snapshot()),"Campaign save remains valid after real combat")
 # A crash rolls back all battle mutations, including resources spent earlier.
 a=owner();a.team[0].moves=[{"id":"protect","pp":10}]
 var before: Dictionary=a.snapshot();b=Adapter.new();check(b.begin(a,[Mon.make("raticate",50,900000)]),"Second independent battle starts")
 await settle(b);pid=int(b.transport.child.pid)
 check(b.execute({"kind":"move","slot":0}),"Second battle has real pending action")
 OS.kill(pid);await settle(b)
 check(not b.active and b.result=="cancelled" and a.snapshot()==before and not a.in_battle,"Simulator crash restores complete pre-battle snapshot")
 # Two simultaneous fainted slots with one reserve: actual engine, not a fabricated request.
 a=owner();a.team[0].hp=1;a.team[1].hp=1
 a.team[0].moves=[{"id":"withdraw","pp":40}];a.team[1].moves=[{"id":"growth","pp":20}]
 var foes: Array=[Mon.make("raichu",50,900000),Mon.make("raticate",50,900001)]
 foes[0].moves=[{"id":"thunderbolt","pp":15}];foes[1].moves=[{"id":"quick-attack","pp":30}]
 b=Adapter.new();b.double_mode=true
 check(b.begin(a,foes),"Doubles starts with all identities");await settle(b)
 check(b.execute({"kind":"move","slot":0}) and b.execute({"kind":"move","slot":0}),"Two choices resolve in real double battle");await settle(b)
 check(a.team[0].hp==0 and a.team[1].hp==0 and b.replacement_needed(),"Both active slots faint, one reserve remains")
 check(b.replace_fainted(2),"Sole reserve submitted with pass for unavailable replacement");await settle(b)
 check(b.last_error.is_empty() and not b.replacement_needed() and b.current(0).uid==3,"Legal partial replacement completes without deadlock")
 b.finish("escaped")
 # Trainer completion awards campaign progression once and preserves consumptions.
 a=owner();a.cap=10;before=a.snapshot()
 var weak: Dictionary=Mon.make("rattata",8,900000);weak.hp=1
 a.team[0].moves=[{"id":"surf","pp":15}]
 b=Adapter.new();check(b.begin(a,[weak],"trainer-1"),"Story trainer uses Showdown too");await settle(b)
 check(b.execute({"kind":"move","slot":0}),"Winning command accepted");await settle(b)
 check(b.result=="won" and not a.in_battle and a.victories.has("trainer-1") and a.cap==18 and a.money==int(before.money)+300,"Victory commits cap, flag and money once")
 check(a.team[0].moves[0].pp==14 and Adventure.validate(a.snapshot()),"Victory leaves a valid save with depleted PP")
 b.finish("won");check(a.money==int(before.money)+300,"Repeated finish cannot duplicate reward")
 # Missing runtime must not alter the campaign or silently use a different engine.
 var node_path: String=OS.get_environment("ARCHELYS_NODE_BIN")
 OS.set_environment("ARCHELYS_NODE_BIN","/missing/archelys-node")
 a=owner();before=a.snapshot();b=Adapter.new()
 check(not b.begin(a,[Mon.make("raticate",50,900000)]) and a.snapshot()==before and not a.in_battle,"Missing runtime refuses battle without campaign mutation")
 OS.set_environment("ARCHELYS_NODE_BIN",node_path)
 print("SHOWDOWN INTEGRATION: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
