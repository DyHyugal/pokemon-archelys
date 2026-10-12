extends RefCounted
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
const Dex=preload("res://scripts/domain/demo_dex.gd")
const Expedition=preload("res://scripts/domain/demo_expedition.gd")
const Archive=preload("res://scripts/services/demo_archive.gd")
const Assets=preload("res://scripts/services/imported_assets.gd")
const Slots=preload("res://scripts/services/demo_slots.gd")
var game: CanvasLayer
var menu: CanvasLayer
func _init(owner: CanvasLayer) -> void:game=owner;menu=game.menu
func t(fr: String,en: String) -> String:return game.t(fr,en)
func render(page: String) -> void:
 var a: RefCounted=menu.adventure
 if page=="dex":dex()
 elif page=="cinema":
  menu.label(t("Scènes de démo : propositions, progression manuelle, relecture sans récompense.","Demo scenes: proposals, manual progression, replay without rewards."))
  for id: String in ["demo-arrival","demo-return","demo-canopy-briefing","demo-checkpoint-report"]:
   if not a.records.scenes.has(id):continue
   var scene_id: String=id
   var replay: Button=game.button(menu.body,preload("res://scripts/domain/cinematic.gd").library()[id].names[game.locale],func():game.play_scene(scene_id,true),"Replay_"+id);replay.disabled=game.state.location!="town"
  if game.state.location!="town":menu.label(t("Retourne au havre pour rejouer ces cadrages.","Return to the haven to replay these shots."))
  if a.records.scenes.is_empty():menu.label(t("Aucune scène débloquée.","No scene unlocked."))
 elif page=="services":
  if game.state.location not in ["center","shop"]:
   menu.label(t("Entre dans le Centre ou la boutique pour utiliser leurs services.","Enter the Center or shop to use their services."));return
  menu.exploration_pages.render("services")
 elif page=="pc":
  if game.state.location!="center":menu.label(t("Le PC est accessible dans le Centre Pokémon.","The PC is available inside the Pokémon Center."));return
  menu.adventure_pages.render("pc")
 elif page=="assets":
  var assets: Dictionary=Assets.data()
  menu.label(t("Registre des exports locaux : %d modèles. Aucun modèle généré automatiquement.","Local export registry: %d models. No models generated automatically.") % assets.size())
  if assets.is_empty():menu.label(t("Exports Meshy attendus. Les modèles actuels sont des maquettes.","Meshy exports pending. Current models are placeholders."))
  for id: String in assets:
   var entry: Dictionary=assets[id]
   menu.label("%s · %s\n%s\n%s\nSHA-256 %s" % [id,t("disponible","available") if ResourceLoader.exists(entry.path) else t("fichier absent","file missing"),entry.source,entry.rights,entry.sha256])
   var key: String=id
   game.button(menu.body,t("Inspecter : ","Inspect: ")+id,func():preview(key),"Preview_"+id)
 elif page=="saves":saves_extra()
func dex() -> void:
 var history: RefCounted=menu.adventure.records
 menu.label(t("Catalogue provisoire · Vus %d / Obtenus %d","Provisional catalogue · Seen %d / Obtained %d") % [history.seen.size(),history.caught.size()])
 var query:=LineEdit.new();query.name="DemoDexQuery";query.placeholder_text=t("Rechercher une espèce découverte","Search discovered species");query.text=game.dex_query;menu.body.add_child(query)
 game.button(menu.body,t("Rechercher","Search"),func():game.dex_query=query.text;menu.render(),"SearchDemoDex")
 var filter:=OptionButton.new();filter.name="DemoDexFilter"
 for text: String in [t("Toutes","All"),t("Vues","Seen"),t("Obtenues","Obtained")]:filter.add_item(text)
 filter.select(game.dex_filter);menu.body.add_child(filter);filter.item_selected.connect(func(i: int):game.dex_filter=i;menu.render())
 for id: String in Dex.roster(history,game.dex_filter,game.dex_query,game.locale):
  var key: String=id;var known: bool=history.seen.has(id)
  var b: Button=game.button(menu.body,Catalog.name_of(id,game.locale) if known else "???",func():details(key),"Dex_"+id);b.disabled=not known
func details(id: String) -> void:
 if not menu.adventure.records.seen.has(id):return
 menu.clear(menu.body);menu.label(Catalog.name_of(id,game.locale))
 menu.label(" / ".join(Catalog.species(id).types.map(func(type: String):return Catalog.text("type_names",type,game.locale))))
 var habitats: Array=Dex.habitats(id)
 for place: Dictionary in habitats:
  menu.label("%s · %s · %s%d–%d" % [preload("res://scripts/domain/demo_chapter.gd").name_of(place.place,game.locale),t("herbes","grass") if place.method=="grass" else t("pêche","fishing"),t("Nv.","Lv."),int(place.get("minimum",place.level)),int(place.get("maximum",place.level))])
 if habitats.is_empty():menu.label(t("Pas de rencontre sauvage dans cette portion de démo.","No wild encounter in this demo slice."))
 if id in preload("res://scripts/domain/demo_content.gd").data().starters:menu.label(t("Partenaire de départ provisoire.","Provisional starter partner."))
 if id==preload("res://scripts/domain/demo_content.gd").data().gift_egg:menu.label(t("Œuf cadeau du professeur, une fois par partie.","Professor's gift egg, once per save."))
 for item: String in preload("res://scripts/domain/fossils.gd").RECIPES:
  if preload("res://scripts/domain/fossils.gd").RECIPES[item]==id:menu.label(t("Fossile au Centre : ","Fossil at Center: ")+Catalog.name_of(item,game.locale))
 game.button(menu.body,t("Retour à la liste","Back to list"),menu.render,"BackDemoDex")
func saves_extra() -> void:
 var toggle:=CheckButton.new();toggle.name="DemoAutosave";toggle.text=t("Autosauvegarde séparée (60 s d’exploration)","Separate autosave (60 s of exploration)");toggle.set_pressed_no_signal(game.state.autosave);menu.body.add_child(toggle)
 toggle.toggled.connect(func(enabled: bool):game.state.autosave=enabled;game.persist_auto(true))
 game.button(menu.body,t("Exporter cette partie…","Export this save…"),func():game.archive_dialog(false),"ExportDemoSave")
 game.button(menu.body,t("Importer une partie…","Import a save…"),func():game.archive_dialog(true),"ImportDemoSave")
 menu.label(t("Dossier de sauvegardes : ","Save folder: ")+ProjectSettings.globalize_path(game.save_path).get_base_dir())
 game.button(menu.body,t("Ouvrir le dossier","Open folder"),func():OS.shell_open(ProjectSettings.globalize_path(game.save_path).get_base_dir()),"OpenSaveFolder")
 for index: int in range(1,4):
  var slot: int=index;var file: String=Slots.path(game.save_path,index)
  for suffix: String in ["",".backup",".auto"]:
   var info: Dictionary=Archive.inspect(file+suffix)
   menu.label("%d%s : %s" % [index,suffix,{"valid":t("valide","valid"),"empty":t("absent","empty"),"invalid":t("invalide / incompatible","invalid / incompatible")}[info.status]]+(" · %s · %d Pokémon · %d ₽" % [Catalog.name_of(info.starter,game.locale),info.team,info.money] if info.status=="valid" else ""))
  if not Slots.read_auto(game.save_path,index).is_empty():game.button(menu.body,t("Charger auto %d","Load auto %d") % index,func():game.confirm_auto(slot),"LoadDemoAuto%d" % index)
func preview(id: String) -> void:
 menu.clear(menu.body)
 var model: Node3D=Assets.instantiate(id)
 if model==null:menu.label(t("Modèle absent ou invalide.","Missing or invalid model."));return
 preview_node(model)
func preview_node(model: Node3D) -> void:
 var viewport:=SubViewport.new();viewport.size=Vector2i(600,400);viewport.own_world_3d=true;viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS;menu.body.add_child(viewport)
 var scene:=Node3D.new();viewport.add_child(scene);scene.add_child(model)
 var bounds:=AABB();var initialized: bool=false
 for part: Node in model.find_children("*","MeshInstance3D",true,false):
  var box: AABB=part.global_transform*part.get_aabb();bounds=bounds.merge(box) if initialized else box;initialized=true
 if not initialized:menu.label(t("Aucune géométrie visible.","No visible geometry."))
 var center: Vector3=bounds.get_center();var radius: float=maxf(bounds.size.length(),1)
 var light:=DirectionalLight3D.new();light.rotation_degrees=Vector3(-45,-30,0);scene.add_child(light)
 var camera:=Camera3D.new();camera.position=center+Vector3(1,.7,1.4).normalized()*radius*1.3;scene.add_child(camera);camera.look_at(center);camera.current=true
 var image:=TextureRect.new();image.name="ImportedModelPreview";image.texture=viewport.get_texture();image.custom_minimum_size=Vector2(480,320);image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;image.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;menu.body.add_child(image)
 menu.label(t("Dimensions en jeu : ","In-game dimensions: ")+str(bounds.size))
 var turn:=HSlider.new();turn.min_value=-180;turn.max_value=180;menu.body.add_child(turn);var yaw: float=model.rotation_degrees.y;turn.value_changed.connect(func(value: float):model.rotation_degrees.y=yaw+value)
 game.button(menu.body,t("Retour aux imports","Back to imports"),menu.render)
