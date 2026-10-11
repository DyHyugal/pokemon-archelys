extends SceneTree
const Adventure=preload("res://scripts/domain/solo_adventure.gd")
const Mon=preload("res://scripts/domain/pokemon.gd")
const Storage=preload("res://scripts/domain/storage.gd")
const Adapter=preload("res://scripts/services/showdown_battle.gd")
var checks:=0
var failures:=0
func check(value: bool,message: String) -> void:
 checks+=1
 if not value:failures+=1;push_error(message)
func _initialize() -> void:call_deferred("run")
func wait_for(b: RefCounted) -> void:
 var deadline: int=Time.get_ticks_msec()+12000
 while b.busy and Time.get_ticks_msec()<deadline:await create_timer(0.01).timeout
 check(not b.busy and b.last_error.is_empty(),"Showdown response completes")
func run() -> void:
 var a:=Adventure.new();a.initialize();a.cap=100
 for i: int in range(3):a.add(Mon.make("squirtle",8,a.next_uid))
 a.add(Mon.make("blastoise",40,a.next_uid));a.add(Mon.make("pikachu",8,a.next_uid))
 var first: int=int(a.boxes[0].uid);var second: int=int(a.boxes[1].uid)
 check(a.storage_slots[str(first)]==0 and a.storage_slots[str(second)]==1,"New acquisition allocates first free PC slots")
 var original: Dictionary=a.find(first).duplicate(true)
 check(a.move_stored(first,239) and a.storage_slots[str(first)]==239 and a.find(first)==original,"Move to last box preserves whole individual")
 check(a.move_stored(second,239) and a.storage_slots[str(first)]==1 and a.storage_slots[str(second)]==239,"Occupied slot swaps positions instead of replacing Pokémon")
 var snapshot: Dictionary=a.snapshot();check(not a.move_stored(first,240) and not a.move_stored(first,-1) and not a.move_stored(999,0) and a.snapshot()==snapshot,"Invalid moves are atomic")
 a.find(first).hp=20;a.find(first).moves=[{"id":"surf","pp":3},{"id":"withdraw","pp":20}];a.find(first).item="leftovers"
 var outgoing: Dictionary=a.team[0].duplicate(true);var incoming: Dictionary=a.find(first).duplicate(true)
 check(a.exchange_with_party(first,0) and a.team.size()==6 and a.boxes.size()==2,"Full party exchanges directly with PC")
 check(a.team[0]==incoming and a.find(int(outgoing.uid))==outgoing and a.storage_slots[str(int(outgoing.uid))]==1,"Exchange preserves UID, HP/PP/held item and vacated slot")
 var danger:=Adventure.new();danger.initialize();danger.team[1].hp=0;danger.team[2].hp=0;danger.deposit(1);var boxed: int=int(danger.boxes[0].uid);snapshot=danger.snapshot()
 check(not danger.exchange_with_party(boxed,0) and danger.snapshot()==snapshot,"Cannot exchange sole healthy team member for fainted box member")
 snapshot=a.snapshot();a.in_battle=true
 check(not a.move_stored(second,0) and not a.exchange_with_party(second,0) and not a.reorder_moves(first,0,1),"All roster mutations locked during battle")
 a.in_battle=false;check(a.snapshot()==snapshot,"Rejected mutations preserve all campaign state")
 var restored:=Adventure.new();check(restored.restore(JSON.parse_string(JSON.stringify(a.snapshot()))) and restored.storage_slots==a.storage_slots and restored.team==a.team,"JSON restores slots, roster and individual conditions")
 var legacy: Dictionary=a.snapshot();legacy.erase("storage_slots")
 check(restored.restore(legacy) and restored.storage_slots[str(int(restored.boxes[0].uid))]==0 and restored.storage_slots.size()==restored.boxes.size(),"Legacy PC receives ordered slots without losing individuals")
 var invalid: Dictionary=a.snapshot();var keys: Array=invalid.storage_slots.keys();invalid.storage_slots[keys[1]]=invalid.storage_slots[keys[0]]
 check(not restored.restore(invalid),"Duplicate occupied slot rejected")
 invalid=a.snapshot();invalid.storage_slots[keys[0]]=0.5;check(not Adventure.validate(invalid),"Fractional slot rejected")
 invalid=a.snapshot();invalid.storage_slots.erase(keys[0]);check(not Adventure.validate(invalid),"Missing boxed UID slot rejected")
 invalid=a.snapshot();invalid.storage_slots["999999"]=2;check(not Adventure.validate(invalid),"Orphan slot rejected")
 invalid=a.snapshot();invalid.storage_slots[keys[0]]=240;check(not Adventure.validate(invalid),"Out-of-capacity slot rejected")
 snapshot=a.snapshot();a.withdraw(a.boxes.find(a.find(second))) # Team full, no change.
 check(a.snapshot()==snapshot,"Full party withdrawal leaves layout and roster intact")
 check(a.deposit(5) and a.withdraw(a.boxes.find(a.find(second))) and not a.storage_slots.has(str(second)),"Deposit/withdraw remove only matching UID mapping")
 var mon: Dictionary=a.find(first);var pp: int=int(mon.moves[0].pp)
 check(a.reorder_moves(first,0,1) and mon.moves[1].id=="surf" and mon.moves[1].pp==pp,"Move order follows its depleted PP")
 check(not a.teach_machine(first,"surf",0) and mon.moves[1].pp==pp,"Known move cannot reset PP through reusable TM")
 check(a.move_options(first,"machine").has("surf") and a.move_options(first,"reminder").has("water-gun") and not a.move_options(first,"invalid").size(),"Preparation options contain only requested legal sources")
 var preserved: Dictionary=mon.duplicate(true);var bag: Dictionary=a.bag.duplicate(true)
 check(a.relearn(first,"water-gun",0) and mon.hp==preserved.hp and mon.item==preserved.item and mon.moves[1]==preserved.moves[1] and a.bag==bag,"Reminder replaces one slot and preserves all other state")
 a.heal_team();mon.hp=20;mon.moves=[{"id":"surf","pp":3}]
 var opponent: Dictionary=Mon.make("magikarp",100,900000);opponent.moves=[{"id":"splash","pp":40}]
 var b:=Adapter.new();check(b.begin(a,[opponent]),"Prepared exchanged member enters actual Showdown");await wait_for(b)
 check(b.current(0).uid==first and b.current(0).moves[0].pp==3 and b.current(0).item=="leftovers","Simulator imports prepared identity, PP and equipment")
 check(b.execute({"kind":"move","slot":0}),"Prepared attack accepted");await wait_for(b)
 check(mon.moves[0].pp==2,"Real simulator consumption returns to same UID")
 b.finish("escaped");check(Adventure.validate(a.snapshot()),"Post-combat storage campaign remains valid")
 var full:=Adventure.new();full.initialize()
 while full.team.size()<6:full.add(Mon.make("rattata",8,full.next_uid))
 for i: int in range(240):full.add(Mon.make("rattata",8,full.next_uid))
 snapshot=full.snapshot();check(Storage.valid(full.storage_slots,full.boxes) and full.storage_slots.size()==240,"All eight boxes fill without collision")
 check(full.add(Mon.make("rattata",8,full.next_uid))=="full" and not full.deposit(0) and full.snapshot()==snapshot,"Full PC never discards an individual")
 print("STORAGE SYSTEMS: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
