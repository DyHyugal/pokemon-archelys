extends SceneTree
const Slots=preload("res://scripts/services/save_slots.gd")
const Mon=preload("res://scripts/domain/pokemon.gd")
var checks:=0
var failures:=0
func check(ok: bool,label: String) -> void:
 checks+=1
 if not ok:failures+=1;push_error(label)
func press(menu: CanvasLayer,needle: String) -> bool:
 for node: Node in menu.body.get_children():
  if node is Button and node.text.contains(needle):node.pressed.emit();return true
 return false
func key(world: Node,code: Key,echo: bool=false) -> void:
 var event:=InputEventKey.new();event.keycode=code;event.pressed=true;event.echo=echo;world._input(event)
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var prefix: String="user://tests_collection_scene"
 var dir:=DirAccess.open("user://")
 for file: String in dir.get_files():
  if file.begins_with("tests_collection_scene"):dir.remove(file)
 var world: Node=load("res://main.tscn").instantiate();world.slots=Slots.new(prefix);world.preferences_path="user://tests_collection_scene_prefs.json";root.add_child(world)
 await process_frame;await process_frame
 world._set_locale("fr")
 var session: Node=root.get_node("Session")
 var a: RefCounted=session.campaign.adventure
 world._open_menu("dex")
 check(world.pause_menu.buttons.has("dex") and world.pause_menu.buttons.has("cinema") and world.pause_menu.buttons.has("saves"),"Actual pause navigation exposes all three new pages")
 var hidden: bool=false
 for node: Node in world.pause_menu.body.get_children():
  if node is Button and node.text.contains("???"):hidden=hidden or node.disabled
 check(hidden,"Unseen Dex entries have no browsable data")
 check(press(world.pause_menu,"Bulbizarre"),"Known species button opens actual details")
 check(world.pause_menu.body.get_children().any(func(node: Node):return node is Label and node.text.contains("Herbes du village")),"Real Dex detail shows legal habitat")
 press(world.pause_menu,"Retour à la liste")
 var filter: OptionButton=world.pause_menu.body.get_node("DexFilter");filter.item_selected.emit(2)
 check(world.pause_menu.collection_pages.filter==2,"Actual filter control selects obtained species")
 world.pause_menu.close();world._open_menu("cinema")
 var original: Dictionary=a.snapshot();var zoom: float=world.camera.size
 check(press(world.pause_menu,"Découvrir : Visite"),"Gallery launches first main scene through actual button")
 check(world.cinematic.active and world.cinematic_panel.visible and not world.pause_menu.visible and not world.gameplay_layer.visible,"Cinematic is a distinct modal with its own controls")
 key(world,KEY_ESCAPE);check(world.cinematic.active and world.cinematic.index==0,"Escape cannot skip main scene")
 key(world,KEY_E,true);check(world.cinematic.index==0,"Held/echo confirmation cannot skip text")
 world._open_menu("bag");world._save();world._travel("cove");world._slot_action("new",2)
 check(world.cinematic.active and not world.pause_menu.visible and not FileAccess.file_exists(world.slots.path(1)) and a.exploration.location=="village" and world.slots.active==1,"Film blocks menu, save, travel and new game operations")
 Engine.time_scale=4
 await create_timer(0.2).timeout
 check(world.cinematic.index==0,"Accelerated presentation never auto-advances narrative text")
 for i: int in range(4):world.cinematic_panel.next_button.pressed.emit()
 check(not world.cinematic.active and world.pause_menu.visible and world.camera.size==zoom and world.gameplay_layer.visible and a.records.scenes.has("lab-tour"),"Real Next control completes scene, unlocks replay, restores camera and gallery")
 var after: Dictionary=a.snapshot();after.records=original.records
 check(after==original,"Cinematic does not alter party, bag, progression or location")
 var unlocked: Dictionary=a.snapshot();press(world.pause_menu,"Rejouer : Visite")
 for i: int in range(4):key(world,KEY_ENTER)
 check(a.snapshot()==unlocked,"Replay has no gameplay rewards or duplicate history")
 press(world.pause_menu,"Découvrir : Scène secondaire");world.cinematic_panel.skip_button.pressed.emit()
 check(not world.cinematic.active and a.records.scenes.has("lab-note") and not press(world.pause_menu,"Rejouer : Scène secondaire"),"Actual secondary skip returns to gallery without enabling replay")
 Engine.time_scale=1
 world.pause_menu.close();world._open_menu("saves")
 check(press(world.pause_menu,"Sauvegarder ici") and not FileAccess.file_exists(world.slots.path(1)),"Save slot button waits for explicit confirmation")
 check(press(world.pause_menu,"Confirmer") and world.slots.read(1).adventure.records.scenes.has("lab-tour"),"Confirm stores discovery and movies in real manual file")
 world._slot_action("new",2);a=session.campaign.adventure
 check(a.records.scenes.is_empty() and world.slots.active==2 and not FileAccess.file_exists(world.slots.path(2)),"New slot starts fresh in memory without deleting stored old game")
 a.money=1555;world._autosave_if_safe(true)
 check(not FileAccess.file_exists(world.slots.path(2,true)),"Autosave defers while pause menu open")
 world.pause_menu.close();world.last_auto_tick=Time.get_ticks_msec();Engine.time_scale=4;world._autosave_if_safe()
 check(not FileAccess.file_exists(world.slots.path(2,true)),"4x speed does not bypass 60 real-second autosave delay")
 world.last_auto_tick=Time.get_ticks_msec()-60001;world._autosave_if_safe();Engine.time_scale=1
 check(world.slots.read(2,true).adventure.money==1555 and not FileAccess.file_exists(world.slots.path(2)),"Actual safe autosave writes only auto file in active slot")
 world._slot_action("load",1);a=session.campaign.adventure
 check(world.slots.active==1 and a.records.scenes.has("lab-tour") and a.money==3000,"Loading another slot restores its own history and party")
 var snapshot: Dictionary=session.campaign.snapshot();world._slot_action("load",3)
 check(world.slots.active==1 and session.campaign.snapshot()==snapshot,"Invalid load preserves active slot and all current game data")
 world._slot_action("auto",2);a=session.campaign.adventure
 check(world.slots.active==2 and a.money==1555,"Autosave is explicitly loadable through slot operation")
 a.money=1500;world._open_menu("saves");var automatic: CheckButton=world.pause_menu.body.get_node("AutosaveToggle");automatic.button_pressed=false;world.pause_menu.close();world._autosave_if_safe(true)
 check(world.slots.read(2,true).adventure.money==1555 and not Slots.new(prefix).autosave,"Real autosave toggle persists and disables further automatic writes")
 world.slots.set_autosave(true)
 world._begin_pokemon_battle([Mon.make("rattata",8,900000)]);world._autosave_if_safe(true)
 check(world.slots.read(2,true).adventure.money==1555,"Autosave refuses partial battle state")
 world.pokemon_battle.finish("escaped")
 while world.battle_panel.event_index<world.pokemon_battle.events.size():world.battle_panel.advance()
 if world.battle_panel.visible:world.battle_panel.render()
 world._set_locale("en");world._open_menu("dex")
 check(world.pause_menu.body.get_child(0).text.contains("Laboratory catalogue"),"New pages localize in English")
 print("COLLECTION SCENE: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
