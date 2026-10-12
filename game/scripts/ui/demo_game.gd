extends CanvasLayer
signal finished
const Slots=preload("res://scripts/services/demo_slots.gd")
const Guidance=preload("res://scripts/domain/demo_guidance.gd")
const LocalMap=preload("res://scripts/ui/demo_map.gd")
const State=preload("res://scripts/domain/demo_state.gd")
const Mon=preload("res://scripts/domain/pokemon.gd")
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
const World=preload("res://scripts/world/demo_world.gd")
const Style=preload("res://scripts/world/demo_actor_style.gd")
const Battle=preload("res://scripts/services/showdown_battle.gd")
const BattlePanel=preload("res://scripts/ui/demo_battle_panel.gd")
const Stage=preload("res://scripts/world/demo_battle_stage.gd")
var active: bool=false
var owner_world: Node3D
var state:=State.new()
var world: Node3D
var menu: CanvasLayer
var battle_panel: CanvasLayer
var battle: RefCounted
var arena: Node3D
var old_visibility: Dictionary={}
var old_camera: Camera3D
var hud: Label
var feedback: Label
var modal: PanelContainer
var dialogue_lines: Array=[]
var dialogue_index: int=0
var save_path: String="user://archelys-demo-v1.json"
var active_slot: int=1
var loaded_slot: int=0
var contextual: Label
var last_save: int=0
var saved_msaa: int=0
var steps: float=0
var in_transition: bool=false
var locale: String="fr"
var preview_actor: Node3D
func t(fr: String,en: String) -> String:return fr if locale=="fr" else en
func _ready() -> void:layer=30;hide()
func button(parent: Node,text: String,action: Callable,name_value: String="") -> Button:
 var b:=Button.new();b.text=text;b.custom_minimum_size.y=40;b.name=name_value if not name_value.is_empty() else "Action";parent.add_child(b);b.pressed.connect(action);return b
func clear_modal() -> void:
 if modal:remove_child(modal);modal.queue_free();modal=null
func popup(title: String) -> VBoxContainer:
 clear_modal();modal=PanelContainer.new();modal.set_anchors_and_offsets_preset(Control.PRESET_CENTER);modal.offset_left=-330;modal.offset_right=330;modal.offset_top=-150;modal.offset_bottom=200;modal.theme=owner_world.ui_theme;add_child(modal)
 var column:=VBoxContainer.new();column.add_theme_constant_override("separation",12);modal.add_child(column)
 var label:=Label.new();label.text=title;label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;column.add_child(label);return column
func open(owner: Node3D) -> bool:
 if active or owner.pokemon_battle.active or owner.atlas_studio.active or owner.photo_mode.active:return false
 owner_world=owner;locale=owner.locale;old_camera=owner.camera;saved_msaa=get_viewport().msaa_3d;get_viewport().msaa_3d=Viewport.MSAA_4X
 old_visibility={owner.world_geometry:owner.world_geometry.visible}
 for avatar: Node3D in owner.avatars.values():old_visibility[avatar]=avatar.visible
 for child: Node in owner.get_children():
  if child is CanvasLayer and child!=self:old_visibility[child]=child.visible
 for node: Node in old_visibility:node.hide()
 owner.get_node("/root/Session").submit_axis(Vector2.ZERO)
 world=World.new();owner.add_child(world);world.build(state);world.camera.size=owner.camera.size;world.configure_labels(owner.comfort.data.world_labels)
 menu=preload("res://scripts/ui/pause_menu.gd").new();menu.demo_mode=true;menu.adventure=state.campaign.adventure;menu.comfort=owner.comfort;owner.add_child(menu)
 menu.layer=40;menu.panel.theme=owner.ui_theme
 menu.save_requested.connect(save_game);menu.load_requested.connect(load_game)
 menu.preview_renderer=add_avatar_preview;menu.demo_pages_renderer=render_demo_page
 menu.appearance_changed.connect(func():
  Style.apply(world.hero,state.campaign.adventure.appearance)
  if is_instance_valid(preview_actor):Style.apply(preview_actor,state.campaign.adventure.appearance))
 menu.language_changed.connect(func(value: String):
  locale=value;owner._set_locale(value);menu.sync(locale,world.camera.size,state.campaign.laboratory))
 menu.camera_changed.connect(func(value: float):world.camera.size=value;owner.camera.size=value;owner._persist_preferences())
 menu.comfort_changed.connect(func():owner._apply_comfort();world.configure_labels(owner.comfort.data.world_labels))
 menu.audio_preview_requested.connect(func(kind: String):
  if kind=="stop":owner.lab_audio.stop_previews()
  else:owner.lab_audio.preview(kind))
 menu.speed_changed.connect(func(value: float):Engine.time_scale=value)
 menu.closed.connect(func():owner.lab_audio.stop_previews();if state.starter.is_empty():starter_screen())
 battle_panel=BattlePanel.new();battle_panel.comfort=owner.comfort;owner.add_child(battle_panel);battle_panel.finished.connect(battle_finished)
 for child: Node in battle_panel.get_children():
  if child is Control:child.theme=owner.ui_theme
 hud=Label.new();hud.position=Vector2(24,18);hud.add_theme_font_size_override("font_size",19);hud.add_theme_color_override("font_outline_color",Color("1c3540"));hud.add_theme_constant_override("outline_size",4);hud.theme=owner.ui_theme;add_child(hud)
 feedback=Label.new();feedback.position=Vector2(24,100);feedback.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;feedback.custom_minimum_size.x=950;feedback.theme=owner.ui_theme;feedback.add_theme_color_override("font_outline_color",Color.BLACK);feedback.add_theme_constant_override("outline_size",3);add_child(feedback)
 contextual=Label.new();contextual.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE);contextual.offset_top=-60;contextual.offset_bottom=-18;contextual.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;contextual.theme=owner.ui_theme;contextual.add_theme_color_override("font_outline_color",Color.BLACK);contextual.add_theme_constant_override("outline_size",4);add_child(contextual)
 active=true;show();welcome();return true
func welcome() -> void:
 var column:=popup(t("ARCHÉLYS — Démo du havre tropical\nUne ville, un sentier et un premier défi. Sauvegarde distincte de l'atelier.","ARCHÉLYS — Tropical haven demo\nOne town, one trail and a first challenge. Save separate from workshop."))
 button(column,t("Emplacement %d — changer","Slot %d — change") % active_slot,slot_picker,"SelectDemoSlot")
 if not Slots.read(save_path,active_slot).is_empty():button(column,t("Continuer la démo sauvegardée","Continue saved demo"),load_game,"ContinueDemo").grab_focus()
 if not Slots.read(save_path,active_slot,true).is_empty():button(column,t("Restaurer la copie précédente","Restore previous copy"),func():load_slot(active_slot,true),"RecoverDemo")
 button(column,t("Nouvelle aventure de démo","New demo adventure"),func():
  var confirm:=popup(t("Créer une nouvelle démo ? La sauvegarde précédente sera conservée en copie .backup. L'atelier est conservé.","Create a new demo? Previous save retained as .backup. Workshop preserved."))
  button(confirm,t("Commencer","Start"),new_demo,"ConfirmNewDemo").grab_focus();button(confirm,t("Retour","Back"),welcome))
 button(column,t("Retour à l'atelier","Return to workshop"),close)
func slot_path(index: int=0) -> String:return Slots.path(save_path,active_slot if index==0 else index)
func slot_picker() -> void:
 var column:=popup(t("Choisir une partie de démo","Choose a demo save slot"))
 for index: int in range(1,Slots.COUNT+1):
  var key: int=index;var data: Dictionary=Slots.read(save_path,key)
  var detail: String=Catalog.name_of(data.starter,locale) if not data.is_empty() else t("vide / invalide","empty / invalid")
  button(column,t("Emplacement %d : %s","Slot %d: %s") % [key,detail],func():active_slot=key;welcome(),"PickSlot%d" % key)
func new_demo() -> void:
 loaded_slot=active_slot
 state=State.new();state.campaign.adventure.appearance=owner_world.get_node("/root/Session").campaign.adventure.appearance.duplicate()
 state.campaign.adventure.appearance.style=0;menu.adventure=state.campaign.adventure;world.build(state);starter_screen()
func starter_screen() -> void:
 world.build(state)
 var column:=popup(t("Choisis ton premier Pokémon — sélection provisoire pour la démo. Tu peux personnaliser ton personnage avant de partir.","Choose your first Pokémon — provisional demo roster. Customize your character before setting off."))
 for id: String in State.STARTERS:
  var key: String=id
  button(column,Catalog.name_of(id,locale)+" • Nv.6",func():choose_starter(key),"Starter_"+id)
 button(column,t("Personnaliser mon personnage","Customize my character"),func():clear_modal();open_menu("appearance"))
 # Actual models on the starter plaza, not species-name placeholders.
 for i: int in range(3):world.asset("pokemon-"+State.STARTERS[i],Vector3(-2+i*2,0,-2),.7)
func choose_starter(id: String) -> bool:
 if not state.choose(id):return false
 clear_modal();world.build(state);save_game();talk([t("Ton partenaire est prêt ! Vyna t'attend près de la place. E / Entrée : interagir. Échap : menu.","Your partner is ready! Vyna waits by the plaza. E / Enter: interact. Escape: menu.")]);return true
func add_avatar_preview(body: Node) -> void:
 var viewport:=SubViewport.new();viewport.size=Vector2i(360,400);viewport.own_world_3d=true;viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS;body.add_child(viewport)
 var scene:=Node3D.new();viewport.add_child(scene)
 preview_actor=load("res://assets/demo/trainer.glb").instantiate();scene.add_child(preview_actor);Style.apply(preview_actor,state.campaign.adventure.appearance)
 var env:=WorldEnvironment.new();var settings:=Environment.new();settings.background_mode=Environment.BG_COLOR;settings.background_color=Color("dce9e8");settings.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;settings.ambient_light_energy=.7;settings.ambient_light_color=Color.WHITE;env.environment=settings;scene.add_child(env)
 var light:=DirectionalLight3D.new();light.rotation_degrees=Vector3(-35,-30,0);scene.add_child(light)
 var cam:=Camera3D.new();cam.position=Vector3(.08,1.05,2.6);cam.fov=42;scene.add_child(cam);cam.look_at(Vector3(0,.95,0));cam.current=true
 var picture:=TextureRect.new();picture.name="DemoCharacterPreview";picture.texture=viewport.get_texture();picture.custom_minimum_size=Vector2(210,240);picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;body.add_child(picture);body.move_child(picture,0)
func open_menu(page: String="home") -> void:
 clear_modal();menu.adventure=state.campaign.adventure;menu.sync(locale,world.camera.size,state.campaign.laboratory);menu.open(page)
 if page=="home":button(menu.body,t("Revenir à l'atelier (démo sauvegardée)","Return to workshop (demo saved)"),close,"ExitDemo")
 if page=="appearance":
  var selector: OptionButton=menu.body.get_node("Appearance_style")
  for i: int in range(3):selector.set_item_text(i,[t("Casquette","Cap"),t("Cheveux courts","Short hair"),t("Cheveux longs","Long hair")][i])
func talk(lines: Array) -> void:
 dialogue_lines=lines;dialogue_index=0;render_dialogue()
func render_dialogue() -> void:
 if dialogue_index>=dialogue_lines.size():dialogue_lines=[];clear_modal();return
 var column:=popup(str(dialogue_lines[dialogue_index]));button(column,t("Continuer • E / Entrée","Continue • E / Enter"),advance_dialogue,"NextDialogue").grab_focus()
func advance_dialogue() -> void:dialogue_index+=1;render_dialogue()
func interact(id: String="") -> void:
 if state.starter.is_empty() or menu.visible or battle_panel.visible or modal:return
 if id.is_empty():id=world.nearest()
 match id:
  "door-center":travel("center")
  "door-shop":travel("shop")
  "door-home":travel("home")
  "gate":travel("trail")
  "exit":travel("town")
  "vyna":
   if state.flags.has("trainer") and state.flags.has("survey"):
    state.flags.complete=true;save_game();talk([t("Le sentier est sécurisé ! Merci. Cette portion de la première île se termine ici ; tu peux continuer à explorer, capturer et préparer ton équipe.","The trail is safe! Thank you. This first island slice ends here; keep exploring, catching and preparing your party.")])
   else:talk([t("La balise du sentier ne répond plus. Va la relever au nord, puis affronte le dresseur qui garde le passage. Soins et provisions sont disponibles au havre.","The trail beacon has stopped responding. Survey it to the north, then battle the trainer guarding the path. Healing and supplies are available in town.")])
  "professor":talk([t("Tu peux consulter ton partenaire et modifier ses IV, EV et sa nature dans Équipe / Résumé. Les trois starters de cette démo restent provisoires.","View your partner and edit IVs, EVs and nature in Party / Summary. This demo's three starters remain provisional.")])
  "resident":talk([t("Le port vit grâce aux jardins de la jungle et aux sources de la montagne. Notre ville reste ouverte malgré les contrôles au-delà du sentier.","The harbor lives from jungle gardens and mountain springs. Our town remains open despite controls beyond the trail.")])
  "nurse":state.campaign.adventure.heal_team();save_game();talk([t("Ton équipe est soignée et ses PP restaurés.","Your party is healed and its PP restored.")])
  "merchant":open_menu("services")
  "clothier":open_menu("wardrobe")
  "pc":open_menu("pc")
  "mirror":open_menu("appearance")
  "supplies":
   if not state.flags.has("supplies"):
    var a: RefCounted=state.campaign.adventure
    if int(a.bag.get("poke-ball",0))+3<=999 and int(a.bag.get("potion",0))+2<=999:
     a.bag['poke-ball']=int(a.bag.get('poke-ball',0))+3;a.bag.potion=int(a.bag.get('potion',0))+2;state.flags.supplies=true;save_game()
   talk([t("La caisse contient des provisions pour le sentier. Réception unique : trois Balls et deux Potions.","The crate contains trail supplies. One-time gift: three Balls and two Potions.")])
  "survey":state.flags.survey=true;save_game();talk([t("Balise relevée. Le dresseur attend plus loin dans le sentier.","Beacon surveyed. The trainer waits farther along the trail.")])
  "trainer":
   if not state.flags.has("survey"):talk([t("Relève d'abord la balise à l'ouest du sentier.","Survey the beacon west of the trail first.")])
   elif state.flags.has("trainer"):talk([t("Bien joué ! Retourne voir Vyna au havre.","Well done! Return to Vyna in town.")])
   else:begin_battle([Mon.make("rattata",6,900000),Mon.make("pikachu",7,900001)],"demo-trainer")
  "grass":begin_battle([state.campaign.adventure.wild(5,"rattata" if state.campaign.adventure.rng.randi_range(0,1)==0 else "pikachu")])
func travel(id: String) -> void:
 var previous: String=state.location
 if not state.travel(id):return
 if id=="town":
  if previous in ["center","shop","home"]:state.position=World.TOWN_BUILDINGS[previous]+Vector3(0,0,3.5)
  elif previous=="trail":state.position=Vector3(0,0,-21)
 world.build(state);steps=0;save_game()
func begin_battle(enemies: Array,trainer: String="") -> bool:
 if state.starter.is_empty() or modal or menu.visible or battle_panel.visible:return false
 battle=Battle.new()
 if not battle.begin(state.campaign.adventure,enemies,trainer):feedback.text=t("Combat non lancé : ","Battle not started: ")+battle.last_error;return false
 world.hide();arena=Stage.new();owner_world.add_child(arena);arena.battle=battle;arena.animations=owner_world.comfort.data.combat_animations and not owner_world.comfort.data.reduced_motion
 battle_panel.animations_enabled=arena.animations;battle_panel.open(battle,locale);hud.hide();feedback.hide();contextual.hide();return true
func battle_finished(result: String) -> void:
 if battle and result=="won" and battle.trainer=="demo-trainer":state.flags.trainer=true;state.campaign.adventure.money=mini(999999,state.campaign.adventure.money+250)
 if arena:arena.queue_free();arena=null
 world.show();world.camera.current=true;hud.show();feedback.show();contextual.show()
 if result=="lost":state.travel("center");world.build(state)
 feedback.text=t("Combat terminé : ","Battle finished: ")+result;steps=0;save_game()
func save_game() -> void:
 if not active or loaded_slot==0 or state.starter.is_empty() or (battle and battle.active):return
 var error: int=state.save(slot_path(loaded_slot));last_save=Time.get_ticks_msec()
 if feedback:feedback.text=t("Sauvegarde de démo : ","Demo save: ")+error_string(error)
func load_game() -> void:
 if battle and battle.active:return
 var v: Dictionary=Slots.read(save_path,active_slot)
 if v.is_empty() or not state.restore(v):
  if feedback:feedback.text=t("Sauvegarde absente/invalide ; partie conservée.","Save absent/invalid; current game preserved.")
  return
 loaded_slot=active_slot
 clear_modal();menu.close();menu.adventure=state.campaign.adventure;world.build(state);steps=0
func _process(delta: float) -> void:
 if not active:return
 hud.text="ARCHÉLYS • "+t("Havre tropical","Tropical haven")+"\n"+state.objective(locale)+"\n"+t("E / Entrée : interagir • Échap : menu","E / Enter: interact • Escape: menu")
 contextual.text=""
 if modal or menu.visible or battle_panel.visible:return
 var nearby: String=world.nearest()
 if not nearby.is_empty():contextual.text=owner_world.comfort.caption("interact")+" / "+t("Entrée","Enter")+" — "+Guidance.title(nearby,locale)
 var old: Vector3=state.position;world.move_hero(owner_world.comfort.axis(),delta,state)
 var walked: float=old.distance_to(state.position);state.campaign.adventure.nursery.walk(walked)
 if state.location=="trail" and state.position.x>3 and state.position.x<9 and state.position.z> -7 and state.position.z< -1:
  steps+=walked
  if steps>6:steps=0;interact("grass")
 if not state.starter.is_empty() and Time.get_ticks_msec()-last_save>60000:save_game()
func _input(event: InputEvent) -> void:
 if not active:return
 if event is InputEventJoypadButton and event.pressed:
  if battle_panel.visible:
   if event.button_index==JOY_BUTTON_A and battle_panel.event_index<battle.events.size():battle_panel.advance();get_viewport().set_input_as_handled()
   elif event.button_index==JOY_BUTTON_B:
    var back:=InputEventKey.new();back.keycode=KEY_ESCAPE;back.pressed=true;battle_panel.handle_key(back);get_viewport().set_input_as_handled()
   return
  if event.button_index in [JOY_BUTTON_B,JOY_BUTTON_START]:
   if menu.visible:menu.close()
   elif not modal:open_menu()
   get_viewport().set_input_as_handled();return
  if event.button_index==JOY_BUTTON_A and not menu.visible:
   if not dialogue_lines.is_empty():advance_dialogue();get_viewport().set_input_as_handled()
   elif not modal:interact();get_viewport().set_input_as_handled()
  return
 if not event is InputEventKey or not event.pressed or event.echo:return
 if battle_panel.visible:
  if battle_panel.handle_key(event):get_viewport().set_input_as_handled()
  return
 if menu.visible:
  if menu.handle_key(event):get_viewport().set_input_as_handled()
  return
 if not dialogue_lines.is_empty() and owner_world.comfort.confirming(event):advance_dialogue();get_viewport().set_input_as_handled();return
 if modal:return
 if owner_world.comfort.matches(event,"menu"):open_menu();get_viewport().set_input_as_handled()
 elif owner_world.comfort.matches(event,"journal"):open_menu("journal");get_viewport().set_input_as_handled()
 elif owner_world.comfort.matches(event,"bag"):open_menu("bag");get_viewport().set_input_as_handled()
 elif owner_world.comfort.matches(event,"interact") or event.keycode==KEY_ENTER:interact();get_viewport().set_input_as_handled()
func _notification(what: int) -> void:
 if what==NOTIFICATION_WM_CLOSE_REQUEST and active:save_game()
func close() -> void:
 if not active or (battle and battle.active):return
 save_game();active=false;clear_modal();hide()
 for child: Node in [hud,feedback,contextual]:remove_child(child);child.queue_free()
 world.queue_free();menu.queue_free();battle_panel.queue_free()
 for node: Node in old_visibility:
  if is_instance_valid(node):node.visible=old_visibility[node]
 old_camera.current=true;get_viewport().msaa_3d=saved_msaa;old_visibility.clear();finished.emit()

func render_demo_page(page: String,body: Node) -> void:
 if page=="journal":
  var objective:=Label.new();objective.text=state.objective(locale);objective.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;body.add_child(objective)
  for task: Dictionary in Guidance.tasks(state,locale):
   var row:=Label.new();row.text=("✓ " if task.done else "○ ")+task.text;body.add_child(row)
  button(body,t("Voir la carte locale","View local map"),func():menu.page="map";menu.render(),"OpenLocalMap")
 elif page=="map":
  var map:=LocalMap.new();map.world=world;map.state=state;map.target=Guidance.target(state);map.locale=locale;body.add_child(map)
  var legend:=Label.new();legend.text=t("Rouge : toi · Or : objectif · Bleu : interaction
Plan local du lieu actuel, sans déplacement automatique.","Red: you · Gold: objective · Blue: interaction
Local plan of the current area; no automatic travel.");legend.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;body.add_child(legend)
  for id: String in world.points:
   var row:=Label.new();row.text=("→ " if id==map.target else "• ")+Guidance.title(id,locale);body.add_child(row)
 elif page=="saves":
  var label:=Label.new();label.text=t("Partie active : emplacement %d. Autosauvegarde toutes les 60 s d'exploration.
La copie précédente .backup est conservée pour chaque emplacement.","Active save: slot %d. Autosave every 60 seconds of exploration.
Previous .backup copy retained for each slot.") % active_slot;label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;body.add_child(label)
  button(body,t("Sauvegarder la partie active","Save active game"),save_game,"SaveActiveDemo")
  for index: int in range(1,Slots.COUNT+1):
   var key: int=index;var data: Dictionary=Slots.read(save_path,key)
   var detail: String=Catalog.name_of(data.starter,locale) if not data.is_empty() else t("vide / invalide","empty / invalid")
   var row:=Label.new();row.text=t("Emplacement %d : %s","Slot %d: %s") % [key,detail];body.add_child(row)
   if not data.is_empty():button(body,t("Charger cet emplacement","Load this slot"),func():confirm_slot(key,false),"LoadDemo%d" % key)
   if not Slots.read(save_path,key,true).is_empty():button(body,t("Restaurer sa copie précédente","Restore previous copy"),func():confirm_slot(key,true),"BackupDemo%d" % key)
   button(body,t("Nouvelle partie ici","New game here"),func():confirm_new_slot(key),"NewDemo%d" % key)
func confirm_slot(index: int,backup: bool) -> void:
 menu.visible=false
 var column:=popup(t("Charger l'emplacement %d ? La progression non sauvegardée sera remplacée.","Load slot %d? Unsaved progress will be replaced.") % index)
 button(column,t("Confirmer","Confirm"),func():load_slot(index,backup),"ConfirmLoadSlot").grab_focus()
 button(column,t("Annuler","Cancel"),func():open_menu("saves"))
func load_slot(index: int,backup: bool=false) -> bool:
 if battle and battle.active:return false
 var data: Dictionary=Slots.read(save_path,index,backup)
 if data.is_empty() or not state.restore(data):
  clear_modal();open_menu("saves");feedback.text=t("Emplacement absent ou invalide ; partie conservée.","Missing or invalid slot; game preserved.");return false
 active_slot=index;loaded_slot=index;clear_modal();menu.visible=false;menu.adventure=state.campaign.adventure;world.build(state);steps=0;last_save=Time.get_ticks_msec();return true
func confirm_new_slot(index: int) -> void:
 menu.visible=false
 var column:=popup(t("Nouvelle partie dans l'emplacement %d ? Sa dernière sauvegarde sera conservée en .backup à la première sauvegarde.","New game in slot %d? Its last save will be retained as .backup at the first save.") % index)
 button(column,t("Commencer","Start"),func():active_slot=index;new_demo(),"ConfirmNewSlot").grab_focus()
 button(column,t("Annuler","Cancel"),func():open_menu("saves"))
