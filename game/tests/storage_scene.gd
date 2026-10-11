extends SceneTree
const Mon=preload("res://scripts/domain/pokemon.gd")
var checks:=0
var failures:=0
func check(value: bool,message: String) -> void:
 checks+=1
 if not value:failures+=1;push_error(message)
func press(parent: Node,text: String) -> bool:
 for node: Node in parent.get_children():
  if node is Button and not node.disabled and node.text.contains(text):node.pressed.emit();return true
 return false
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var world: Node=load("res://main.tscn").instantiate();world.preferences_path="user://tests_storage_prefs.json";root.add_child(world);await process_frame;await process_frame;world._set_locale("fr")
 var a: RefCounted=root.get_node("Session").campaign.adventure
 while a.team.size()<6:a.add(Mon.make("squirtle",8,a.next_uid))
 a.add(Mon.make("blastoise",40,a.next_uid));a.add(Mon.make("pikachu",8,a.next_uid))
 var uid: int=int(a.boxes[0].uid);a.find(uid).hp=20;a.find(uid).moves=[{"id":"withdraw","pp":20},{"id":"surf","pp":3}]
 world._open_menu("pc");var menu: CanvasLayer=world.pause_menu
 check(menu.body.get_node("StorageGrid").get_child_count()==30 and menu.body.get_node("StorageBox").item_count==8,"Actual PC renders eight boxes and thirty slots")
 menu.body.get_node("StorageGrid/StorageSlot_0").pressed.emit()
 check(menu.storage_pages.selected_uid==uid and press(menu.body,"Déplacer"),"Actual slot selects individual and starts move")
 var box: OptionButton=menu.body.get_node("StorageBox");box.select(7);box.item_selected.emit(7);menu.body.get_node("StorageGrid/StorageSlot_239").pressed.emit()
 check(a.storage_slots[str(uid)]==239 and a.find(uid).hp==20,"Actual cross-box move preserves HP and slot")
 var search: LineEdit=menu.body.get_node("StorageSearch");search.text="Blastoise";search.text_changed.emit(search.text)
 check(menu.body.get_node("StorageResults").get_child_count()==2,"English species search works in French UI")
 search.text="#"+str(uid);search.text_changed.emit(search.text)
 check(menu.body.get_node("StorageResults").get_child_count()==2 and not menu.storage_pages.matches(Mon.make("blastoise",40,uid*10)),"Individual ID search is exact, not a numeric prefix")
 press(menu.body.get_node("StorageResults"),"Tortank")
 check(menu.storage_pages.box==7 and menu.storage_pages.selected_uid==uid,"Search result selects correct stable box member")
 press(menu.body,"Consulter / préparer")
 check(menu.page=="team" and menu.adventure_pages.summary_from=="pc" and menu.adventure_pages.iv_controls.size()==6,"Boxed member shares complete editable summary")
 var pages: RefCounted=menu.adventure_pages;pages.iv_controls[1].value=31;press(menu.body,"Appliquer IV")
 check(a.find(uid).iv[1]==31 and a.find(uid) in a.boxes,"Actual stat edit applies without withdrawing")
 var source: OptionButton=menu.body.get_node("MoveSource");source.select(1);source.item_selected.emit(1)
 var move_search: LineEdit=menu.body.get_node("MoveSearch");move_search.text="Water Gun";move_search.text_changed.emit(move_search.text)
 check(menu.body.get_node("MovePicker").item_count==1 and menu.body.get_node("MoveDetails").text.contains("Pistolet"),"Reminder search filters and localizes real move details")
 var original: Dictionary=a.find(uid).duplicate(true)
 menu.body.get_node("MoveActions/PrepareMove_0").pressed.emit();press(menu.body.get_node("MoveConfirmation"),"Annuler")
 check(a.find(uid)==original,"Cancel replacement preserves original moves and PP")
 menu.body.get_node("MoveActions/PrepareMove_0").pressed.emit();menu.body.get_node("MoveConfirmation/ConfirmMove").pressed.emit()
 check(a.find(uid).moves[0].id=="water-gun" and a.find(uid).moves[1].pp==3 and a.find(uid).hp==original.hp,"Actual confirmation replaces only selected move and retains damage/PP")
 press(menu.body,"Retour au PC");press(menu.body,"Échanger avec 1")
 check(a.team[0].uid==uid and a.team.size()==6 and a.boxes.size()==2,"Actual exchange works with a full party")
 var saved: Dictionary=root.get_node("Session").campaign.snapshot();root.get_node("Session").campaign.restore(JSON.parse_string(JSON.stringify(saved)));world._sync_menu();a=root.get_node("Session").campaign.adventure
 check(a.team[0].moves[0].id=="water-gun" and a.storage_slots.values().has(239),"Campaign restoration keeps set and vacated storage position")
 world._set_locale("en");world._open_menu("pc")
 check(menu.body.get_node("StorageBox").get_item_text(0).begins_with("Box"),"PC localizes in English")
 for i: int in range(60):a.add(Mon.make("rattata",8,a.next_uid))
 world._open_menu("pc");menu.body.get_node("StorageSearch").text="Normal";menu.body.get_node("StorageSearch").text_changed.emit("Normal")
 check(menu.body.get_node("StorageResults").get_child_count()==32 and menu.storage_pages.result_page==0,"Large search renders thirty results plus pagination, not entire PC")
 menu.body.get_node("StorageResults/SearchPages/NextResults").pressed.emit()
 check(menu.storage_pages.result_page==1 and menu.body.get_node("StorageResults").get_child_count()==32,"Next search page shows remaining thirty actual individuals")
 if DisplayServer.get_name()!="headless":
  for arg: String in OS.get_cmdline_user_args():
   if arg.begins_with("--storage-proof="):
    menu.storage_pages.query="";menu.storage_pages.box=0;menu.render()
    await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(arg.trim_prefix("--storage-proof="))
 world.queue_free();await process_frame
 print("STORAGE SCENE: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
