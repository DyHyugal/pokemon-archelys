extends SceneTree
const Adventure=preload("res://scripts/domain/solo_adventure.gd")
const Exploration=preload("res://scripts/domain/exploration.gd")
const Mon=preload("res://scripts/domain/pokemon.gd")
const Slots=preload("res://scripts/services/save_slots.gd")
var checks: int=0
var failures: int=0
func check(value: bool,label: String) -> void:
 checks+=1
 if not value:failures+=1;push_error(label)
func settle(b: RefCounted) -> void:
 var deadline: int=Time.get_ticks_msec()+12000
 while b.busy and Time.get_ticks_msec()<deadline:await create_timer(0.01).timeout
 check(not b.busy and b.last_error.is_empty(),"Real Showdown reply completes")
func drain(world: Node) -> void:
 while world.battle_panel.event_index<world.pokemon_battle.events.size():world.battle_panel.advance()
func press(panel: Node,needle: String) -> bool:
 for control: Node in panel.actions.get_children():
  if control is Button and not control.disabled and control.text.contains(needle):control.pressed.emit();return true
 return false
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var a:=Adventure.new();a.initialize()
 check(a.exploration.battle_style=="set" and a.exploration.bag_healing,"Defaults preserve old laboratory behavior")
 check(a.set_battle_options("shift",false),"Approved styles and healing option configurable outside battle")
 var snapshot: Dictionary=a.snapshot();check(Adventure.validate(snapshot),"New optional fields fit campaign schema")
 var restored:=Adventure.new();check(restored.restore(JSON.parse_string(JSON.stringify(snapshot))) and restored.exploration.battle_style=="shift" and not restored.exploration.bag_healing,"JSON reload retains explicit rules")
 snapshot.exploration.erase("battle_style");snapshot.exploration.erase("bag_healing")
 check(restored.restore(snapshot) and restored.exploration.battle_style=="set" and restored.exploration.bag_healing,"Old saves load compatible defaults")
 for key: String in ["battle_style","bag_healing"]:
  var bad: Dictionary=a.snapshot();bad.exploration[key]="invalid"
  check(not Adventure.validate(bad),"Invalid rule rejected: "+key)
 a.in_battle=true;var before: Dictionary=a.snapshot()
 check(not a.set_battle_options("set",true) and a.snapshot()==before,"Mid-battle rule edits are atomic refusals")
 a.team[0].hp=1;var quantity: int=int(a.bag.potion)
 check(not a.use("potion",int(a.team[0].uid)) and int(a.bag.potion)==quantity and a.team[0].hp==1,"Disabled bag healing enforced in domain without spending")
 a.in_battle=false
 check(a.use("potion",int(a.team[0].uid)) and int(a.bag.potion)==quantity-1,"Out-of-battle medicine remains available")
 a.team[0].hp=0;a.heal_team();check(a.team[0].hp==Mon.stats(a.team[0]).hp,"Center heals independently of bag restriction")
 var world: Node=load("res://main.tscn").instantiate();world.preferences_path="user://tests_battle_options_prefs.json";world.slots=Slots.new("user://tests_battle_options_campaign");root.add_child(world);await process_frame;await process_frame;world._set_locale("fr")
 var campaign: RefCounted=root.get_node("Session").campaign
 world._open_menu("rules")
 var styles: OptionButton=world.pause_menu.body.get_node("BattleStyle");styles.select(1);styles.item_selected.emit(1)
 var healing: CheckButton=world.pause_menu.body.get_node("BattleHealing");healing.set_pressed_no_signal(false);healing.toggled.emit(false)
 check(campaign.adventure.exploration.battle_style=="shift" and not campaign.adventure.exploration.bag_healing,"Actual rules widgets change domain settings")
 world._save();world.pause_menu.close();world._load()
 a=campaign.adventure
 check(a.exploration.battle_style=="shift" and not a.exploration.bag_healing,"Actual disk save/load retains both rules")
 a.cap=100;a.team=[Mon.make("blastoise",50,1),Mon.make("vulpix",50,2)];a.next_uid=3
 a.team[0].moves=[{"id":"surf","pp":15}];a.team[1].ability="drought";a.team[1].moves=[{"id":"protect","pp":10}]
 for member: Dictionary in a.team:a.records.observe(member.species,true)
 var foe: Dictionary=Mon.make("rattata",8,900000);foe.hp=1;foe.moves=[{"id":"tail-whip","pp":30}]
 var reserve: Dictionary=Mon.make("magikarp",100,900001);reserve.moves=[{"id":"splash","pp":40}]
 var began: bool=world._begin_pokemon_battle([foe,reserve],"weather-test")
 check(began,"Trainer battle starts with configured Shift")
 if not began:
  print("START DIAGNOSTIC ",world.message.text," pause=",world.pause_menu.visible," dialog=",world.dialogue.active," cinematic=",world.cinematic.active," in_battle=",a.in_battle," team=",Mon.validate(a.team[0]),"/",Mon.validate(a.team[1])," foes=",Mon.validate(foe),"/",Mon.validate(reserve))
  quit(1);return
 await settle(world.pokemon_battle);drain(world)
 check(press(world.battle_panel,"Attaquer") and press(world.battle_panel,"Surf"),"Actual attack UI executes decisive move")
 await settle(world.pokemon_battle)
 check(not world.pokemon_battle.shift_offer.is_empty() and world.pokemon_battle.current(1).hp==0,"Upcoming enemy stays off field during pending KO messages")
 drain(world)
 check(world.battle_panel.message.text.contains("Magicarpe") and world.battle_panel.actions.get_node("ShiftMember0").disabled and not world.battle_panel.actions.get_node("ShiftMember1").disabled,"Offer announces next species and only legal reserves")
 var pending: Dictionary=world.pokemon_battle.shift_offer.duplicate(true)
 check(press(world.battle_panel,"Historique"),"History remains available during shift offer")
 var escape:=InputEventKey.new();escape.keycode=KEY_ESCAPE;escape.pressed=true;world.battle_panel.handle_key(escape)
 check(world.pokemon_battle.shift_offer==pending,"History cannot accept, decline or discard the offer")
 check(not world.pokemon_battle.valid_command({"kind":"move","slot":0}) and not world.pokemon_battle.execute({"kind":"run"}),"Ordinary action blocked until free-shift decision")
 for arg: String in OS.get_cmdline_user_args():
  if arg.begins_with("--options-proof=") and DisplayServer.get_name()!="headless":
   await process_frame;await process_frame;await RenderingServer.frame_post_draw
   check(root.get_texture().get_image().save_png(arg.trim_prefix("--options-proof="))==OK,"Actual trainer offer renders to PNG")
 world.battle_panel.actions.get_node("ShiftMember1").pressed.emit()
 check(not world.pokemon_battle.choose_shift(1),"Duplicate shift submission refused while worker pending")
 await settle(world.pokemon_battle);drain(world)
 check(world.pokemon_battle.current(0).uid==2 and world.pokemon_battle.current(1).uid==900001 and world.pokemon_battle.turn==1,"Accepted shift changes both active identities without extra attack")
 check(world.pokemon_battle.field.weather=="sun" and a.team[0].moves[0].pp==14 and a.team[1].moves[0].pp==10,"Native entry talent runs and reserve PP preserved")
 world.pokemon_battle.finish("escaped");drain(world)
 # A second battle exercises decline with English labels, then restricted Bag.
 a.heal_team();world._set_locale("en")
 check(world._begin_pokemon_battle([foe,reserve],"weather-test"),"Second independently configured trainer starts")
 await settle(world.pokemon_battle);drain(world);press(world.battle_panel,"Fight");press(world.battle_panel,"Surf")
 await settle(world.pokemon_battle);drain(world)
 check(world.battle_panel.message.text.contains("Magikarp") and press(world.battle_panel,"Keep current"),"English prompt can decline through actual UI")
 await settle(world.pokemon_battle);drain(world)
 check(world.pokemon_battle.current(0).uid==1 and world.pokemon_battle.turn==1,"Decline preserves player and consumes no extra turn")
 check(press(world.battle_panel,"Bag"),"Bag remains inspectable")
 check(world.battle_panel.actions.get_children().any(func(c: Node):return c is Button and c.text.begins_with("Potion") and c.disabled),"Restricted medicines visibly disabled")
 check(not world.pokemon_battle.valid_command({"kind":"item","item":"potion","index":0}),"Godot command gate refuses disabled healing")
 world.pokemon_battle.finish("escaped");drain(world)
 # Defeat is real, not a mocked finish: fastest foe KOs the sole active member.
 a.team=[Mon.make("bulbasaur",8,1)];a.next_uid=2;a.team[0].hp=1;a.team[0].moves=[{"id":"growl","pp":40}];a.money=137;a.exploration.enter("village")
 var strong: Dictionary=Mon.make("raichu",100,900000);strong.moves=[{"id":"thunderbolt","pp":15}]
 check(world._begin_pokemon_battle([strong]),"Real defeat fixture starts")
 await settle(world.pokemon_battle);drain(world);press(world.battle_panel,"Fight");press(world.battle_panel,"Growl")
 await settle(world.pokemon_battle)
 check(world.pokemon_battle.result=="lost" and a.money==37 and a.team[0].hp==Mon.stats(a.team[0]).hp,"Real defeat debits once and heals despite bag restriction")
 check(a.exploration.location=="village" and world.battle_panel.visible,"Defeat texts are still confirmed before travel")
 drain(world)
 check(a.exploration.location=="center" and world.displayed_location=="center" and campaign.players[1].position==[0.0,0.0,5.0],"Defeat returns to actual Center geometry and safe spawn")
 var money: int=a.money;world.pokemon_battle.finish("lost")
 check(a.money==money,"Repeated finish cannot debit twice")
 world._save();world._load();a=campaign.adventure
 check(a.exploration.location=="center" and world.displayed_location=="center" and a.money==37 and not a.exploration.bag_healing,"Center/money/rules persist through real disk reload")
 check(Adventure.validate(a.snapshot()),"Final campaign remains valid")
 print("BATTLE OPTIONS: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
