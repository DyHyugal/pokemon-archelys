extends RefCounted
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
var menu: CanvasLayer
var source: String="machine"
var query: String=""
var ids: Array=[]
var picker: OptionButton
var details: Label
var actions: VBoxContainer
var confirm: VBoxContainer
var uid: int=0
func _init(owner: CanvasLayer) -> void:menu=owner
func t(fr: String,en: String) -> String:return menu.tr_text(fr,en)
func render(mon: Dictionary) -> void:
 uid=int(mon.uid)
 menu.label(t("Préparer les attaques — CT réutilisables / rappel gratuit du catalogue","Prepare moves — reusable TMs / free catalogue move reminder"))
 menu.label(t("Une seule attaque remplacée après confirmation. Le nouvel emplacement reçoit ses PP de base ; les autres attaques, PV, statut et objet sont conservés.","One move replaced after confirmation. The new slot receives base PP; other moves, HP, status and held item are retained."))
 var modes:=OptionButton.new();modes.name="MoveSource";modes.add_item(t("CT","TMs"));modes.add_item(t("Rappel au niveau actuel","Reminder at current level"));modes.select(0 if source=="machine" else 1);menu.body.add_child(modes)
 modes.item_selected.connect(func(index: int):source="machine" if index==0 else "reminder";query="";menu.render())
 var search:=LineEdit.new();search.name="MoveSearch";search.placeholder_text=t("Nom ou type de l'attaque (FR/EN)","Move name or type (FR/EN)");search.text=query;menu.body.add_child(search)
 picker=OptionButton.new();picker.name="MovePicker";menu.body.add_child(picker)
 details=menu.label("");details.name="MoveDetails"
 actions=VBoxContainer.new();actions.name="MoveActions";menu.body.add_child(actions)
 confirm=VBoxContainer.new();confirm.name="MoveConfirmation";menu.body.add_child(confirm)
 search.text_changed.connect(func(value: String):query=value;populate())
 picker.item_selected.connect(func(_index: int):update_selection())
 populate()
func populate() -> void:
 ids=menu.adventure.move_options(uid,source).filter(func(id: String):
  var needle: String=query.strip_edges().to_lower()
  return needle.is_empty() or ["fr","en"].any(func(locale: String):return Catalog.name_of(id,locale).to_lower().contains(needle) or Catalog.text("type_names",Catalog.move(id).type,locale).to_lower().contains(needle)))
 ids.sort_custom(func(a: String,b: String):return Catalog.name_of(a,menu.locale).naturalnocasecmp_to(Catalog.name_of(b,menu.locale))<0)
 picker.clear()
 for id: String in ids:picker.add_item(Catalog.name_of(id,menu.locale))
 picker.disabled=ids.is_empty();if not ids.is_empty():picker.select(0)
 update_selection()
func update_selection() -> void:
 menu.clear(actions);menu.clear(confirm)
 if ids.is_empty():details.text=t("Aucune attaque légale correspondant à cette recherche.","No legal moves match this search.");return
 var id: String=ids[maxi(0,picker.selected)];var move: Dictionary=Catalog.move(id)
 var category: String={"physical":t("Physique","Physical"),"special":t("Spéciale","Special"),"status":t("Statut","Status")}[move.category]
 details.text="%s • %s • %s\n%s %s • %s %s • %d PP • %s %d" % [Catalog.name_of(id,menu.locale),Catalog.text("type_names",move.type,menu.locale),category,t("Puissance","Power"),str(move.power) if move.power>0 else "—",t("Précision","Accuracy"),str(move.accuracy)+"%" if move.accuracy>0 else "—",move.pp,t("Priorité","Priority"),move.priority]
 var mon: Dictionary=menu.adventure.find(uid)
 if mon.is_empty():return
 if mon.moves.any(func(slot: Dictionary):return slot.id==id):details.text+="\n"+t("Déjà connue : ses PP ne sont pas réinitialisés.","Already known: its PP are not reset.");return
 for i: int in range(mini(4,mon.moves.size()+1)):
  var slot: int=i;var old: String=mon.moves[i].id if i<mon.moves.size() else ""
  var text: String=t("Ajouter dans l'emplacement %d","Add into slot %d") % (i+1) if old.is_empty() else t("Remplacer %d : %s","Replace %d: %s") % [i+1,Catalog.name_of(old,menu.locale)]
  var button: Button=menu.button(actions,text,func():prepare(id,slot,old));button.name="PrepareMove_%d" % slot
func prepare(id: String,slot: int,previous: String) -> void:
 menu.clear(confirm)
 var label:=Label.new();label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;label.text=t("Confirmer %s → %s ?","Confirm %s → %s?") % [Catalog.name_of(previous,menu.locale) if not previous.is_empty() else t("emplacement libre","empty slot"),Catalog.name_of(id,menu.locale)];confirm.add_child(label)
 var selected_source: String=source;var selected_uid: int=uid
 var accept: Button=menu.button(confirm,t("Confirmer l'apprentissage","Confirm learning"),func():
  var mon: Dictionary=menu.adventure.find(selected_uid)
  var current: String=mon.moves[slot].id if not mon.is_empty() and slot<mon.moves.size() else ""
  var ok: bool=not mon.is_empty() and current==previous and (menu.adventure.teach_machine(selected_uid,id,slot) if selected_source=="machine" else menu.adventure.relearn(selected_uid,id,slot))
  menu.render();menu.feedback.text=t("Attaque apprise ; autres états conservés.","Move learned; other conditions retained.") if ok else t("Choix refusé ou devenu indisponible. Rien n'a été remplacé.","Choice rejected or no longer available. Nothing replaced."))
 accept.name="ConfirmMove";accept.grab_focus()
 menu.button(confirm,t("Annuler","Cancel"),func():menu.clear(confirm))
