extends RefCounted
const Fossils=preload("res://scripts/domain/fossils.gd")
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
const Mon=preload("res://scripts/domain/pokemon.gd")
const Records=preload("res://scripts/domain/journey_records.gd")
const Cinematic=preload("res://scripts/domain/cinematic.gd")
var menu: CanvasLayer
var selected: String=""
var filter: int=0
var confirmation: Dictionary={}
func _init(owner: CanvasLayer) -> void:menu=owner
func t(fr: String,en: String) -> String:return menu.tr_text(fr,en)
func render(page: String) -> void:
 match page:
  "dex":dex()
  "cinema":cinema()
  "saves":saves()
func dex() -> void:
 var history: RefCounted=menu.adventure.records
 menu.label(t("Catalogue de laboratoire : %d espèces, pas le Pokédex final.","Laboratory catalogue: %d species, not the final Pokédex.") % Catalog.data().species.size())
 menu.label(t("Vus : %d · Obtenus : %d","Seen: %d · Obtained: %d") % [history.seen.size(),history.caught.size()])
 var choice:=OptionButton.new();choice.name="DexFilter"
 for label: String in [t("Toutes","All"),t("Vues","Seen"),t("Obtenues","Obtained")]:choice.add_item(label)
 choice.select(filter);menu.body.add_child(choice);choice.item_selected.connect(func(value: int):filter=value;selected="";menu.render())
 if not selected.is_empty() and history.seen.has(selected):
  var entry:=Catalog.species(selected)
  menu.label(Catalog.name_of(selected,menu.locale)+(" ✓" if history.caught.has(selected) else ""))
  menu.label(t("Types : ","Types: ")+" / ".join(entry.types.map(func(id: String):return Catalog.text("type_names",id,menu.locale))))
  var places:=Records.habitats(selected)
  menu.label(t("Rencontres sauvages du laboratoire : ","Laboratory wild encounters: ")+(t("Herbes du village","Village grass") if "village" in places else "")+(" · " if places.size()>1 else "")+(t("Pêche dans la crique","Cove fishing") if "cove" in places else "") if not places.is_empty() else t("Aucune rencontre sauvage pour cette forme dans le laboratoire.","No wild encounter for this form in the laboratory."))
  for fossil: String in Fossils.RECIPES:
   var base: String=Fossils.RECIPES[fossil]
   if selected==base or entry.get("previous","")==base:
    menu.label(t("Obtention : restauration de %s au Centre du village%s.","Acquisition: restore %s at the village Center%s.") % [Catalog.name_of(fossil,menu.locale),t(" puis évolution niveau40"," then evolve at level40") if selected!=base else ""])
  menu.label(t("Les stades sauvages suivent le niveau de la rencontre ; les zones ne garantissent pas une apparition immédiate.","Wild evolution stages follow encounter level; a location does not guarantee an immediate encounter."))
  if history.caught.has(selected):
   menu.label(t("Statistiques de base","Base stats"))
   var grid:=GridContainer.new();grid.columns=3;grid.add_theme_constant_override("h_separation",24);menu.body.add_child(grid)
   for index: int in range(6):
    var value:=Label.new();value.text="%s : %d" % [Catalog.text("stat_names",Mon.STATS[index],menu.locale),int(entry.stats[index])];grid.add_child(value)
   menu.label(t("Talents : ","Abilities: ")+" / ".join(entry.abilities.map(func(id: String):return Catalog.text("abilities",id,menu.locale))))
  menu.button(menu.body,t("Retour à la liste","Back to list"),func():selected="";menu.render())
  return
 var index:=0;var found:=false
 for id: String in Catalog.data().species:
  index+=1
  if filter==1 and not history.seen.has(id):continue
  if filter==2 and not history.caught.has(id):continue
  found=true
  var known: bool=history.seen.has(id)
  var control: Button=menu.button(menu.body,"%02d · %s%s" % [index,Catalog.name_of(id,menu.locale) if known else "???"," ✓" if history.caught.has(id) else ""],func():selected=id;menu.render())
  control.disabled=not known
 if not found:menu.label(t("Aucune espèce dans ce filtre.","No species in this filter."))
func cinema() -> void:
 menu.label(t("Essais de mise en scène : aucun scénario final ni cinématique d'île.","Staging tests: no final story or island cinematic."))
 if menu.adventure.exploration.location!="village":menu.label(t("Reviens au village pour lancer ces cadrages de laboratoire.","Return to the village to start these laboratory shots."))
 for id: String in Cinematic.library():
  var entry: Dictionary=Cinematic.library()[id]
  var watched: bool=menu.adventure.records.scenes.has(id)
  if watched and not entry.replayable:
   menu.label(entry.names[menu.locale]+t(" — terminée, non rejouable"," — completed, not replayable"));continue
  var control: Button=menu.button(menu.body,(t("Rejouer : ","Replay: ") if watched else t("Découvrir : ","Discover: "))+entry.names[menu.locale],func():menu.scene_requested.emit(id,watched))
  control.disabled=menu.adventure.exploration.location!="village"
 menu.label(t("Scène principale : progression manuelle, impossible à passer. Scène secondaire : Échap pour passer ; aucun replay. La galerie conserve les scènes débloquées dans chaque sauvegarde.","Main scene: manual progress, cannot be skipped. Secondary scene: Escape to skip; no replay. Unlocked scenes are kept in each save."))
func request(action: String,slot: int) -> void:
 if action in ["save","new"]:
  confirmation={"action":action,"slot":slot};menu.render()
 else:menu.slot_requested.emit(action,slot)
func saves() -> void:
 if menu.slots==null:return
 menu.label(t("Emplacement actif : %d · 3 sauvegardes solo indépendantes","Active slot: %d · 3 independent solo saves") % menu.slots.active)
 menu.label(t("L'autosauvegarde est séparée : elle ne remplace jamais une sauvegarde manuelle. Charger ne sauvegarde pas la partie quittée.","Autosave is separate: it never replaces a manual save. Loading does not save the game you leave."))
 if not confirmation.is_empty():
  var action: String=confirmation.action;var slot: int=confirmation.slot
  menu.label((t("Enregistrer la partie actuelle dans l'emplacement %d ? L'ancien fichier valide restera en .backup.","Save the current game to slot %d? The previous valid file remains in .backup.") if action=="save" else t("Commencer une partie dans l'emplacement %d ? La partie en mémoire sera quittée sans sauvegarde. Les anciens fichiers ne seront pas effacés ; l'autosauvegarde pourra évoluer ensuite.","Start a game in slot %d? The game in memory will be left unsaved. Old files are not deleted; autosave may later evolve.")) % slot)
  menu.button(menu.body,t("Confirmer","Confirm"),func():confirmation={};menu.slot_requested.emit(action,slot))
  menu.button(menu.body,t("Annuler","Cancel"),func():confirmation={};menu.render());return
 var automatic:=CheckButton.new();automatic.name="AutosaveToggle";automatic.text=t("Autosauvegarde (60 s réelles, hors combat / dialogue / menus)","Autosave (60 real seconds, outside battle / dialogue / menus)");automatic.set_pressed_no_signal(menu.slots.autosave);menu.body.add_child(automatic)
 automatic.toggled.connect(func(enabled: bool):var error: int=menu.slots.set_autosave(enabled);menu.feedback.text=error_string(error);menu.render())
 for slot: int in range(1,4):
  menu.label(t("Emplacement %d","Slot %d") % slot)
  for auto: bool in [false,true]:
   var info: Dictionary=menu.slots.describe(slot,auto)
   var caption:=t("Auto : ","Auto: ") if auto else t("Manuelle : ","Manual: ")
   if info.status=="valid":caption+="%s · %s %d · %s" % [Catalog.name_of(info.species,menu.locale),t("niv.","Lv."),info.level,Time.get_datetime_string_from_unix_time(info.modified).replace("T"," ")+" UTC"]
   else:caption+=t("absente","empty") if info.status=="empty" else t("invalide / incompatible — fichier conservé","invalid / incompatible — file preserved")
   menu.label(caption)
   var load_button: Button=menu.button(menu.body,t("Charger auto","Load autosave") if auto else t("Charger manuelle","Load manual save"),func():request("auto" if auto else "load",slot))
   load_button.disabled=info.status!="valid"
  menu.button(menu.body,t("Sauvegarder ici","Save here"),func():request("save",slot))
  menu.button(menu.body,t("Nouvelle partie ici","New game here"),func():request("new",slot))
  var backup: Button=menu.button(menu.body,t("Restaurer la précédente manuelle (.backup)","Restore previous manual (.backup)"),func():request("backup",slot))
  backup.disabled=menu.slots.read(slot,false,true).is_empty()
 menu.label(t("Dossier : ","Folder: ")+ProjectSettings.globalize_path(menu.slots.base).get_base_dir())
