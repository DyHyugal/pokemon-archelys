extends SceneTree
const Solo=preload("res://scripts/domain/solo_adventure.gd")
const Mon=preload("res://scripts/domain/pokemon.gd")
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
const Comfort=preload("res://scripts/services/comfort_store.gd")
const Battle=preload("res://scripts/domain/adventure_battle.gd")
var checks:=0
var failures:=0
func check(ok: bool,label: String) -> void:
 checks+=1
 if not ok:failures+=1;push_error(label)
func owner() -> RefCounted:
 var value:=Solo.new();value.initialize();return value
func key(code: int,pressed: bool) -> void:
 var event:=InputEventKey.new();event.physical_keycode=code;event.keycode=code;event.pressed=pressed;Input.parse_input_event(event);Input.flush_buffered_events()
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var path: String="user://tests_continuity_comfort.json";DirAccess.remove_absolute(path)
 var prefs:=Comfort.new(path)
 check(prefs.keys("run")==[KEY_SHIFT] and prefs.bind("run",KEY_R)==OK,"Sprint can be remapped and persisted")
 key(KEY_R,true);check(prefs.wants_run(),"Rebound physical key actually activates sprint");key(KEY_R,false)
 key(KEY_SHIFT,true);check(not prefs.wants_run(),"Old sprint key no longer activates sprint after rebind");key(KEY_SHIFT,false)
 check(Comfort.new(path).keys("run")==[KEY_R],"Sprint survives fresh preference read")
 var legacy: Dictionary=prefs.data.duplicate(true);legacy.keys={"left":KEY_SHIFT};legacy.erase("game_speed")
 check(Comfort.validate(legacy) and Comfort.effective_keys(legacy,"left")==[KEY_SHIFT] and Comfort.effective_keys(legacy,"run").is_empty(),"Legacy custom Shift remains valid without hijacking left movement")
 check(prefs.set_option("game_speed",4)==OK and Comfort.new(path).data.game_speed==4,"Game speed is a local persistent preference")
 var before: String=FileAccess.get_file_as_string(path)
 check(prefs.set_option("game_speed",5)==ERR_INVALID_DATA and FileAccess.get_file_as_string(path)==before,"Invalid speed leaves preferences intact")
 var pad:=InputEventJoypadButton.new();pad.device=0;pad.button_index=JOY_BUTTON_RIGHT_SHOULDER;pad.pressed=true;Input.parse_input_event(pad);Input.flush_buffered_events()
 check(prefs.wants_run(0),"Standard RB event activates sprint polling");pad=pad.duplicate();pad.pressed=false;Input.parse_input_event(pad);Input.flush_buffered_events()
 check(not prefs.wants_run(0),"Releasing RB stops sprint")
 var a: RefCounted=owner();a.bag.potion=999;var original: Dictionary=a.snapshot()
 check(not a.grant_items({"poke-ball":3,"potion":2}) and a.snapshot()==original,"Full batch reward is rejected atomically")
 check(not a.grant_items({"future-item":1}) and not a.grant_items({"potion":-1}) and a.snapshot()==original,"Invalid gifts do not mutate inventory")
 a.bag.potion=997;check(a.grant_items({"poke-ball":3,"potion":2}) and a.bag.potion==999,"Valid gift batch is delivered together")
 check(a.equip(1,"leftovers"),"Held-item fixture equipped")
 a.bag.leftovers=999;original=a.snapshot()
 check(not a.equip(1,"") and not a.equip(1,"lucky-egg") and a.snapshot()==original,"Unequip/exchange cannot overflow the returned item or spend the new item")
 a.bag.leftovers=998;check(a.equip(1,"lucky-egg") and a.bag.leftovers==999 and a.find(1).item=="lucky-egg","Valid held-item exchange refunds once")
 a=owner();var dragon: Dictionary=Mon.make("charizard",36,a.next_uid);a.add(dragon);a.equip(int(dragon.uid),"leftovers");a.bag.leftovers=999;original=a.snapshot()
 check(not a.grant_mega_kit() and a.snapshot()==original,"Mega kit rollback preserves roster, cap and items on impossible refund")
 a.bag.leftovers=998;check(a.grant_mega_kit() and a.find(int(dragon.uid)).item=="charizardite-y" and dragon.item=="charizardite-y" and a.bag.leftovers==999 and Solo.validate(a.snapshot()),"Mega kit succeeds after room is freed, preserving the same individual")
 original=a.snapshot();check(a.add(Mon.make("pikachu",8,1000000))=="full" and a.snapshot()==original,"UID exhaustion cannot create an unsavable roster")
 a=owner();a.next_uid=1000000;var b:=Battle.new();b.adventure=a;b.enemies=[Mon.make("magikarp",5,900000)];b.active=true;a.in_battle=true
 original=a.snapshot();check(not b.valid_command({"kind":"ball","item":"poke-ball"}) and not b.try_capture("poke-ball") and a.snapshot()==original,"Exhausted identities refuse capture before ball/EXP consumption");b.finish("escaped")
 var fox: Dictionary=Mon.make("vulpix",12,20);fox.ability="drought";fox.hp-=3;var damage: int=Mon.stats(fox).hp-int(fox.hp)
 Mon.evolve(fox,"ninetales")
 check(fox.ability=="drought" and Mon.stats(fox).hp-int(fox.hp)==damage and Mon.validate(fox),"Evolution preserves hidden ability slot and existing damage")
 var anchors: Dictionary={"erratic":{15:5737,50:125000,68:257834,98:583539,100:600000},"fluctuating":{15:1957,16:2457,35:42017,36:46656,100:1640000}}
 for growth: String in anchors:
  for level: int in anchors[growth]:check(Mon.experience(level,growth)==anchors[growth][level],"Official XP anchor "+growth+" "+str(level))
 for growth: String in ["fast","medium","medium-slow","slow","erratic","fluctuating"]:
  var increasing:=true
  for level: int in range(2,101):increasing=increasing and Mon.experience(level,growth)>Mon.experience(level-1,growth)
  check(increasing,"Growth curve monotonic across all levels: "+growth)
 # Synthetic in-memory learnset proves new-stage learning; owner data is restored.
 var saved_learnset: Array=Catalog.species("charmeleon").learnset.duplicate(true)
 Catalog.species("charmeleon").learnset.append({"level":18,"move":"protect"})
 a=owner();a.team=[Mon.make("charmander",18,1)];a.next_uid=2;a.pending=[{"kind":"evolution","uid":1,"target":"charmeleon"}]
 check(a.resolve_choice(0,0) and a.team[0].species=="charmeleon" and a.pending.any(func(c: Dictionary):return c.kind=="move" and c.target=="protect") and Solo.validate(a.snapshot()),"Delayed evolution queues a new-stage move without silently replacing a set")
 Catalog.species("charmeleon").learnset=saved_learnset
 check(a.resolve_choice(0,0) and a.team[0].moves[0].id=="protect" and a.pending.is_empty(),"Player explicitly approves the queued attack")
 var saved_effort: Array=Catalog.species("magikarp").effort.duplicate()
 Catalog.species("magikarp").effort=[1,0,0,0,0,0]
 a=owner();a.team=[Mon.make("charizard",50,1)];a.next_uid=2;a.cap=50;a.team[0].ev[0]=123;a.team[0].hp=Mon.stats(a.team[0]).hp-10
 b=Battle.new();b.adventure=a;b.enemies=[Mon.make("magikarp",5,900000)];b.active=true;b.participants={1:true};a.in_battle=true;b.award_experience();b.finish("won")
 check(a.team[0].ev[0]==124 and Mon.stats(a.team[0]).hp-int(a.team[0].hp)==10,"HP EV gain preserves actual damage instead of creating missing HP")
 Catalog.species("magikarp").effort=saved_effort
 a=owner();a.team[1].status="toxic";original=a.snapshot()
 var parsed: Variant=JSON.parse_string(JSON.stringify(original));var restored:=Solo.new()
 check(Solo.validate(parsed) and restored.restore(parsed) and restored.team[1].status=="toxic","Bad poison survives save JSON roundtrip")
 check(restored.use("antidote",int(restored.team[1].uid)) and restored.team[1].status=="","Campaign antidote cures bad poison")
 var backup: Dictionary=Catalog.cached.duplicate(true)
 Catalog.cached.species.rattata.evolution.target="rattata"
 check(Catalog.legal_species("rattata",50)=="","Forward evolution cycle fails safely instead of hanging")
 Catalog.cached=backup.duplicate(true);Catalog.cached.species.rattata.previous="rattata";Catalog.cached.species.rattata.minimum_level=20
 check(Catalog.legal_species("rattata",5)=="","Previous-stage cycle fails safely instead of hanging")
 check(Catalog.lineage("rattata").is_empty() and not Mon.legal_move(Mon.make("rattata",5,1),"future-move"),"Invalid genealogy also fails safely in move legality");Catalog.cached=backup
 check(Catalog.legal_species("future-missing",5)=="","Missing future species refused safely")
 var scene: Node=load("res://main.tscn").instantiate();scene.preferences_path="user://tests_continuity_locale.json";scene.comfort=Comfort.new(path);root.add_child(scene)
 await process_frame;await process_frame
 var game: Node=scene.demo_game;game.save_path="user://tests_continuity_demo.json";game.open(scene);game.new_demo();game.choose_starter("charmander")
 while not game.dialogue_lines.is_empty():game.advance_dialogue()
 game.open_menu("settings");game.menu.body.get_node("GameSpeed").item_selected.emit(1)
 check(Engine.time_scale==2 and Comfort.new(path).data.game_speed==2 and scene.pause_menu.speed==2,"Actual demo speed selector persists and synchronizes workshop")
 game.menu.close();game.state.campaign.adventure.pending=[{"kind":"move","uid":game.state.campaign.adventure.team[0].uid,"target":"protect"}]
 game.open_menu("home");check(game.menu.body.get_node_or_null("ReviewPendingChoices")!=null,"Pending progress gets a visible review shortcut")
 game.menu.body.get_node("ReviewPendingChoices").pressed.emit();check(game.menu.page=="choices","Shortcut opens actual pending-learning screen")
 game.menu.close();game.state.campaign.adventure.bag.potion=999;var saved_bag: Dictionary=game.state.campaign.adventure.bag.duplicate();game.interact("supplies")
 check(not game.state.flags.has("supplies") and game.state.campaign.adventure.bag==saved_bag and str(game.dialogue_lines[0]).contains("place"),"Real gift dialogue reports full bag without awarding or marking collected")
 while not game.dialogue_lines.is_empty():game.advance_dialogue()
 game.close();game.open(scene)
 check(game.menu.speed==2,"Reopening demo displays the real active speed")
 game.close();scene.free();Engine.time_scale=1
 print("SOLO CONTINUITY: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
