extends RefCounted
const Mon=preload("res://scripts/domain/pokemon.gd")
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
const Storage=preload("res://scripts/domain/storage.gd")
var menu: CanvasLayer
var box: int=0
var selected_uid: int=0
var moving_uid: int=0
var query: String=""
var type_filter: String=""
var result_page: int=0
var result_list: VBoxContainer
func _init(owner: CanvasLayer) -> void:menu=owner
func t(fr: String,en: String) -> String:return menu.tr_text(fr,en)
func caption(mon: Dictionary) -> String:return "%s • %s%d • #%d" % [Catalog.name_of(mon.species,menu.locale),t("Nv.","Lv."),mon.level,mon.uid]
func render() -> void:
 var a: RefCounted=menu.adventure;a._sync_storage()
 menu.label(t("PC : %d/240 • équipe : %d/6","PC: %d/240 • party: %d/6") % [a.boxes.size(),a.team.size()])
 if a.boxes.is_empty():menu.label(t("Le PC est vide. Dépose un Pokémon depuis son résumé.","The PC is empty. Deposit a Pokémon from its summary."))
 menu.label(t("Les emplacements sont stables. Choisis un Pokémon pour le retirer, l'échanger avec l'équipe ou consulter son résumé sans le retirer.","Slots are stable. Select a Pokémon to withdraw it, exchange it with your party or inspect its summary without withdrawing."))
 var pick:=OptionButton.new();pick.name="StorageBox"
 for i: int in range(Storage.BOX_COUNT):
  var count: int=a.storage_slots.values().filter(func(slot: int):return slot/Storage.BOX_SIZE==i).size()
  pick.add_item(t("Boîte %d — %d/30","Box %d — %d/30") % [i+1,count])
 pick.select(box);menu.body.add_child(pick);pick.item_selected.connect(func(index: int):box=index;menu.render())
 if moving_uid!=0:
  menu.label(t("Déplacement de #%d : choisis un emplacement, même dans une autre boîte. Un emplacement occupé échange les positions.","Moving #%d: choose a slot, including another box. An occupied slot swaps positions.") % moving_uid)
  menu.button(menu.body,t("Annuler le déplacement","Cancel move"),func():moving_uid=0;menu.render())
 var grid:=GridContainer.new();grid.name="StorageGrid";grid.columns=5;menu.body.add_child(grid)
 for i: int in range(Storage.BOX_SIZE):
  var slot: int=box*Storage.BOX_SIZE+i;var uid: int=Storage.uid_at(a.storage_slots,slot);var mon: Dictionary=a.find(uid)
  var label: String=t("%02d · vide","%02d · empty") % (i+1) if uid==0 else "%02d · %s\n%s%d · #%d" % [i+1,Catalog.name_of(mon.species,menu.locale),t("Nv.","Lv."),mon.level,uid]
  var button: Button=menu.button(grid,label,func():
   if moving_uid!=0:
    var ok: bool=a.move_stored(moving_uid,slot);moving_uid=0;menu.render();menu.feedback.text=t("Rangement conservé dans la campagne.","Storage layout belongs to the campaign.") if ok else t("Déplacement refusé.","Move rejected.")
   else:selected_uid=uid;menu.render())
  button.name="StorageSlot_%d" % slot;button.clip_text=true;button.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS;button.custom_minimum_size=Vector2(105,54);button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
  button.tooltip_text=caption(mon) if uid!=0 else t("Emplacement libre","Free slot")
 if selected_uid!=0:render_selected()
 menu.label(t("Rechercher dans tout le PC — nom, type ou talent (FR/EN), identifiant individuel","Search all PC boxes — name, type or ability (FR/EN), individual ID"))
 var search:=LineEdit.new();search.name="StorageSearch";search.placeholder_text=t("Ex. Carapuce, Eau, Torche, #7…","E.g. Squirtle, Water, Flash Fire, #7…");search.text=query;menu.body.add_child(search)
 var types:=OptionButton.new();types.name="StorageType";types.add_item(t("Tous les types","All types"))
 var ids: Array=Catalog.data().type_names.keys();ids.sort()
 for id: String in ids:types.add_item(Catalog.text("type_names",id,menu.locale))
 types.select(0 if type_filter.is_empty() else ids.find(type_filter)+1);menu.body.add_child(types)
 result_list=VBoxContainer.new();result_list.name="StorageResults";menu.body.add_child(result_list)
 search.text_changed.connect(func(value: String):query=value;result_page=0;render_results())
 types.item_selected.connect(func(index: int):type_filter="" if index==0 else ids[index-1];result_page=0;render_results())
 render_results()
func matches(mon: Dictionary) -> bool:
 if not type_filter.is_empty() and type_filter not in Catalog.species(mon.species).types:return false
 var terms: Array=["#"+str(int(mon.uid)),str(int(mon.uid)),mon.species,mon.ability]
 for locale: String in ["fr","en"]:
  terms.append(Catalog.name_of(mon.species,locale));terms.append(Catalog.text("abilities",mon.ability,locale))
  for id: String in Catalog.species(mon.species).types:terms.append(Catalog.text("type_names",id,locale))
 var needle: String=query.strip_edges().to_lower()
 if needle.begins_with("#"):return needle=="#"+str(int(mon.uid))
 return needle.is_empty() or terms.any(func(term: String):return term.to_lower().contains(needle))
func render_results() -> void:
 if not is_instance_valid(result_list):return
 menu.clear(result_list)
 if query.strip_edges().is_empty() and type_filter.is_empty():return
 var a: RefCounted=menu.adventure;var found: Array=a.boxes.filter(matches)
 var total:=Label.new();total.text=t("%d résultat(s)","%d result(s)") % found.size();result_list.add_child(total)
 if found.size()>30:
  var pages: int=ceili(found.size()/30.0);result_page=clampi(result_page,0,pages-1)
  var navigation:=HBoxContainer.new();navigation.name="SearchPages";result_list.add_child(navigation)
  var previous: Button=menu.button(navigation,t("Précédents","Previous"),func():result_page-=1;render_results());previous.disabled=result_page<=0
  var next: Button=menu.button(navigation,t("Suivants","Next"),func():result_page+=1;render_results());next.name="NextResults";next.disabled=result_page>=pages-1
  var page_label:=Label.new();page_label.text="%d / %d" % [result_page+1,pages];navigation.add_child(page_label)
 else:result_page=0
 for mon: Dictionary in found.slice(result_page*30,result_page*30+30):
  var uid: int=int(mon.uid);var slot: int=a.storage_slots[str(uid)]
  menu.button(result_list,caption(mon)+t(" — Boîte %d / case %d"," — Box %d / slot %d") % [slot/Storage.BOX_SIZE+1,slot%Storage.BOX_SIZE+1],func():box=int(a.storage_slots[str(uid)])/Storage.BOX_SIZE;selected_uid=uid;menu.render())
func render_selected() -> void:
 var a: RefCounted=menu.adventure;var mon: Dictionary=a.find(selected_uid)
 if mon.is_empty() or mon not in a.boxes:selected_uid=0;return
 menu.label(caption(mon)+" • %d/%d %s" % [mon.hp,Mon.stats(mon).hp,t("PV","HP")])
 var uid: int=selected_uid
 var inspect: Button=menu.button(menu.body,t("Consulter / préparer le résumé","Inspect / prepare summary"),func():menu.adventure_pages.selected_uid=uid;menu.adventure_pages.summary_from="pc";menu.page="team";menu.render())
 inspect.name="StorageInspect"
 var take: Button=menu.button(menu.body,t("Retirer dans l'équipe","Withdraw to party"),func():
  var ok: bool=a.withdraw(a.boxes.find(a.find(uid)))
  if ok:selected_uid=0
  menu.render();menu.feedback.text=t("Ajouté à l'équipe sans soin ni changement de set.","Added to party without healing or changing its set.") if ok else t("Équipe pleine.","Party full."))
 take.disabled=a.team.size()>=6
 menu.button(menu.body,t("Déplacer / échanger un emplacement","Move / swap a storage slot"),func():moving_uid=uid;menu.render())
 for i: int in range(a.team.size()):
  var index: int=i
  menu.button(menu.body,t("Échanger avec %d : %s","Exchange with %d: %s") % [i+1,caption(a.team[i])],func():
   var ok: bool=a.exchange_with_party(uid,index)
   if ok:selected_uid=0
   menu.render();menu.feedback.text=t("Échange effectué, identités et états conservés.","Exchange completed, identities and conditions retained.") if ok else t("Garde au moins un Pokémon apte au combat.","Keep at least one battle-ready Pokémon."))
