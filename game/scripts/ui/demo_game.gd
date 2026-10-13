extends CanvasLayer
signal finished
const Chapter=preload("res://scripts/domain/demo_chapter.gd")
const ChapterUI=preload("res://scripts/ui/demo_chapter_controller.gd")
const RegionMap=preload("res://scripts/ui/demo_region_map.gd")
const Extended=preload("res://scripts/ui/demo_extended_pages.gd")
const Expedition=preload("res://scripts/domain/demo_expedition.gd")
const Archive=preload("res://scripts/services/demo_archive.gd")
const Cinematic=preload("res://scripts/domain/cinematic.gd")
const Content=preload("res://scripts/domain/demo_content.gd")
const Systems=preload("res://scripts/ui/demo_system_pages.gd")
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
var scene:=Cinematic.new()
var scene_camera:=Transform3D()
var scene_size: float=18
var dex_query: String=""
var dex_filter: int=0
var archive_picker: FileDialog
var use_hd2d: bool=false
var hd2d_view: CanvasLayer
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
 world=World.new();world.logic_only=use_hd2d;world.locale=locale;owner.add_child(world);world.build(state);world.camera.size=owner.camera.size;world.configure_labels(owner.comfort.data.world_labels)
 menu=preload("res://scripts/ui/pause_menu.gd").new();menu.demo_mode=true;menu.adventure=state.campaign.adventure;menu.comfort=owner.comfort;owner.add_child(menu)
 menu.layer=40;menu.panel.theme=owner.ui_theme;menu.speed=float(owner.comfort.data.game_speed)
 menu.save_requested.connect(save_game);menu.load_requested.connect(load_game)
 menu.preview_renderer=add_avatar_preview;menu.demo_pages_renderer=render_demo_page
 menu.appearance_changed.connect(func():
  Style.apply(world.hero,state.campaign.adventure.appearance)
  if is_instance_valid(preview_actor):Style.apply(preview_actor,state.campaign.adventure.appearance))
 menu.language_changed.connect(func(value: String):
  locale=value;world.locale=value;world.configure_labels(world.show_labels);owner._set_locale(value);menu.sync(locale,world.camera.size,state.campaign.laboratory))
 menu.camera_changed.connect(func(value: float):world.camera.size=value;owner.camera.size=value;owner._persist_preferences())
 menu.comfort_changed.connect(func():owner._apply_comfort();world.configure_labels(owner.comfort.data.world_labels))
 menu.audio_preview_requested.connect(func(kind: String):
  if kind=="stop":owner.lab_audio.stop_previews()
  else:owner.lab_audio.preview(kind))
 menu.speed_changed.connect(func(value: float):
  var error: int=owner._set_game_speed(value)
  if error!=OK:menu.feedback.text=t("Réglage non enregistré : ","Setting not saved: ")+error_string(error))
 menu.closed.connect(func():
  owner.lab_audio.stop_previews()
  if state.starter.is_empty():starter_screen()
  else:persist_auto())
 battle_panel=BattlePanel.new();battle_panel.comfort=owner.comfort;owner.add_child(battle_panel);battle_panel.finished.connect(battle_finished)
 for child: Node in battle_panel.get_children():
  if child is Control:child.theme=owner.ui_theme
 hud=Label.new();hud.position=Vector2(24,18);hud.add_theme_font_size_override("font_size",19);hud.add_theme_color_override("font_outline_color",Color("1c3540"));hud.add_theme_constant_override("outline_size",4);hud.theme=owner.ui_theme;add_child(hud)
 feedback=Label.new();feedback.position=Vector2(24,100);feedback.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;feedback.custom_minimum_size.x=950;feedback.theme=owner.ui_theme;feedback.add_theme_color_override("font_outline_color",Color.BLACK);feedback.add_theme_constant_override("outline_size",3);add_child(feedback)
 contextual=Label.new();contextual.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE);contextual.offset_top=-60;contextual.offset_bottom=-18;contextual.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;contextual.theme=owner.ui_theme;contextual.add_theme_color_override("font_outline_color",Color.BLACK);contextual.add_theme_constant_override("outline_size",4);add_child(contextual)
 active=true
 if use_hd2d:
  world.hide();hd2d_view=preload("res://scripts/world/hd2d_view.gd").new();hd2d_view.game=self;owner.add_child(hd2d_view)
 show();welcome();return true
func welcome() -> void:
 var column:=popup(t("ARCHÉLYS — Démo du havre tropical\nUne ville, un sentier et un premier défi. Sauvegarde distincte de l'atelier.","ARCHÉLYS — Tropical haven demo\nOne town, one trail and a first challenge. Save separate from workshop."))
 button(column,t("Emplacement %d — changer","Slot %d — change") % active_slot,slot_picker,"SelectDemoSlot")
 if not Slots.read_auto(save_path,active_slot).is_empty():button(column,t("Continuer l’autosauvegarde","Continue autosave"),func():apply_archive(Slots.read_auto(save_path,active_slot),active_slot),"ContinueDemoAuto").grab_focus()
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
 if Content.data().is_empty():
  var column:=popup(t("Configuration de démo invalide : vérifier les espèces et niveaux dans data/demo/content.json.","Invalid demo configuration: check species and levels in data/demo/content.json."));button(column,t("Retour","Back"),welcome);return
 loaded_slot=active_slot
 state=State.new();state.campaign.adventure.appearance=owner_world.get_node("/root/Session").campaign.adventure.appearance.duplicate()
 state.campaign.adventure.appearance.style=0;menu.adventure=state.campaign.adventure;world.build(state);starter_screen()
func starter_screen() -> void:
 world.build(state)
 var column:=popup(t("Choisis ton premier Pokémon — sélection provisoire pour la démo. Tu peux personnaliser ton personnage avant de partir.","Choose your first Pokémon — provisional demo roster. Customize your character before setting off."))
 for id: String in Content.data().starters:
  var key: String=id
  button(column,Catalog.name_of(id,locale)+" • Nv.%d" % int(Content.data().starter_level),func():choose_starter(key),"Starter_"+id)
 button(column,t("Personnaliser mon personnage","Customize my character"),func():clear_modal();open_menu("appearance"))
 # Actual models on the starter plaza, not species-name placeholders.
 for i: int in range(Content.data().starters.size()):
  var path: String="res://assets/demo/pokemon-"+Content.data().starters[i]+".glb"
  if ResourceLoader.exists(path):world.asset("pokemon-"+Content.data().starters[i],Vector3(-2+i*2,0,-2),.7)
func choose_starter(id: String) -> bool:
 if not state.choose(id):return false
 clear_modal();world.build(state);save_game();persist_auto(true);talk([t("Ton partenaire est prêt ! Vyna t'attend près de la place. E / Entrée : interagir. Échap : menu.","Your partner is ready! Vyna waits by the plaza. E / Enter: interact. Escape: menu.")]);return true
func add_avatar_preview(body: Node) -> void:
 if use_hd2d:
  for field: String in ["skin","shirt","pants","hair","style","face"]:
   var control: Node=body.get_node_or_null("Appearance_"+field)
   if control is OptionButton:control.disabled=true
  var picture:=TextureRect.new();picture.texture=load("res://assets/hd2d/hero-0-idle-0.png");picture.custom_minimum_size=Vector2(180,240);picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;body.add_child(picture)
  var note:=Label.new();note.text=t("Prototype 2D : apparence fixe ; tes choix sauvegardés restent conservés.","2D prototype: fixed appearance; saved choices preserved.");note.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;body.add_child(note);return
 for field: String in ["style","face"]:
  var control: OptionButton=body.get_node("Appearance_"+field)
  control.disabled=true
  control.tooltip_text=t("Pas encore disponible sur le pilote Tripo ; choix sauvegardé conservé.","Not yet supported by the Tripo pilot; saved choice retained.")
 var note:=Label.new();note.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;note.text=t("Pilote Tripo : couleurs expérimentales ; coiffure/visage fixes. Marche/course intégrées ; maintenir Maj pour courir.","Tripo pilot: experimental colors; fixed hairstyle/face. Walk/run integrated; hold Shift to run.");body.add_child(note)
 var viewport:=SubViewport.new();viewport.size=Vector2i(360,400);viewport.own_world_3d=true;viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS;body.add_child(viewport)
 var scene:=Node3D.new();viewport.add_child(scene)
 preview_actor=preload("res://scripts/world/tripo_actor.gd").create();scene.add_child(preview_actor);Style.apply(preview_actor,state.campaign.adventure.appearance)
 var env:=WorldEnvironment.new();var settings:=Environment.new();settings.background_mode=Environment.BG_COLOR;settings.background_color=Color("dce9e8");settings.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;settings.ambient_light_energy=.7;settings.ambient_light_color=Color.WHITE;env.environment=settings;scene.add_child(env)
 var light:=DirectionalLight3D.new();light.rotation_degrees=Vector3(-35,-30,0);scene.add_child(light)
 var cam:=Camera3D.new();cam.position=Vector3(.08,1.0,3.1);cam.fov=42;scene.add_child(cam);cam.look_at(Vector3(0,.95,0));cam.current=true
 var picture:=TextureRect.new();picture.name="DemoCharacterPreview";picture.texture=viewport.get_texture();picture.custom_minimum_size=Vector2(210,240);picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;body.add_child(picture);body.move_child(picture,0)
func open_menu(page: String="home") -> void:
 clear_modal();menu.adventure=state.campaign.adventure;menu.sync(locale,world.camera.size,state.campaign.laboratory);menu.open(page)
 if page=="home":
  if not state.campaign.adventure.pending.is_empty():button(menu.body,t("Préparer les %d choix en attente","Review %d pending choices") % state.campaign.adventure.pending.size(),func():open_menu("choices"),"ReviewPendingChoices")
  button(menu.body,t("Revenir à l'atelier (démo sauvegardée)","Return to workshop (demo saved)"),close,"ExitDemo")
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
 if ChapterUI.new(self).interact(id):return
 match id:
  "door-center":travel("center")
  "door-shop":travel("shop")
  "door-home":travel("home")
  "gate":travel("trail")
  "exit":travel("town")
  "vyna":
   if state.flags.has("trainer") and state.flags.has("survey"):
    state.flags.complete=true;persist_auto()
    if not state.campaign.adventure.records.scenes.has("demo-return"):play_scene("demo-return")
    else:ChapterUI.new(self).vyna()
   elif not state.campaign.adventure.records.scenes.has("demo-arrival"):play_scene("demo-arrival")
   else:talk([t("La balise du sentier ne répond plus. Va la relever au nord, puis affronte le dresseur qui garde le passage. Soins et provisions sont disponibles au havre.","The trail beacon has stopped responding. Survey it to the north, then battle the trainer guarding the path. Healing and supplies are available in town.")])
  "professor":
   var column:=popup(t("Professeur — préparation de l’équipe","Professor — party preparation"))
   button(column,t("Œuf cadeau / incubateur (essai)","Gift egg / incubator (test)"),func():open_menu("nursery"),"ProfessorIncubator")
   button(column,t("Remettre les relevés du sentier","Turn in trail field notes"),func():
    var ok: bool=Expedition.reward(state);persist_auto();talk([t("Relevés reçus : cinq Poké Balls !","Notes received: five Poké Balls!") if ok else t("Explore les trois obstacles du sentier et relève la cache. Récompense unique ; place nécessaire dans le sac.","Explore the three trail obstacles and survey the cache. One-time reward; bag space required.")]),"ExpeditionReward")
   button(column,t("Conseils","Advice"),func():talk([t("Tu peux consulter ton partenaire et modifier ses IV, EV et sa nature dans Équipe / Résumé. Les trois starters de cette démo restent provisoires.","View your partner and edit IVs, EVs and nature in Party / Summary. This demo's three starters remain provisional.")]),"ProfessorAdvice")
   button(column,t("Retour","Back"),clear_modal)
  "resident":talk([t("Le port vit grâce aux jardins de la jungle et aux sources de la montagne. Notre ville reste ouverte malgré les contrôles au-delà du sentier.","The harbor lives from jungle gardens and mountain springs. Our town remains open despite controls beyond the trail.")])
  "fossils":open_menu("services")
  "fish":begin_battle([state.campaign.adventure.wild(int(Content.data().fishing_level),Content.data().fishing)])
  "nurse":state.campaign.adventure.heal_team();persist_auto();talk([t("Ton équipe est soignée et ses PP restaurés.","Your party is healed and its PP restored.")])
  "merchant":open_menu("services")
  "clothier":open_menu("wardrobe")
  "pc":open_menu("pc")
  "mirror":open_menu("appearance")
  "supplies":
   var received:=false
   if not state.flags.has("supplies") and state.campaign.adventure.grant_items({"poke-ball":3,"potion":2}):
    received=true;state.flags.supplies=true;persist_auto()
   talk([t("Provisions reçues : trois Balls et deux Potions.","Supplies received: three Balls and two Potions.") if received else (t("Ces provisions ont déjà été récupérées.","These supplies have already been collected.") if state.flags.has("supplies") else t("Pas assez de place dans le sac. Les provisions restent dans la caisse.","Not enough bag space. The supplies remain in the crate."))])
  "survey":state.flags.survey=true;persist_auto();talk([t("Balise relevée. Le dresseur attend plus loin dans le sentier.","Beacon surveyed. The trainer waits farther along the trail.")])
  "trainer":
   if not state.flags.has("survey"):talk([t("Relève d'abord la balise à l'ouest du sentier.","Survey the beacon west of the trail first.")])
   elif state.flags.has("trainer"):talk([t("Bien joué ! Retourne voir Vyna au havre.","Well done! Return to Vyna in town.")])
   else:begin_battle(Content.opponents(),"demo-trainer")
  "cut","rock-smash","strength":
   var ok: bool=Expedition.perform(state,id)
   if ok:world.build(state);persist_auto()
   talk([t("Passage dégagé grâce au déblocage scénaristique. Aucun Pokémon compatible requis.","Passage cleared using the story unlock. No compatible Pokémon required.") if ok else t("Rétablis d’abord la balise pour débloquer cette action.","Restore the beacon first to unlock this action.")])
  "expedition-cache":
   var ok: bool=Expedition.open_cache(state);persist_auto()
   talk([t("Relevés récupérés. Remets-les au professeur sur la place.","Notes recovered. Bring them to the professor on the plaza.") if ok else t("Dégage les trois obstacles pour accéder aux relevés ; récupération unique.","Clear the three obstacles to access the notes; collect once.")])
  "grass":begin_battle([state.campaign.adventure.wild(int(Content.data().wild_level),Content.data().wild[state.campaign.adventure.rng.randi_range(0,Content.data().wild.size()-1)])])
func travel(id: String,flight: bool=false) -> void:
 var previous: String=state.location
 if not state.travel(id,flight):return
 if id=="town":
  if previous=="shop":state.position=World.shop_door_position()
  elif previous in ["center","home"]:state.position=World.TOWN_BUILDINGS[previous]+Vector3(0,0,3.5)
  elif previous=="trail":state.position=Vector3(0,0,-21)
 world.build(state);steps=0;persist_auto()
func begin_battle(enemies: Array,trainer: String="") -> bool:
 if state.starter.is_empty() or modal or menu.visible or battle_panel.visible:return false
 battle=Battle.new()
 battle.progression_handler=func(id: String):state.chapter.won(state,id)
 if not battle.begin(state.campaign.adventure,enemies,trainer):feedback.text=t("Combat non lancé : ","Battle not started: ")+battle.last_error;return false
 world.hide()
 var animated: bool=owner_world.comfort.data.combat_animations and not owner_world.comfort.data.reduced_motion
 if not use_hd2d:
  arena=Stage.new();owner_world.add_child(arena);arena.battle=battle;arena.locale=locale;arena.animations=animated
 battle_panel.animations_enabled=animated;battle_panel.open(battle,locale);hud.hide();feedback.hide();contextual.hide();return true
func battle_finished(result: String) -> void:
 if battle and result=="won" and battle.trainer=="demo-trainer":state.flags.trainer=true;state.campaign.adventure.money=mini(999999,state.campaign.adventure.money+250)
 if arena:arena.queue_free();arena=null
 world.show();world.camera.current=true;hud.show();feedback.show();contextual.show()
 if result=="lost":
  # Defeat is a deliberate return to the haven, not a normal walking portal.
  state.location="town";state.travel("center")
 world.build(state)
 feedback.text=t("Combat terminé : ","Battle finished: ")+result;steps=0;persist_auto()
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
 if owner_world.photo_mode.active:return
 hud.text="ARCHÉLYS • "+Chapter.name_of(state.location,locale)+(t(" • %d choix en attente"," • %d pending choices") % state.campaign.adventure.pending.size() if not state.campaign.adventure.pending.is_empty() else "")+"\n"+state.objective(locale)+"\n"+t("%s / Entrée : interagir • %s : menu • %s / RB : courir","%s / Enter: interact • %s: menu • %s / RB: run") % [owner_world.comfort.caption("interact"),owner_world.comfort.caption("menu"),owner_world.comfort.caption("run")]
 contextual.text=""
 if modal or menu.visible or battle_panel.visible:
  preload("res://scripts/world/tripo_actor.gd").animate(world.hero,false,false)
  return
 var nearby: String=world.nearest()
 if not nearby.is_empty():contextual.text=owner_world.comfort.caption("interact")+" / "+t("Entrée","Enter")+" — "+Guidance.title(nearby,locale)
 var old: Vector3=state.position;world.move_hero(owner_world.comfort.axis(),delta,state,owner_world.comfort.wants_run())
 var walked: float=old.distance_to(state.position);state.campaign.adventure.nursery.walk(walked)
 if state.location in ["trail","canopy"] and state.position.x>3 and state.position.x<9 and ((state.position.z> -7 and state.position.z< -1) if state.location=="trail" else (state.position.z> -1 and state.position.z<5)):
  steps+=walked
  if steps>6:steps=0;interact("grass" if state.location=="trail" else "chapter-grass")
 if state.autosave and not state.starter.is_empty() and Time.get_ticks_msec()-last_save>60000:auto_save()
func _input(event: InputEvent) -> void:
 if not active:return
 if owner_world.photo_mode.active:
  if event is InputEventJoypadButton and event.pressed and event.button_index in [JOY_BUTTON_B,JOY_BUTTON_START]:owner_world.photo_mode.close();get_viewport().set_input_as_handled()
  else:owner_world.photo_mode.handle_key(event)
  return
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
   if scene.active:advance_scene();get_viewport().set_input_as_handled()
   elif not dialogue_lines.is_empty():advance_dialogue();get_viewport().set_input_as_handled()
   elif not modal:interact();get_viewport().set_input_as_handled()
  return
 if not event is InputEventKey or not event.pressed or event.echo:return
 if battle_panel.visible:
  if battle_panel.handle_key(event):get_viewport().set_input_as_handled()
  return
 if menu.visible:
  if menu.handle_key(event):get_viewport().set_input_as_handled()
  return
 if scene.active and owner_world.comfort.confirming(event):advance_scene();get_viewport().set_input_as_handled();return
 if not dialogue_lines.is_empty() and owner_world.comfort.confirming(event):advance_dialogue();get_viewport().set_input_as_handled();return
 if modal:return
 if owner_world.comfort.matches(event,"menu"):open_menu();get_viewport().set_input_as_handled()
 elif owner_world.comfort.matches(event,"journal"):open_menu("journal");get_viewport().set_input_as_handled()
 elif owner_world.comfort.matches(event,"bag"):open_menu("bag");get_viewport().set_input_as_handled()
 elif owner_world.comfort.matches(event,"interact") or event.keycode==KEY_ENTER:interact();get_viewport().set_input_as_handled()
func _notification(what: int) -> void:
 if what==NOTIFICATION_WM_CLOSE_REQUEST and active:persist_auto()
func close() -> void:
 if not active or owner_world.photo_mode.active or (battle and battle.active):return
 if hd2d_view:hd2d_view.queue_free();hd2d_view=null
 persist_auto();active=false;clear_modal();hide()
 for child: Node in [hud,feedback,contextual]:remove_child(child);child.queue_free()
 world.queue_free();menu.queue_free();battle_panel.queue_free()
 for node: Node in old_visibility:
  if is_instance_valid(node):node.visible=old_visibility[node]
 old_camera.current=true;get_viewport().msaa_3d=saved_msaa;old_visibility.clear();finished.emit()

func render_demo_page(page: String,body: Node) -> void:
 if use_hd2d and page=="photo":
  menu.label(t("Mode photo 2D à adapter. Les réglages et anciennes photos sont conservés.","2D photo mode pending adaptation. Previous settings/photos preserved."));return
 if page in ["dex","pc","services","cinema","assets"]:Extended.new(self).render(page);return
 if page in ["rules","photo","nursery","bag"]:Systems.new(self).render(page);return
 if page=="journal":
  var objective:=Label.new();objective.text=state.objective(locale);objective.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;body.add_child(objective)
  for task: Dictionary in Guidance.tasks(state,locale):
   var row:=Label.new();row.text=("✓ " if task.done else "○ ")+task.text;body.add_child(row)
  if state.chapter.flags.has("started"):
   for task: Dictionary in state.chapter.tasks(locale):
    var row:=Label.new();row.text=("✓ " if task.done else "○ ")+task.text;body.add_child(row)
   for id: String in state.chapter.ceilings:
    var row:=Label.new();row.text=t("Palier enregistré %s : %d","Recorded ceiling %s: %d") % [Guidance.title({"demo-roadblock":"roadblock","demo-spring-keeper":"spring-keeper","demo-post-a":"post-a","demo-post-b":"post-b"}[id],locale),state.chapter.ceilings[id]];body.add_child(row)
  for action: String in Expedition.ACTIONS:
   var row:=Label.new();row.text=("✓ " if state.flags.has(Expedition.ACTIONS[action]) else "○ ")+Guidance.title(action,locale);body.add_child(row)
  var side:=Label.new();side.text=t("Optionnel : dégager les trois obstacles, récupérer les relevés, puis les remettre au professeur (5 Balls, une fois).","Optional: clear three obstacles, collect notes, then turn them in to the professor (5 Balls, once).");side.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;body.add_child(side)
  button(body,t("Voir la carte locale","View local map"),func():menu.page="map";menu.render(),"OpenLocalMap")
 elif page=="map":
  var region:=RegionMap.new();region.state=state;region.locale=locale;body.add_child(region)
  var map:=LocalMap.new();map.world=world;map.state=state;map.target=Guidance.target(state);map.locale=locale;body.add_child(map)
  var legend:=Label.new();legend.text=t("Rouge : toi · Or : objectif · Bleu : interaction
Plan local du lieu actuel, sans déplacement automatique.","Red: you · Gold: objective · Blue: interaction
Local plan of the current area; no automatic travel.");legend.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;body.add_child(legend)
  for id: String in world.points:
   var row:=Label.new();row.text=("→ " if id==map.target else "• ")+Guidance.title(id,locale);body.add_child(row)
  for id: String in ["town","trail"]+Chapter.LOCATIONS:
   var target: String=id
   var fly: Button=button(body,t("Vol : ","Fly: ")+Chapter.name_of(id,locale),func():fly_to(target),"Fly_"+id);fly.disabled=not Expedition.can_fly(state,id)
  var notice:=Label.new();notice.text=t("Vol débloqué après le retour à Vyna ; destinations visitées uniquement. Aucun Pokémon requis.","Fly unlocks after returning to Vyna; visited destinations only. No Pokémon required.");notice.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;body.add_child(notice)
 elif page=="saves":
  var label:=Label.new();label.text=t("Partie active : emplacement %d. Autosauvegarde séparée toutes les 60 s d'exploration (si activée).
La copie précédente .backup est conservée pour chaque emplacement.","Active save: slot %d. Separate autosave every 60 seconds of exploration (if enabled).
Previous .backup copy retained for each slot.") % loaded_slot;label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;body.add_child(label)
  Extended.new(self).render("saves")
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

func start_photo() -> bool:
 if use_hd2d:return false
 if not active or (battle and battle.active) or modal:return false
 return owner_world.photo_mode.start(owner_world,world.camera,world.hero)

func fly_to(target: String) -> bool:
 if not Expedition.can_fly(state,target):return false
 menu.close();travel(target,true);return true
func auto_save() -> void:
 if modal or menu.visible:return
 persist_auto()
func persist_auto(force: bool=false) -> void:
 if (not state.autosave and not force) or loaded_slot==0 or state.starter.is_empty() or (battle and battle.active):return
 var error: int=state.save(Slots.auto_path(save_path,loaded_slot));last_save=Time.get_ticks_msec()
 if error!=OK:feedback.text=t("Autosauvegarde : ","Autosave: ")+error_string(error)
func confirm_auto(index: int) -> void:
 menu.visible=false;var column:=popup(t("Charger l’autosauvegarde %d ? La progression non sauvegardée sera remplacée.","Load autosave %d? Unsaved progress will be replaced.") % index)
 button(column,t("Confirmer","Confirm"),func():
  var data: Dictionary=Slots.read_auto(save_path,index)
  if data.is_empty():clear_modal();open_menu("saves");return
  apply_archive(data,index),"ConfirmDemoAuto")
 button(column,t("Annuler","Cancel"),func():open_menu("saves"))
func apply_archive(data: Dictionary,index: int) -> bool:
 if (battle and battle.active) or not state.restore(data):return false
 active_slot=index;loaded_slot=index;clear_modal();menu.visible=false;menu.adventure=state.campaign.adventure;world.build(state);steps=0;last_save=Time.get_ticks_msec();return true
func archive_dialog(importing: bool) -> void:
 if battle and battle.active:return
 archive_picker=FileDialog.new();archive_picker.use_native_dialog=true;archive_picker.access=FileDialog.ACCESS_FILESYSTEM;archive_picker.file_mode=FileDialog.FILE_MODE_OPEN_FILE if importing else FileDialog.FILE_MODE_SAVE_FILE;archive_picker.filters=PackedStringArray(["*.json ; Archélys demo save"]);add_child(archive_picker)
 archive_picker.current_file="Archelys-demo.json" if not importing else ""
 archive_picker.file_selected.connect(func(path: String):
  if importing:confirm_import(path)
  else:menu.feedback.text=t("Export : ","Export: ")+error_string(Archive.export_file(state,path))
  archive_picker.queue_free();archive_picker=null)
 archive_picker.canceled.connect(func():archive_picker.queue_free();archive_picker=null)
 archive_picker.popup_centered_ratio(.7)
func confirm_import(path: String) -> void:
 var data: Dictionary=Archive.read_file(path)
 if data.is_empty():menu.feedback.text=t("Import refusé : fichier invalide ou incompatible. Partie conservée.","Import rejected: invalid or incompatible file. Current save preserved.");return
 menu.visible=false;var column:=popup(t("Importer cette partie dans l’emplacement actif %d ? La progression non sauvegardée sera remplacée ; l’ancien fichier valide restera en copie précédente. Le fichier source sera conservé.","Import this save into active slot %d? Unsaved progress will be replaced; the previous valid file will remain as a backup. Source file preserved.") % loaded_slot)
 button(column,t("Confirmer","Confirm"),func():
  var candidate:=State.new()
  if not candidate.restore(data):return
  var error: int=candidate.save(slot_path(loaded_slot))
  if error==OK:apply_archive(data,loaded_slot);persist_auto(true)
  else:clear_modal();open_menu("saves");menu.feedback.text=error_string(error),"ConfirmDemoImport")
 button(column,t("Annuler","Cancel"),func():open_menu("saves"))
func play_scene(id: String,replay: bool=false) -> bool:
 if state.location!="town" or (battle and battle.active) or not scene.begin(id,state.campaign.adventure.records,replay):return false
 menu.visible=false;scene_camera=world.camera.transform;scene_size=world.camera.size;render_scene();return true
func render_scene() -> void:
 var step: Dictionary=scene.current();var focus:=Vector3(step.focus[0],step.focus[1],step.focus[2])
 world.camera.position=focus+Vector3(0,13,15);world.camera.look_at(focus+Vector3(0,1,0));world.camera.size=step.size
 var column:=popup(step[locale]);button(column,t("Continuer • E / Entrée","Continue • E / Enter"),advance_scene,"NextScene").grab_focus()
func advance_scene() -> void:
 if not scene.active:return
 scene.advance()
 if scene.active:render_scene()
 else:world.camera.transform=scene_camera;world.camera.size=scene_size;clear_modal();persist_auto()
