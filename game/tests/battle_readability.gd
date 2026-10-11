extends SceneTree
const Messages=preload("res://scripts/services/battle_messages.gd")
const Adapter=preload("res://scripts/services/showdown_battle.gd")
const BattlePanel=preload("res://scripts/ui/pokemon_battle_panel.gd")
const Adventure=preload("res://scripts/domain/solo_adventure.gd")
const Mon=preload("res://scripts/domain/pokemon.gd")
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
var checks: int=0
var failures: int=0
func check(value: bool,label: String) -> void:
 checks+=1
 if not value:failures+=1;push_error(label)
func settle(b: RefCounted) -> void:
 var deadline: int=Time.get_ticks_msec()+12000
 while b.busy and Time.get_ticks_msec()<deadline:await create_timer(0.01).timeout
 check(not b.busy and b.last_error.is_empty(),"Real Showdown response completes")
func button_named(panel: Node,node_name: String) -> Node:
 for child: Node in panel.actions.get_children():
  if child.name==node_name:return child
 return null
func press(panel: Node,needle: String) -> bool:
 for child: Node in panel.actions.get_children():
  if child is Button and not child.disabled and child.text.contains(needle):child.pressed.emit();return true
 return false
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var roster: Array=[Mon.make("charizard",50,1),Mon.make("magikarp",100,900000)]
 var cases: Array=[
  ["|move|p1a: 1|Flamethrower|p2a: 900000","Lance-Flammes","Flamethrower"],
  ["|-damage|p2a: 900000|65/100 par","PV restants : 65%","Remaining HP: 65%"],
  ["|-heal|p1a: 1|100/145 brn","PV restants : 100/145","Remaining HP: 100/145"],
  ["|-status|p1a: 1|par","paralysie","paralysis"],
  ["|-curestatus|p1a: 1|par","ne souffre plus","recovered"],
  ["|-unboost|p1a: 1|accuracy|2","Précision diminue de 2","Accuracy falls by 2"],
  ["|-boost|p1a: 1|spa|1","Attaque Spéciale augmente","Special Attack rises"],
  ["|-weather|SunnyDay|[upkeep]","soleil se poursuit","sun continues"],
  ["|-weather|none","climat prend fin","weather ended"],
  ["|-fieldstart|move: Electric Terrain","terrain électrique","Electric Terrain"],
  ["|-fieldend|move: Grassy Terrain","Fin du terrain herbu","Grassy Terrain ended"],
  ["|-supereffective|p2a: 900000","super efficace","super effective"],
  ["|-resisted|p2a: 900000","pas très efficace","not very effective"],
  ["|-immune|p2a: 900000","n'affecte pas","doesn't affect"],
  ["|-crit|p2a: 900000","Coup critique","critical hit"],
  ["|cant|p1a: 1|flinch","apeuré","flinched"],
  ["|-activate|p1a: 1|move: Protect","Abri","Protect"],
  ["|-ability|p1a: 1|Drought","Sécheresse","Drought"],
  ["|-enditem|p1a: 1|Leftovers","Restes","Leftovers"],
 ]
 for item: Array in cases:
  var event: Dictionary=Messages.format_line(item[0],roster)
  check(event.get("fr","").contains(item[1]) and event.get("en","").contains(item[2]),"Protocol localizes "+item[0])
 check(Messages.format_line("|move|p1a: 1",roster).is_empty() and Messages.format_line("|-boost|p1a: 1|atk",roster).is_empty(),"Truncated protocol cannot crash or invent event")
 check(Messages.format_line("|request|secret",roster).is_empty() and Messages.format_line("|player|p2|Opponent",roster).is_empty(),"Private requests and protocol metadata are not displayed")
 var a:=Adventure.new();a.initialize();a.cap=100;a.team=[roster[0]];a.next_uid=2
 a.team[0].moves=[{"id":"flamethrower","pp":15},{"id":"growl","pp":40}]
 roster[1].moves=[{"id":"splash","pp":40}]
 var b:=Adapter.new();check(b.begin(a,[roster[1]]),"Actual battle starts")
 await settle(b)
 if not b.active:quit(1);return
 var panel:=BattlePanel.new();root.add_child(panel);await process_frame
 var theme:=Theme.new();theme.default_font_size=16;load("res://scripts/ui/interface_style.gd").apply(theme,"dark");panel.panel.theme=theme
 panel.open(b,"fr")
 check(panel.message.text.contains("avance manuelle") and panel.event_index==0,"First real event waits for manual confirmation")
 var original: int=panel.event_index
 check(button_named(panel,"BattleHistory")!=null,"Journal available while message awaits confirmation")
 button_named(panel,"BattleHistory").pressed.emit()
 check(panel.journal_open and panel.history_entries().size()==1,"Journal contains current event but conceals future events")
 var echo:=InputEventKey.new();echo.keycode=KEY_A;echo.pressed=true;echo.echo=true
 panel.handle_key(echo);await create_timer(0.1).timeout
 check(panel.event_index==original,"Journal and repeated key never advance pending message")
 var escape:=InputEventKey.new();escape.keycode=KEY_ESCAPE;escape.pressed=true;panel.handle_key(escape)
 check(not panel.journal_open and panel.event_index==original,"Escape restores exact pending message")
 panel.handle_key(echo);check(panel.event_index==original,"Held confirmation key does not skip events")
 while panel.event_index<b.events.size():panel.advance()
 var count: int=b.history.size()
 check(press(panel,"Attaquer"),"Move selector opens")
 button_named(panel,"BattleMoveDetails").toggled.emit(true)
 check(panel.move_details and panel.actions.get_children().any(func(c: Node):return c is Label and c.text.contains("Puissance 90") and c.text.contains("Précision 100%")),"Move power/category/accuracy visible without choosing attack")
 check(b.turn==0 and a.team[0].moves[0].pp==15,"Inspection consumes no turn or PP")
 check(press(panel,"Lance-Flammes"),"Inspected attack still executes actual Showdown")
 await settle(b)
 check(b.history.size()>count and b.history[count].sequence==count and a.team[0].moves[0].pp==14,"History survives queue clearing while actual attack consumes one PP")
 panel.locale="en";panel.render();check(panel.message.text.contains("manual advance"),"Language renders same waiting queue in English")
 original=panel.event_index
 Engine.time_scale=4.0;await create_timer(0.3).timeout;Engine.time_scale=1.0
 check(panel.event_index==original,"Accelerated frames never auto-confirm battle text")
 while panel.event_index<b.events.size():panel.advance()
 var before: Dictionary=a.snapshot();button_named(panel,"BattleHistory").pressed.emit()
 check(panel.history_entries().size()==b.history.size(),"Completed turn history includes all presented messages")
 # Multiple pages of already-presented messages exercise navigation without simulation.
 for i: int in range(43):b.say("Message historique %d" % i,"History message %d" % i)
 panel.event_index=b.events.size();panel.journal_page=0;panel.render()
 check(panel.message.text.contains("page 1 / 3") and press(panel,"Next page") and panel.journal_page==1,"Journal pages navigate over twenty entries")
 check(a.snapshot()==before and b.turn==1,"Journal reading/pagination never changes campaign or combat")
 panel.journal_open=false;panel.choice_page="moves";panel.render()
 check(panel.move_caption(Catalog.move("surf")).contains("opponents AND ally") and panel.move_caption(Catalog.move("protect")).contains("self"),"Move details distinguish friendly fire and self targets")
 for arg: String in OS.get_cmdline_user_args():
  if arg.begins_with("--battle-proof=") and DisplayServer.get_name()!="headless":
   panel.locale="fr";panel.choice_page="moves";panel.render();await process_frame;await process_frame;await RenderingServer.frame_post_draw
   check(root.get_texture().get_image().save_png(arg.trim_prefix("--battle-proof="))==OK,"Real battle selector render saves PNG")
 b.finish("escaped");panel.render()
 check(panel.visible,"Final queue still requires manual advance after finish")
 while panel.event_index<b.events.size():panel.advance()
 check(not panel.visible and not a.in_battle,"Battle exits after manual queue without extra modal lock")
 # Real doubles: consulting history must not discard a partner's queued command.
 var duo:=Adventure.new();duo.initialize();duo.cap=100;duo.team=[Mon.make("charizard",50,1),Mon.make("blastoise",50,2)];duo.next_uid=3
 for member: Dictionary in duo.team:member.moves=[{"id":"protect","pp":10}]
 var foes: Array=[Mon.make("magikarp",100,900000),Mon.make("magikarp",100,900001)]
 for foe: Dictionary in foes:foe.moves=[{"id":"splash","pp":40}]
 var doubles:=Adapter.new();doubles.double_mode=true
 check(doubles.begin(duo,foes),"Actual double battle starts after single exit")
 await settle(doubles);panel.open(doubles,"en")
 while panel.event_index<doubles.events.size():panel.advance()
 check(doubles.history.size()<b.history.size(),"Independent battle has a fresh history")
 check(press(panel,"Protect"),"First double actor queues Protect")
 var queued: Dictionary=doubles.queued.duplicate(true)
 check(doubles.selected_player==1 and panel.message.text.contains("Ally choice locked"),"Partner selection visibly retains first choice")
 button_named(panel,"BattleHistory").pressed.emit();panel.handle_key(escape)
 check(doubles.queued==queued and doubles.turn==0,"Opening/closing history preserves queued double choice")
 check(press(panel,"Protect"),"Partner still submits its own Protect")
 await settle(doubles)
 check(doubles.turn==1 and duo.team[0].moves[0].pp==9 and duo.team[1].moves[0].pp==9,"Both real choices resolve once with their own PP")
 doubles.finish("escaped")
 while panel.event_index<doubles.events.size():panel.advance()
 print("BATTLE READABILITY: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
