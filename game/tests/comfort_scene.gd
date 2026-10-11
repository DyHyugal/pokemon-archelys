extends SceneTree
const Comfort=preload("res://scripts/services/comfort_store.gd")
const Slots=preload("res://scripts/services/save_slots.gd")
const Mon=preload("res://scripts/domain/pokemon.gd")
var checks:=0
var failures:=0
func check(ok: bool,label: String) -> void:
 checks+=1
 if not ok:failures+=1;push_error(label)
func key(code: Key,echo: bool=false) -> void:
 var event:=InputEventKey.new();event.keycode=code;event.physical_keycode=code;event.pressed=true;event.echo=echo;root.push_input(event,true)
func press(menu: CanvasLayer,needle: String) -> bool:
 for control: Node in menu.body.get_children():
  if control is Button and control.text.contains(needle):control.pressed.emit();return true
 return false
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var path: String="user://tests_comfort_scene.json";DirAccess.remove_absolute(path)
 var world: Node=load("res://main.tscn").instantiate();world.comfort=Comfort.new(path);world.slots=Slots.new("user://tests_comfort_scene_campaign");world.preferences_path="user://tests_comfort_scene_prefs.json";root.add_child(world)
 await process_frame;await process_frame
 world._set_locale("fr");world._open_menu("settings")
 var pages: RefCounted=world.pause_menu.comfort_pages
 pages.sliders.music.value=35;pages.sliders.effects.value=0
 check(world.comfort.data.music==35 and world.comfort.data.effects==0 and AudioServer.is_bus_mute(world.lab_audio.buses.effects) and is_equal_approx(AudioServer.get_bus_volume_linear(world.lab_audio.buses.music),0.35),"Real sliders update separate buses and persist preferences")
 press(world.pause_menu,"Écouter la mélodie")
 check(world.lab_audio.players.music.playing,"Actual preview button starts original music sample")
 press(world.pause_menu,"Arrêter les sons")
 check(not world.lab_audio.players.music.playing,"Actual stop button stops audio")
 var size: OptionButton=world.pause_menu.body.get_node("TextSize");size.item_selected.emit(2);await process_frame
 check(world.pause_menu.body.get_child(0).get_theme_font_size("font_size")==24 and world.battle_panel.message.get_theme_font_size("font_size")==24 and world.cinematic_panel.text.get_theme_font_size("font_size")==24,"Text size propagates to menu, battle and cinematic body text")
 check(press(world.pause_menu,"Interagir / texte suivant") and pages.capture_action=="interact","Binding control enters key capture")
 key(KEY_F3);check(pages.capture_action=="interact" and world.comfort.keys("interact")==[KEY_E],"Reserved key rejected without activating debug tools")
 key(KEY_I);check(pages.capture_action=="interact" and world.comfort.keys("interact")==[KEY_E],"Conflict with existing bag shortcut rejected")
 key(KEY_F,true);check(pages.capture_action=="interact","Echo event does not bind a key")
 key(KEY_F);check(pages.capture_action.is_empty() and world.comfort.keys("interact")==[KEY_F] and Comfort.new(path).keys("interact")==[KEY_F],"Physical binding accepted and survives fresh disk read")
 press(world.pause_menu,"Aller à gauche");key(KEY_ESCAPE)
 check(pages.capture_action.is_empty() and world.pause_menu.visible and world.pause_menu.page=="settings","Escape cancels capture without closing settings")
 press(world.pause_menu,"Ouvrir le menu");key(KEY_M)
 world.pause_menu.close();key(KEY_M)
 check(world.pause_menu.visible and world.pause_menu.page=="home","Custom menu shortcut opens actual menu")
 key(KEY_ESCAPE);check(not world.pause_menu.visible,"Escape still safely closes menu after remap")
 world._open_menu("settings");press(world.pause_menu,"Aller à gauche");key(KEY_K);world.pause_menu.close()
 var session: Node=root.get_node("Session")
 session.campaign.players[1].position=[0.0,0.0,0.0];session.latest=session.campaign.snapshot()
 var event:=InputEventKey.new();event.physical_keycode=KEY_K;event.keycode=KEY_K;event.pressed=true;Input.parse_input_event(event)
 for i: int in range(20):await physics_frame
 event.pressed=false;Input.parse_input_event(event)
 check(session.campaign.players[1].position[0]<-0.2,"Custom movement key drives authoritative solo movement")
 check(not world.comfort.keys("left").has(KEY_A),"Rebinding replaces old movement aliases")
 session.campaign.players[1].position=[3.0,0.0,5.0];session.latest=session.campaign.snapshot()
 world.comfort.bind("interact",KEY_TAB);world._apply_comfort();key(KEY_TAB)
 check(world.dialogue.active and world.dialogue.index==0,"Custom Tab interaction opens world dialogue before GUI focus navigation")
 while world.dialogue.active:key(KEY_TAB)
 world.comfort.bind("interact",KEY_F);world._apply_comfort()
 world._open_interaction("guide");world.dialogue_panel.visible=true
 var before: int=world.dialogue.index;key(KEY_E)
 check(world.dialogue.index==before,"Old interaction key no longer advances world dialogue")
 key(KEY_F);check(world.dialogue.index==before+1,"Custom interaction advances actual dialogue once")
 key(KEY_F,true);check(world.dialogue.index==before+1,"Holding custom confirm never auto-advances dialogue")
 while world.dialogue.active:key(KEY_F)
 world._begin_pokemon_battle([Mon.make("rattata",8,900000)])
 var deadline: int=Time.get_ticks_msec()+12000
 while world.pokemon_battle.busy and Time.get_ticks_msec()<deadline:await create_timer(0.01).timeout
 check(not world.pokemon_battle.busy and world.pokemon_battle.last_error.is_empty(),"Showdown initial messages ready")
 before=world.battle_panel.event_index
 key(KEY_E);check(world.battle_panel.event_index==before,"Old interaction key no longer advances battle text")
 key(KEY_F);check(world.battle_panel.event_index==before+1,"Custom confirm advances actual battle text")
 world.pokemon_battle.finish("escaped")
 while world.battle_panel.event_index<world.pokemon_battle.events.size():world.battle_panel.advance()
 if world.battle_panel.visible:world.battle_panel.render()
 world._play_scene("lab-tour");before=world.cinematic.index;key(KEY_F)
 check(world.cinematic.index==before+1,"Same custom confirm advances cinematics")
 while world.cinematic.active:key(KEY_F)
 world.pause_menu.close();world._save();world._load()
 check(world.comfort.keys("interact")==[KEY_F] and world.comfort.data.text_size==24 and world.comfort.data.music==35,"Campaign load preserves separate local preferences")
 world._open_menu("settings");press(world.pause_menu,"Restaurer uniquement")
 check(world.comfort.keys("interact")==[KEY_E] and world.comfort.keys("left").has(KEY_A) and world.comfort.data.text_size==24 and world.comfort.data.music==35,"Actual reset keys preserves other comfort settings")
 press(world.pause_menu,"Écouter la mélodie");world.pause_menu.close()
 check(not world.lab_audio.players.music.playing,"Closing settings stops calibration audio")
 world._set_locale("en");world._open_menu("settings")
 check(world.pause_menu.body.get_children().any(func(node: Node):return node is Label and node.text=="Keyboard controls"),"New settings localize in English")
 print("COMFORT SCENE: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
