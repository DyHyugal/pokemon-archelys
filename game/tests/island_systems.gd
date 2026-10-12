extends SceneTree
const Adventure=preload("res://scripts/domain/solo_adventure.gd")
const Island=preload("res://scripts/domain/island.gd")
const Mon=preload("res://scripts/domain/pokemon.gd")
const World=preload("res://scripts/domain/world_rules.gd")
var checks:=0
var failures:=0
func check(ok: bool,label: String) -> void:
 checks+=1
 if not ok:failures+=1;push_error(label)
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var a:=Adventure.new();a.initialize();var original: Dictionary=a.snapshot()
 check(not a.travel("isle-port"),"Island cannot be entered before prototype starts")
 check(a.island.start(a) and not a.island.start(a) and a.team==original.team,"Start once without resetting party")
 check(a.travel("isle-port") and not a.travel("isle-base") and not a.travel("isle-jungle"),"Arrival respects adjacency/story gates")
 check(a.island.accept_quest(a) and not a.island.accept_quest(a),"Optional quest accepted once at haven")
 var balls: int=int(a.bag['poke-ball'])
 check(a.island.cache(a,"port-cache") and not a.island.cache(a,"port-cache") and a.bag['poke-ball']==balls+5,"Supply cache gives fixed items once")
 a.records.scenes['isle-arrival']=true
 var foes: Array=a.island.opponents(a,"isle-checkpoint")
 check(foes.size()==2 and foes.all(func(m: Dictionary):return Mon.validate(m)),"Checkpoint team legal and data driven")
 check(a.island.won(a,"isle-checkpoint") and a.cap==14,"First boss raises cap")
 var money: int=a.money;check(not a.island.won(a,"isle-checkpoint") and a.money==money,"Repeated victory cannot duplicate reward")
 check(a.travel("isle-jungle") and not a.travel("isle-caldera"),"Jungle opens but both relays required")
 check(a.island.collect(a,"sample-a") and not a.island.collect(a,"sample-a"),"Survey cannot duplicate")
 check(a.island.relay(a,"relay-east") and not a.island.relay(a,"relay-east") and not a.travel("isle-shrine"),"One relay is insufficient")
 check(a.island.relay(a,"relay-west") and a.travel("isle-shrine"),"Relays work in either order and open shrine")
 foes=a.island.opponents(a,"isle-keeper")
 check(foes.size()==3 and foes[1].species=="ivysaur" and foes[2].species=="wartortle" and foes.all(func(m: Dictionary):return Mon.validate(m)),"Keeper adapts legal stages and weather abilities")
 check(a.island.won(a,"isle-keeper") and a.cap==18,"Keeper establishes next cap")
 check(a.travel("isle-jungle") and a.travel("isle-caldera") and a.travel("isle-cave") and a.travel("isle-base"),"Connected route reaches outpost after keeper")
 check(not a.island.can_battle(a,"isle-admin-b") and not a.island.won(a,"isle-admin-b"),"Second admin cannot complete before first")
 check(a.island.won(a,"isle-admin-a") and a.cap==22 and a.island.won(a,"isle-admin-b") and a.cap==22,"Admins share event cap rather than stacking +2")
 check(not a.island.liberate(a),"Liberation requires manual scene completion")
 a.records.scenes['isle-liberation']=true
 check(a.island.liberate(a) and not a.island.liberate(a),"Liberation recorded once")
 check(a.travel("isle-jungle",true) and not a.travel("isle-shop",true),"Fly only visited outdoor island locations")
 for id: String in ["sample-b","sample-c"]:check(a.island.collect(a,id),"Remaining survey collected: "+id)
 check(a.travel("isle-port",true),"Visited haven can be reached without compatible Pokémon")
 var uid: int=a.next_uid
 check(a.island.gift(a)=="team" and a.next_uid==uid+1 and a.island.gift(a)=="unavailable","Quest companion received exactly once")
 check(Adventure.validate(a.snapshot()),"Completed island campaign validates")
 var reload:=Adventure.new()
 check(reload.restore(JSON.parse_string(JSON.stringify(a.snapshot()))) and reload.island.snapshot()==a.island.snapshot(),"JSON persistence retains island stages/surveys/caches")
 var old: Dictionary=original.duplicate(true);old.erase("island")
 check(reload.restore(old) and reload.island.flags.is_empty(),"Legacy campaign gets empty proposed chapter without reset")
 var corrupt: Dictionary=a.snapshot();corrupt.island.flags.erase("admin-a")
 check(not Adventure.validate(corrupt),"Broken dependency chain rejected")
 corrupt=a.snapshot();corrupt.island.collected['invented']=true
 check(not Adventure.validate(corrupt),"Unknown quest survey rejected")
 a.cap=100;a.island.flags.erase("admin-b");a.island.flags.erase("liberated");a.exploration.enter("isle-base")
 check(a.island.won(a,"isle-admin-b") and a.cap==100,"Existing higher cap never lowered by prototype")
 for location: String in Island.LOCATIONS:
  check(World.local_points(location)==Island.points(location) and World.local_walkable(Vector2(0,9),location),"Shared interactions/safe spawn: "+location)
  check(not World.local_walkable(Vector2(15,0),location),"Authoritative bounds: "+location)
 # Flood fill proves every interaction can be approached using authoritative
 # walking rules, rather than teleporting through geometry in the scene test.
 for location: String in Island.LOCATIONS:
  var queue: Array=[Vector2(0,9)];var reachable: Dictionary={Vector2(0,9):true};var index:=0
  while index<queue.size():
   var point: Vector2=queue[index];index+=1
   for direction: Vector2 in [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]:
    var next: Vector2=point+direction
    if not reachable.has(next) and World.local_walkable(next,location):reachable[next]=true;queue.append(next)
  for id: String in Island.points(location):
   var target: Vector3=Island.points(location)[id]
   check(reachable.keys().any(func(p: Vector2):return p.distance_to(Vector2(target.x,target.z))<=2.2),"Walking path reaches "+location+"/"+id)
 check(not World.local_walkable(Vector2(0,0),"isle-caldera") and World.local_walkable(Vector2(6,0),"isle-caldera"),"Lava blocks center, side paths walkable")
 for location: String in ["isle-jungle","isle-caldera","isle-cave"]:
  a.exploration.enter(location)
  for i: int in range(6):
   var mon: Dictionary=Island.wild(a);check(Mon.validate(mon) and mon.species==preload("res://scripts/domain/pokemon_catalog.gd").legal_species(mon.species,mon.level),"Biome encounter legal: "+location)
 a.exploration.enter("isle-port");a.island.caches.erase("port-cache");a.bag['poke-ball']=999;var before: Dictionary=a.snapshot()
 check(not a.island.cache(a,"port-cache") and a.snapshot()==before,"Full bag rejects cache atomically")
 a.in_battle=true;before=a.snapshot()
 check(not a.island.cache(a,"port-cache") and not a.island.gift(a) in ["team","pc"] and a.snapshot()==before,"Battle blocks acquisitions")
 a.in_battle=false;a.island.flags.erase("gift");a.exploration.enter("isle-port")
 while a.team.size()<6:a.add(Mon.make("squirtle",8,a.next_uid))
 while a.boxes.size()<240:a.add(Mon.make("squirtle",8,a.next_uid))
 before=a.snapshot()
 check(a.island.gift(a)=="full" and a.snapshot()==before,"Full party/PC reject companion without losing claim or identity")
 a.boxes.pop_back()
 check(a.island.gift(a)=="pc" and a.island.flags.has("gift") and a.boxes.size()==240,"Gift goes to newly available PC slot once")
 check(Adventure.validate(a.snapshot()),"Full PC gift still creates valid storage map and campaign")
 check("isle-cave" in preload("res://scripts/domain/journey_records.gd").habitats("kabuto") and "isle-caldera" in preload("res://scripts/domain/journey_records.gd").habitats("charmeleon"),"Dex biome locations derive from actual legal encounter pools")
 print("ISLAND SYSTEMS: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
