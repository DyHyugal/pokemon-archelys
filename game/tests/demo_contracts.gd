extends SceneTree
const State=preload("res://scripts/domain/demo_state.gd")
const Transport=preload("res://scripts/services/showdown_transport.gd")
const Adapter=preload("res://scripts/services/showdown_battle.gd")
const Mon=preload("res://scripts/domain/pokemon.gd")
var checks:=0
var failures:=0
func check(ok: bool,label: String) -> void:
 checks+=1
 if not ok:failures+=1;push_error(label)
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var s:=State.new();var path: String="user://tests_demo_contracts.json"
 check(s.save(path)==ERR_BUSY,"No save before starter choice")
 check(not s.choose("mewtwo") and s.choose("squirtle") and not s.choose("bulbasaur"),"Only one legal starter")
 check(s.save(path)==OK,"Fresh starter campaign saves")
 var original: Dictionary=s.snapshot()
 for id: String in State.LOCATIONS:
  check(s.travel(id) and State.validate(s.snapshot()),"Each real destination creates valid save: "+id)
 check(s.save(path)==OK and State.validate(JSON.parse_string(FileAccess.get_file_as_string(path+".backup"))),"Atomic save retains valid previous backup")
 var clone:=State.new();check(clone.restore(original) and clone.snapshot()==original,"Complete round trip")
 for field: String in ["position","flags","location","starter"]:
  var bad: Dictionary=original.duplicate(true)
  bad[field]={"position":[0,1,0],"flags":{"complete":true},"location":"unknown","starter":"missing"}[field]
  check(not clone.restore(bad) and clone.snapshot()==original,"Malformed state rejected without mutation: "+field)
 var bad: Dictionary=original.duplicate(true);bad.campaign.adventure.exploration.location="isle-shop"
 check(not State.validate(bad),"World and campaign location must agree")
 var battle:=Adapter.new();clone.campaign.adventure.team[0].hp=0
 check(not battle.begin(clone.campaign.adventure,[Mon.make("rattata",5,900000)]) and not battle.last_error.is_empty() and battle.transport==null,"All-KO team rejected before runtime launch")
 clone.campaign.adventure.heal_team()
 check(battle.begin(clone.campaign.adventure,[Mon.make("rattata",5,900000)]),"Actual runtime launches")
 if battle.transport!=null:
  var expected: String=OS.get_executable_path().get_base_dir() if OS.has_feature("template") else ProjectSettings.globalize_path("res://../builds")
  check(battle.transport.runtime_base==expected,"Runtime resolves beside exported executable")
  var deadline: int=Time.get_ticks_msec()+12000
  while battle.busy and Time.get_ticks_msec()<deadline:await create_timer(.01).timeout
  check(not battle.busy and battle.last_error.is_empty() and not battle.available_moves(0).is_empty(),"Real simulator returns legal turn request")
  battle.finish("escaped")
 check(not clone.campaign.adventure.in_battle,"Simulator shutdown unlocks campaign")
 print("DEMO CONTRACTS: %d checks, %d failures; template=%s standalone=%s" % [checks,failures,OS.has_feature("template"),OS.has_feature("standalone")]);quit(1 if failures else 0)
