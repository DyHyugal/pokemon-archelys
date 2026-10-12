extends SceneTree
const State=preload("res://scripts/domain/demo_state.gd")
const Chapter=preload("res://scripts/domain/demo_chapter.gd")
const Mon=preload("res://scripts/domain/pokemon.gd")
const Dex=preload("res://scripts/domain/demo_dex.gd")
const Slots=preload("res://scripts/services/demo_slots.gd")
var checks: int=0
var failures: int=0
var folder: String=""
func check(ok: bool,label: String) -> void:
 checks+=1
 if not ok:failures+=1;push_error(label)
func _initialize() -> void:call_deferred("run")
func finish_text(game: Node) -> void:
 while not game.dialogue_lines.is_empty():game.advance_dialogue()
 while game.scene.active:game.advance_scene()
func shot(id: String) -> void:
 if folder.is_empty() or DisplayServer.get_name()=="headless":return
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png(folder+"/"+id+".png")==OK,"Actual chapter render "+id)
func settle(game: Node) -> void:
 var deadline: int=Time.get_ticks_msec()+12000
 while game.battle.busy and Time.get_ticks_msec()<deadline:await create_timer(.01).timeout
 check(not game.battle.busy and game.battle.last_error.is_empty(),"Native Showdown responds")
func read_messages(game: Node) -> void:
 var limit: int=0
 while game.battle_panel.visible and game.battle_panel.event_index<game.battle.events.size() and limit<150:game.battle_panel.advance();limit+=1
func win(game: Node) -> void:
 await settle(game);read_messages(game)
 var actions: int=0
 while game.battle.active and actions<45:
  if game.battle.replacement_needed():break
  var slot: int=-1
  for i: int in game.battle.available_moves(0):
   if game.battle.current(0).moves[i].id=="flamethrower":slot=i
  if slot==-1:break
  game.battle_panel.execute({"kind":"move","slot":slot});await settle(game);read_messages(game);actions+=1
 check(game.battle.result=="won" and not game.battle_panel.visible,"Actual battle ends in victory")
func run() -> void:
 for arg: String in OS.get_cmdline_user_args():
  if arg.begins_with("--d73-proof="):folder=arg.trim_prefix("--d73-proof=")
 var data: Dictionary=Chapter.definitions();check(not data.is_empty(),"Chapter authored data validates")
 var bad: Dictionary=data.duplicate(true);bad.battles['demo-post-b'].cap=18;check(not Chapter.validate_definitions(bad),"Shared admin event refuses separate ceiling")
 bad=data.duplicate(true);bad.battles['demo-roadblock'].team[0].species="charizard";check(not Chapter.validate_definitions(bad),"Underlevel evolved boss refused")
 bad=data.duplicate(true);bad.battles['demo-spring-keeper'].team[0].moves=["hydro-pump"];check(not Chapter.validate_definitions(bad),"Illegal fixed profile move refused")
 bad=data.duplicate(true);bad.battles["demo-roadblock"].cap=11;check(not Chapter.validate_definitions(bad),"Boss ceiling must equal its actual ace level")
 var state:=State.new();state.choose("bulbasaur")
 var old: Dictionary=state.snapshot();old.erase("chapter");check(state.restore(old) and state.chapter.flags.is_empty(),"Old saves migrate without unlocking new chapter")
 check(Chapter.is_water("springs",Vector2(-7,-2)) and Chapter.is_water("town",Vector2(14,12)) and not Chapter.is_water("town",Vector2(11,12)),"Shared water mask covers all demo ponds while preserving dry dock")
 check(not state.chapter.begin(state) and not state.travel("canopy"),"No new chapter before old demo completion")
 state.flags={"survey":true,"trainer":true,"complete":true};state.campaign.adventure.records.scenes["demo-return"]=true;check(state.chapter.begin(state) and not state.chapter.begin(state),"Chapter starts once after real prerequisites")
 state.travel("trail");check(not state.chapter.can_battle(state,"demo-roadblock") and state.chapter.target(state)=="exit","Incomplete main briefing cannot be bypassed by loading")
 state.campaign.adventure.records.scenes["demo-canopy-briefing"]=true
 var advanced:=State.new();advanced.restore(state.snapshot());advanced.campaign.adventure.raise_cap(70)
 check(advanced.chapter.won(advanced,"demo-roadblock") and advanced.campaign.adventure.cap==70,"Existing higher cap is never lowered by chapter")
 check(not state.travel("canopy") and not state.chapter.can_battle(state,"demo-post-a"),"Walking portal and boss order are gated")
 check(state.chapter.won(state,"demo-roadblock") and state.campaign.adventure.cap==12,"First checkpoint opens monotonic ceiling")
 var money: int=state.campaign.adventure.money;check(not state.chapter.won(state,"demo-roadblock") and state.campaign.adventure.money==money,"Forged duplicate completion gives nothing")
 check(state.travel("canopy") and not state.travel("springs"),"Canopy opens, sanctuary remains gated")
 check(state.chapter.relay(state,"relay-west") and not state.chapter.relay(state,"relay-west") and not state.travel("springs"),"Both independent relays required, no repeats")
 check(state.chapter.relay(state,"relay-east") and state.travel("springs"),"Second relay opens correct route")
 var team: Array=state.chapter.opponents(state,"demo-spring-keeper")
 check(team.size()==3 and team[0].ability=="drought" and team[1].ability=="chlorophyll" and team[2].ability=="drought" and team.all(Mon.validate),"Setter, beneficiary and second setter have legal real sets")
 check(state.chapter.won(state,"demo-spring-keeper") and state.campaign.adventure.cap==14,"Sanctuary boss becomes new ceiling")
 state.travel("canopy");state.travel("post");check(not state.chapter.can_battle(state,"demo-post-b"),"Second admin requires first")
 check(state.chapter.won(state,"demo-post-a") and state.campaign.adventure.cap==16 and state.chapter.won(state,"demo-post-b") and state.campaign.adventure.cap==16,"Same-area admins never add two levels twice")
 check(State.validate(state.snapshot()),"Full chapter awards and locations serialize")
 bad=state.snapshot();bad.campaign.adventure.cap=14;check(not State.validate(bad),"Cap cannot fall below recorded milestone")
 bad=state.snapshot();bad.chapter.flags.erase("keeper");check(not State.validate(bad),"Forged missing dependency refused")
 state.travel("canopy");state.position=Vector3(-9,0,5);check(State.validate(state.snapshot()),"Legal unlocked Surf position persists")
 bad=state.snapshot();bad.chapter.flags={"started":true,"roadblock":true};bad.chapter.ceilings={"demo-roadblock":12};bad.chapter.visited=["canopy"];check(not State.validate(bad),"Water position without Surf story unlock refused")
 state.campaign.adventure.bag['great-ball']=999;check(not state.chapter.secret(state) and not state.chapter.flags.has("surf-secret"),"Full bag never consumes secret reward")
 state.campaign.adventure.bag['great-ball']=0;check(state.chapter.secret(state) and not state.chapter.secret(state),"Surf gift once, independent of compatible Pokemon")
 var hits: Dictionary={};var valid_samples: bool=true
 state.campaign.adventure.rng.seed=7301
 state.travel("springs")
 for i: int in range(100):
  var mon: Dictionary=state.chapter.encounter(state);valid_samples=valid_samples and Mon.validate(mon) and ((mon.species=="magikarp" and mon.level in [18,19]) or (mon.species=="gyarados" and mon.level in [20,21,22]))
  hits[mon.species]=true
 check(valid_samples,"All 100 native encounter fixtures follow level-stage boundaries")
 check(hits.has("magikarp") and hits.has("gyarados"),"Fishing pool exercises both evolution stages")
 var habitats: Array=Dex.habitats("gyarados");check(habitats.size()==1 and habitats[0].place=="springs" and habitats[0].minimum==20 and habitats[0].maximum==22,"Dex derived from actual legal encounter range")
 # Integration uses an overlevel test party to check the route, not to certify balance.
 var owner: Node=load("res://main.tscn").instantiate();owner.preferences_path="user://tests_d73_preferences.json";root.add_child(owner);await process_frame
 var baseline: Dictionary=root.get_node("Session").campaign.snapshot();var game: Node=owner.demo_game;game.save_path="user://tests_d73_demo.json"
 for i: int in range(1,4):
  for suffix: String in ["",".backup",".auto",".auto.backup"]:DirAccess.remove_absolute(Slots.path(game.save_path,i)+suffix)
 game.open(owner);game.new_demo();game.choose_starter("bulbasaur");finish_text(game)
 game.state.flags={"survey":true,"trainer":true,"complete":true};game.state.campaign.adventure.records.scenes['demo-return']=true
 game.interact("vyna");check(game.modal.find_child("BeginDemoChapter",true,false)!=null,"Actual Vyna offers continuation to old completed saves")
 game.modal.find_child("BeginDemoChapter",true,false).pressed.emit();check(game.scene.active,"Chapter briefing starts manually");finish_text(game)
 var a: RefCounted=game.state.campaign.adventure;a.team[0]=Mon.make("charizard",50,1);a.records.observe("charizard",true);a.exploration.difficulty="hard"
 game.travel("trail");check(game.world.points.has("roadblock") and game.world.points.has("go-canopy"),"Actual trail connects next chapter")
 game.interact("go-canopy");check(game.state.location=="trail" and game.modal!=null,"Locked portal gives story guidance, no teleport");finish_text(game)
 game.interact("roadblock");await win(game)
 check(game.state.chapter.flags.has("roadblock") and a.cap==12,"Native winner callback applies milestone before victory message")
 game.interact("go-canopy");check(game.state.location=="canopy" and game.world.can_walk(game.state.position),"Walking portal arrives on valid ground")
 game.interact("chapter-grass");await settle(game);check(game.battle.enemies[0].level>=8 and game.battle.enemies[0].level<=10 and game.battle.trainer.is_empty(),"Canopy grass opens actual configured wild battle")
 game.battle.finish("escaped");read_messages(game)
 game.interact("hyu");check(game.dialogue_lines[0].contains("Hyu"),"Companion dialogue exists in actual zone");finish_text(game)
 game.interact("surf");check(not game.state.chapter.surfing,"Surf really locked before keeper");finish_text(game)
 a.team[0].hp=1;a.team[0].moves[0].pp=0;game.interact("camp-nurse");finish_text(game);check(a.team[0].hp==Mon.stats(a.team[0]).hp and a.team[0].moves[0].pp>0,"Physical camp restores HP and PP")
 game.interact("relay-west");finish_text(game);game.interact("relay-east");finish_text(game);await shot("01-canopy")
 game.open_menu("map");await shot("02-regional-map");check(game.menu.body.get_node_or_null("Fly_canopy")!=null and not game.menu.body.get_node("Fly_canopy").disabled,"Regional map exposes visited Fly stop");game.menu.close()
 game.interact("go-springs");check(game.state.location=="springs","Relays open physical sanctuary route")
 var untouched: Dictionary=game.state.chapter.snapshot();var prior_money: int=a.money;var prior_cap: int=a.cap
 game.interact("spring-keeper");await settle(game);game.battle._failure("test-only transport interruption");read_messages(game)
 check(game.state.chapter.snapshot()==untouched and a.money==prior_money and a.cap==prior_cap and not game.battle_panel.visible,"Cancelled native battle preserves chapter and wallet")
 game.interact("spring-keeper");await settle(game);game.battle.finish("lost");read_messages(game)
 check(game.state.location=="center" and not game.state.chapter.flags.has("keeper") and a.cap==prior_cap and a.money==maxi(0,prior_money-100),"Defeat returns to Center once and never advances chapter")
 game.open_menu("map");game.menu.body.get_node("Fly_springs").pressed.emit();check(game.state.location=="springs","Visited sanctuary can be revisited after defeat")
 game.interact("spring-keeper");await settle(game);check(game.battle.field.weather=="sun","Actual Showdown Drought sets sun in keeper battle");await shot("03-sun-battle");await win(game)
 check(a.cap==14 and game.state.chapter.can_surf(game.state),"Victory raises ceiling and story Surf")
 game.interact("spring-fish");await settle(game);check(game.battle.enemies[0].level>=18 and game.battle.enemies[0].level<=22 and game.battle.trainer.is_empty(),"Actual spring fishing respects configured pool")
 game.battle.finish("escaped");read_messages(game)
 game.interact("go-canopy");game.state.position=Vector3(-4.5,0,5);game.world.build(game.state);check(not game.world.can_walk(Vector3(-5.5,0,5)),"Water collision refuses foot traversal")
 game.interact("surf");check(game.state.chapter.surfing and game.world.can_walk(Vector3(-5.5,0,5)),"Contextual Surf changes actual walkability")
 for i: int in range(18):game.world.move_hero(Vector2.LEFT,.08,game.state)
 check(Chapter.WATER.has_point(Vector2(game.state.position.x,game.state.position.z)),"Hero actually crosses water after unlock")
 check(game.world.nearest() in ["surf-secret","surf"],"Water interaction remains accessible")
 game.save_game();game.load_game();check(game.state.chapter.surfing and game.world.can_walk(game.state.position),"Loading in water reconstructs Surf safely")
 a=game.state.campaign.adventure;game.interact("surf-secret");finish_text(game);check(a.bag.get("great-ball",0)==3,"Physical pool cache grants real item")
 game.state.position=Vector3(0,0,9);game.world.build(game.state);game.interact("go-post");check(game.state.location=="post","Story keeper opens checkpoint")
 game.interact("raidon");finish_text(game);game.interact("post-b");check(not game.battle_panel.visible,"Second admin cannot start early");finish_text(game)
 game.interact("post-a");await win(game);check(a.cap==16,"First admin ceiling")
 var first_cap: int=a.cap;game.interact("post-b");await win(game);check(a.cap==first_cap and game.state.chapter.ceilings['demo-post-a']==game.state.chapter.ceilings['demo-post-b'],"Native consecutive admins preserve shared event cap")
 await shot("04-checkpoint")
 game.open_menu("map");game.menu.body.get_node("Fly_town").pressed.emit();check(game.state.location=="town","Map Fly can return to town from added region")
 game.interact("vyna");game.modal.find_child("ReportDemoChapter",true,false).pressed.emit();check(game.scene.active and game.state.chapter.flags.has("reported"),"Vyna report starts manual closing proposal")
 game.save_game();var incomplete: Dictionary=game.state.snapshot();var recovery:=State.new();check(recovery.restore(incomplete) and not recovery.campaign.adventure.records.scenes.has("demo-checkpoint-report"),"Interrupted report remains a valid resumable save")
 finish_text(game)
 check(game.apply_archive(incomplete,game.loaded_slot),"Interrupted scene can actually be reloaded")
 game.interact("vyna");check(game.modal.find_child("ResumeChapterReport",true,false)!=null,"Vyna offers resume after interrupted final scene")
 game.modal.find_child("ResumeChapterReport",true,false).pressed.emit();finish_text(game)
 game.open_menu("journal");await shot("05-journal");check(game.state.chapter.tasks("fr").all(func(row: Dictionary):return row.done),"Chapter journal completes exact milestones")
 game.menu.close();game.save_game();var saved: Dictionary=game.state.snapshot();game.load_game();
 if game.state.snapshot()!=saved:
  for key: String in saved:
   if game.state.snapshot().get(key)!=saved[key]:print("ROUNDTRIP MISMATCH: ",key)
 check(game.state.snapshot()==saved and game.state.chapter.visited.size()==3,"Complete route restores without duplicate rewards")
 game.open_menu("cinema");check(game.menu.body.get_node_or_null("Replay_demo-checkpoint-report")!=null,"Completed report unlocked in real gallery")
 game.menu.close();game.close();check(root.get_node("Session").campaign.snapshot()==baseline,"Expanded chapter never modifies workshop campaign")
 print("DEMO CHAPTER: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
