@tool
extends EditorPlugin
const Catalog = preload("res://addons/archelys_workshop/core/catalog.gd")
const Factory = preload("res://addons/archelys_workshop/core/factory.gd")
const Garc = preload("res://addons/archelys_workshop/core/garc.gd")
const Event = preload("res://addons/archelys_workshop/core/event.gd")
const Step = preload("res://addons/archelys_workshop/core/step.gd")
const Map2D = preload("res://addons/archelys_workshop/nodes/map_2d.gd")
const Map3D = preload("res://addons/archelys_workshop/nodes/map_3d.gd")
var dock: VBoxContainer
var library: ItemList
var search: LineEdit
var rows: Array = []
var output: RichTextLabel
var archive_rows: ItemList
var archive_path := ""
var archive_report: Dictionary = {}
var dump_dialog: FileDialog
var dump_resources: ItemList
var dump_report: Dictionary = {}
var selected_object: Node
var event_label: Label
var action: OptionButton
var key: LineEdit
var fr: TextEdit
var en: TextEdit
var event_steps: ItemList
var source_dialog: FileDialog
var asset_dialog: FileDialog
var scene_dialog: FileDialog
var export_dialog: FileDialog
var pending_dimension := 2
var source_edit: LineEdit
var rights_edit: LineEdit
var blender_edit: LineEdit
var addon_edit: LineEdit
var conversion_inputs := PackedStringArray()
var conversion_dialog: FileDialog
var conversion_output_dialog: FileDialog
var conversion_pid := -1
var conversion_report := ""

func _enter_tree() -> void:
	dock = VBoxContainer.new(); dock.name = "Archélys"; dock.custom_minimum_size = Vector2(300, 400)
	var title := Label.new(); title.text = "ATELIER ARCHÉLYS • USUL • 0.1"; dock.add_child(title)
	var tabs := TabContainer.new(); tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL; dock.add_child(tabs)
	var assets := _tab(tabs, "Bibliothèque")
	search = LineEdit.new(); search.placeholder_text = "Rechercher un asset"; assets.add_child(search); search.text_changed.connect(func(_v): _refresh_library())
	library = ItemList.new(); library.custom_minimum_size.y = 180; library.size_flags_vertical = Control.SIZE_EXPAND_FILL; assets.add_child(library)
	_button(assets, "Placer dans la scène (annulable)", _place)
	_button(assets, "Actualiser la bibliothèque", _refresh_library)
	source_edit = LineEdit.new(); source_edit.placeholder_text = "Provenance de l'asset à enregistrer"; assets.add_child(source_edit)
	rights_edit = LineEdit.new(); rights_edit.placeholder_text = "Droits / usage local / attribution"; assets.add_child(rights_edit)
	_button(assets, "Ajouter un PNG / GLB du projet…", func(): asset_dialog.popup_centered_ratio(.7))
	var maps := _tab(tabs, "Maps")
	_note(maps, "Édition dans les vues natives Godot : déplacer, pivoter, redimensionner ; aimantation et Ctrl+Z disponibles. F6 lance la map courante.")
	_button(maps, "Créer une map 2D…", func(): _new_map(2))
	_button(maps, "Créer une map 3D…", func(): _new_map(3))
	_button(maps, "Ouvrir la map d'exemple", func(): EditorInterface.open_scene_from_path("res://data/workshop/example.tscn"))
	_button(maps, "Vérifier la map courante", _validate)
	_note(maps, "Inspecteur d'un objet : dimensions visuelles, empreinte de collision, conditions d'apparition. Les dimensions sont explicites ; une collision n'est pas déduite d'une façade.")
	var events := _tab(tabs, "Événements")
	event_label = _note(events, "Sélectionner un objet Atelier dans la scène.")
	_button(events, "Créer l'événement de cet objet", _create_event)
	event_steps = ItemList.new(); event_steps.custom_minimum_size.y = 120; events.add_child(event_steps)
	action = OptionButton.new()
	for name in ["dialogue", "set_flag", "require_flag", "give_item", "battle", "warp"]: action.add_item(name)
	events.add_child(action)
	key = LineEdit.new(); key.placeholder_text = "Référence : flag / objet / équipe / map"; events.add_child(key)
	fr = TextEdit.new(); fr.placeholder_text = "Dialogue français"; fr.custom_minimum_size.y = 65; events.add_child(fr)
	en = TextEdit.new(); en.placeholder_text = "English dialogue (sinon FR)"; en.custom_minimum_size.y = 65; events.add_child(en)
	_button(events, "Ajouter l'étape (annulable)", _append_step)
	_button(events, "Supprimer l'étape sélectionnée", _remove_step)
	_button(events, "Modifier les conditions et étapes dans l'inspecteur", _inspect_event)
	_note(events, "Combat : référence dans data/workshop/battles.json. La suite attend une victoire réelle Showdown. Warp : référence dans maps.json. Réordonner/éditer les étapes et régler once_flag dans l'inspecteur.")
	var imports := _tab(tabs, "Source USUL")
	_note(imports, "GARC v6 depuis un dump déchiffré local. Source en lecture seule. Pas de déchiffrement .3ds/.cia, pas de conversion automatique de GFModel ni des scripts officiels.")
	_button(imports, "Ouvrir un dossier de dump USUL…", func(): dump_dialog.popup_centered_ratio(.7))
	dump_resources = ItemList.new(); dump_resources.custom_minimum_size.y = 110; imports.add_child(dump_resources)
	_button(imports, "Inspecter l'archive du dump sélectionnée", func():
		if not dump_resources.get_selected_items().is_empty(): _inspect_archive(dump_report.resources[dump_resources.get_selected_items()[0]].path))
	_button(imports, "Inspecter une archive GARC…", func(): source_dialog.popup_centered_ratio(.7))
	archive_rows = ItemList.new(); archive_rows.custom_minimum_size.y = 200; archive_rows.size_flags_vertical = Control.SIZE_EXPAND_FILL; imports.add_child(archive_rows)
	_button(imports, "Extraire le membre sélectionné…", func():
		if archive_rows.get_selected_items().is_empty(): _log("Sélectionner un membre.")
		else: export_dialog.popup_centered_ratio(.7))
	_note(imports, "Les membres LZ/BCH/AMX restent bruts. Convertir les modèles avec un outil compatible (ex. Blender), puis importer le GLB dans Godot et l'enregistrer dans la bibliothèque. Aucun asset officiel n'est inclus.")
	var conversion := _tab(tabs, "Conversion")
	_note(conversion, "Adaptateur optionnel vers Blender 4.2+ et n3ds_importer installé séparément. Sélectionner les fichiers d'un seul modèle avec ses textures/animations ; pas une archive GARC entière. Les matériaux nécessitent une inspection visuelle.")
	blender_edit = LineEdit.new(); blender_edit.placeholder_text = "Chemin de Blender / blender.exe"; conversion.add_child(blender_edit)
	addon_edit = LineEdit.new(); addon_edit.placeholder_text = "Dossier décompressé de n3ds_importer"; conversion.add_child(addon_edit)
	var settings := EditorInterface.get_editor_settings()
	blender_edit.text = str(settings.get_setting("archelys_workshop/blender")) if settings.has_setting("archelys_workshop/blender") else ""
	addon_edit.text = str(settings.get_setting("archelys_workshop/n3ds_addon")) if settings.has_setting("archelys_workshop/n3ds_addon") else ""
	_button(conversion, "Choisir modèle + textures + animations…", func(): conversion_dialog.popup_centered_ratio(.7))
	_button(conversion, "Convertir vers un nouveau GLB…", func():
		if conversion_inputs.is_empty(): _log("Choisir d'abord les fichiers d'un modèle.")
		else: conversion_output_dialog.popup_centered_ratio(.7))
	_button(conversion, "Arrêter la conversion en cours", _cancel_conversion)
	_note(conversion, "Les sources restent locales. L'add-on externe est du code exécuté par Blender : utiliser une copie de confiance. Aucun téléchargement automatique, aucune promesse de conversion de tous les formats USUL.")
	output = RichTextLabel.new(); output.custom_minimum_size.y = 100; output.fit_content = false; dock.add_child(output)
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)
	add_tool_menu_item("Ouvrir l'atelier Archélys", _show_dock)
	source_dialog = _dialog(FileDialog.ACCESS_FILESYSTEM, FileDialog.FILE_MODE_OPEN_FILE); source_dialog.file_selected.connect(_inspect_archive)
	dump_dialog = _dialog(FileDialog.ACCESS_FILESYSTEM, FileDialog.FILE_MODE_OPEN_DIR); dump_dialog.dir_selected.connect(_inspect_dump)
	export_dialog = _dialog(FileDialog.ACCESS_FILESYSTEM, FileDialog.FILE_MODE_OPEN_DIR); export_dialog.dir_selected.connect(_extract)
	asset_dialog = _dialog(FileDialog.ACCESS_RESOURCES, FileDialog.FILE_MODE_OPEN_FILE); asset_dialog.filters = PackedStringArray(["*.png,*.jpg,*.jpeg,*.webp,*.glb ; Assets compatibles"]); asset_dialog.file_selected.connect(_register)
	scene_dialog = _dialog(FileDialog.ACCESS_RESOURCES, FileDialog.FILE_MODE_SAVE_FILE); scene_dialog.filters = PackedStringArray(["*.tscn ; Map Godot"]); scene_dialog.file_selected.connect(_save_new_map)
	conversion_dialog = _dialog(FileDialog.ACCESS_FILESYSTEM, FileDialog.FILE_MODE_OPEN_FILES); conversion_dialog.files_selected.connect(func(paths: PackedStringArray): conversion_inputs = paths; _log("%d ressources sélectionnées pour un modèle." % paths.size()))
	conversion_output_dialog = _dialog(FileDialog.ACCESS_FILESYSTEM, FileDialog.FILE_MODE_SAVE_FILE); conversion_output_dialog.filters = PackedStringArray(["*.glb ; Modèle Godot"]); conversion_output_dialog.file_selected.connect(_convert)
	EditorInterface.get_selection().selection_changed.connect(_selection_changed)
	_refresh_library(); _log("Atelier prêt. Commencer par Maps → Ouvrir la map d'exemple.")
	if OS.get_environment("ARCHELYS_WORKSHOP_EDITOR_CHECKS") == "1": call_deferred("_editor_checks")

func _exit_tree() -> void:
	remove_tool_menu_item("Ouvrir l'atelier Archélys")
	if EditorInterface.get_selection().selection_changed.is_connected(_selection_changed): EditorInterface.get_selection().selection_changed.disconnect(_selection_changed)
	remove_control_from_docks(dock); dock.queue_free()
	for dialog in [source_dialog, dump_dialog, export_dialog, asset_dialog, scene_dialog, conversion_dialog, conversion_output_dialog]: dialog.queue_free()

func _tab(parent: TabContainer, title: String) -> VBoxContainer:
	var scroll := ScrollContainer.new(); scroll.name = title; parent.add_child(scroll)
	var box := VBoxContainer.new(); box.size_flags_horizontal = Control.SIZE_EXPAND_FILL; scroll.add_child(box); return box
func _note(parent: Node, text: String) -> Label:
	var label := Label.new(); label.text = text; label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; parent.add_child(label); return label
func _button(parent: Node, text: String, callback: Callable) -> void:
	var button := Button.new(); button.text = text; parent.add_child(button); button.pressed.connect(callback)
func _dialog(access: int, mode: int) -> FileDialog:
	var dialog := FileDialog.new(); dialog.access = access; dialog.file_mode = mode; dock.add_child(dialog); return dialog
func _log(text: String) -> void: output.text = text
func _show_dock() -> void:
	dock.show()
	var parent := dock.get_parent()
	if parent is EditorDock:
		parent.open(); parent.make_visible()
	elif parent is TabContainer:
		parent.current_tab = parent.get_tab_idx_from_control(dock)

func _refresh_library() -> void:
	library.clear(); rows.clear()
	for entry: Dictionary in Catalog.read_catalog().assets:
		if not search.text.is_empty() and search.text.to_lower() not in str(entry).to_lower(): continue
		rows.append(entry); library.add_item(entry.label + (" [3D]" if str(entry.path).ends_with(".glb") else " [2D]"))
		library.set_item_tooltip(library.item_count - 1, "%s\n%s\n%s" % [entry.path, entry.source, entry.rights])

func _place() -> void:
	var root := EditorInterface.get_edited_scene_root()
	if root == null or not root.get_script() in [Map2D, Map3D]: _log("Ouvrir ou créer une map Atelier."); return
	if library.get_selected_items().is_empty(): _log("Choisir un asset."); return
	var entry: Dictionary = rows[library.get_selected_items()[0]]
	var node := Factory.make(entry, 2 if root is Node2D else 3)
	if node == null: _log("Dimension incompatible : PNG en 2D, GLB en 3D."); return
	var id: String = entry.id; var suffix := 1
	while root.find_child(id, true, false) != null: suffix += 1; id = str(entry.id) + "_" + str(suffix)
	node.object_id = id; node.name = id
	node.position = root.spawn
	var undo := get_undo_redo(); undo.create_action("Placer " + str(entry.label))
	undo.add_do_method(root, "add_child", node, true)
	undo.add_do_method(node, "set_owner", root)
	undo.add_do_reference(node); undo.add_undo_method(root, "remove_child", node); undo.commit_action()
	EditorInterface.get_selection().clear(); EditorInterface.get_selection().add_node(node)
	_log("Objet placé au point de départ. Déplacer dans la vue Godot ; régler sa collision dans l'inspecteur.")

func _selection_changed() -> void:
	selected_object = null
	for node in EditorInterface.get_selection().get_selected_nodes():
		if node.get_script() in [Factory.Object2D, Factory.Object3D]: selected_object = node; break
	_refresh_event()
func _refresh_event() -> void:
	event_steps.clear()
	if not is_instance_valid(selected_object): event_label.text = "Sélectionner un objet Atelier."; return
	event_label.text = "Objet : " + selected_object.object_id
	if selected_object.interaction == null: return
	for step in selected_object.interaction.steps:
		event_steps.add_item("(vide)" if step == null else step.action + " • " + (step.french.left(40) if step.action == "dialogue" else step.key))
func _create_event() -> void:
	if not is_instance_valid(selected_object): return
	if selected_object.interaction != null: _log("Événement existant conservé."); return
	var event := Event.new(); event.resource_local_to_scene = true; event.event_id = selected_object.object_id + "-interaction"
	var undo := get_undo_redo(); undo.create_action("Créer événement")
	undo.add_do_property(selected_object, "interaction", event); undo.add_undo_property(selected_object, "interaction", null)
	undo.add_do_method(self, "_refresh_event"); undo.add_undo_method(self, "_refresh_event"); undo.commit_action()
func _append_step() -> void:
	if not is_instance_valid(selected_object) or selected_object.interaction == null: _log("Créer d'abord l'événement."); return
	var step := Step.new(); step.action = action.get_item_text(action.selected); step.key = key.text.strip_edges(); step.french = fr.text; step.english = en.text
	var next: Array[Step] = selected_object.interaction.steps.duplicate(); next.append(step); _set_steps(next, "Ajouter étape")
func _remove_step() -> void:
	if not is_instance_valid(selected_object) or selected_object.interaction == null or event_steps.get_selected_items().is_empty(): return
	var next: Array[Step] = selected_object.interaction.steps.duplicate(); next.remove_at(event_steps.get_selected_items()[0]); _set_steps(next, "Supprimer étape")
func _set_steps(next: Array[Step], title: String) -> void:
	var event: Resource = selected_object.interaction
	var undo := get_undo_redo(); undo.create_action(title, UndoRedo.MERGE_DISABLE, selected_object)
	undo.add_do_property(event, "steps", next); undo.add_undo_property(event, "steps", event.steps.duplicate())
	undo.add_do_method(event, "emit_changed"); undo.add_undo_method(event, "emit_changed")
	undo.add_do_method(self, "_refresh_event"); undo.add_undo_method(self, "_refresh_event"); undo.commit_action()
func _inspect_event() -> void:
	if is_instance_valid(selected_object) and selected_object.interaction != null: EditorInterface.edit_resource(selected_object.interaction)

func _register(path: String) -> void:
	var id := path.get_file().get_basename().to_snake_case().replace(" ", "-")
	var error := Catalog.register({"id": id, "label": path.get_file().get_basename(), "path": path, "source": source_edit.text, "rights": rights_edit.text})
	_log("Asset enregistré." if error.is_empty() else error); _refresh_library(); EditorInterface.get_resource_filesystem().scan()
func _validate() -> void:
	var root := EditorInterface.get_edited_scene_root()
	if root == null: _log("Aucune scène ouverte"); return
	var errors := Catalog.validate_map(root)
	_log("Map valide structurellement. Rendu et parcours à vérifier séparément." if errors.is_empty() else "\n".join(errors))
func _new_map(dimension: int) -> void:
	pending_dimension = dimension; scene_dialog.current_path = "res://data/workshop/new-map.tscn"; scene_dialog.popup_centered_ratio(.7)
func _save_new_map(path: String) -> void:
	if FileAccess.file_exists(path): _log("Scène existante préservée. Choisir un nouveau nom."); return
	var root: Node = Map2D.new() if pending_dimension == 2 else Map3D.new()
	root.name = path.get_file().get_basename().validate_node_name(); root.map_id = path.get_file().get_basename()
	if root is Node2D:
		var texture := AtlasTexture.new(); texture.atlas = load("res://assets/drawn/calibration/hero-sheet.png"); texture.region = Rect2(186, 33, 148, 318); root.actor_texture = texture
	else:
		var light := DirectionalLight3D.new(); light.rotation_degrees = Vector3(-55, -20, 0); root.add_child(light); light.owner = root
		var floor_body := StaticBody3D.new(); root.add_child(floor_body); floor_body.owner = root
		var mesh := MeshInstance3D.new(); var box := BoxMesh.new(); box.size = Vector3(40, .2, 40); mesh.mesh = box; mesh.position.y = -.1; floor_body.add_child(mesh); mesh.owner = root
		var collider := CollisionShape3D.new(); var shape := BoxShape3D.new(); shape.size = box.size; collider.shape = shape; collider.position.y = -.1; floor_body.add_child(collider); collider.owner = root
	var packed := PackedScene.new(); var error := packed.pack(root)
	if error == OK: error = ResourceSaver.save(packed, path)
	root.free()
	if error != OK: _log("Création impossible : " + error_string(error)); return
	var maps_path := "res://data/workshop/maps.json"
	var maps: Variant = JSON.parse_string(FileAccess.get_file_as_string(maps_path))
	if not maps is Dictionary: maps = {}
	if maps.has(path.get_file().get_basename()): _log("Map créée ; identifiant déjà présent dans maps.json, corriger avant une transition.")
	else:
		maps[path.get_file().get_basename()] = path
		var file := FileAccess.open(maps_path, FileAccess.WRITE); file.store_string(JSON.stringify(maps, "\t"))
	EditorInterface.get_resource_filesystem().scan(); EditorInterface.open_scene_from_path(path)
func _inspect_archive(path: String) -> void:
	archive_path = path; archive_report = Garc.inspect(path); archive_rows.clear()
	if archive_report.has("error"): _log(archive_report.error); return
	for row: Dictionary in archive_report.rows: archive_rows.add_item("%05d / %02d • %d o • %s" % [row.member, row.sub, row.bytes, row.kind])
	_log("GARC v6 • %d membres • %d sous-fichiers. Extraction brute uniquement." % [archive_report.members, archive_report.rows.size()])
func _inspect_dump(directory: String) -> void:
	dump_resources.clear(); archive_rows.clear(); archive_report = {}
	dump_report = preload("res://addons/archelys_workshop/core/usul_source.gd").inspect(directory)
	if dump_report.has("error"): _log(dump_report.error); return
	for row: Dictionary in dump_report.resources: dump_resources.add_item("%s • %d o • %s" % [row.label, row.bytes, "GARC" if row.garc else "format non reconnu"])
	_log("%s • révision non déterminée • %d ressources repérées. Aucun import de map effectué." % [dump_report.game, dump_report.resources.size()])
func _extract(directory: String) -> void:
	if archive_rows.get_selected_items().is_empty(): return
	var row: Dictionary = archive_report.rows[archive_rows.get_selected_items()[0]]
	var result := Garc.extract(archive_path, row.member, row.sub, directory)
	_log(str(result.get("error", "Membre extrait avec manifeste : " + str(result.get("path", "")))))

func _convert(path: String) -> void:
	if conversion_pid > 0: _log("Une conversion est déjà en cours."); return
	var bridge := ProjectSettings.globalize_path("res://../tools/convert_usul_asset.py").simplify_path()
	if not FileAccess.file_exists(bridge): _log("Pont Blender absent : utiliser le projet Archélys complet avec tools/."); return
	if path.get_extension().to_lower() != "glb" or FileAccess.file_exists(path): _log("Choisir un nouveau fichier GLB."); return
	if not FileAccess.file_exists(blender_edit.text) or not FileAccess.file_exists(addon_edit.text.path_join("__init__.py")): _log("Configurer Blender et le dossier de l'add-on."); return
	conversion_report = ProjectSettings.globalize_path("user://conversion-%d.json" % Time.get_ticks_usec())
	var args := PackedStringArray(["--background", "--factory-startup", "--python-exit-code", "1", "--python", bridge, "--", "--addon", addon_edit.text, "--output", path, "--report", conversion_report])
	args.append_array(conversion_inputs)
	conversion_pid = OS.create_process(blender_edit.text, args)
	if conversion_pid < 0: _log("Blender n'a pas démarré."); return
	var settings := EditorInterface.get_editor_settings(); settings.set_setting("archelys_workshop/blender", blender_edit.text); settings.set_setting("archelys_workshop/n3ds_addon", addon_edit.text)
	_log("Conversion locale en cours ; l'éditeur reste utilisable.")
func _process(_delta: float) -> void:
	if conversion_pid < 0 or OS.is_process_running(conversion_pid): return
	conversion_pid = -1
	if not FileAccess.file_exists(conversion_report): _log("Conversion interrompue sans rapport : vérifier Blender et l'add-on."); return
	var report: Variant = JSON.parse_string(FileAccess.get_file_as_string(conversion_report))
	if not report is Dictionary: _log("Rapport de conversion invalide."); return
	if report.has("error"): _log("Conversion refusée : " + str(report.error)); return
	_log("GLB produit : %s\nContrôler le rendu, puis l'importer dans le projet et l'ajouter à la bibliothèque. Rapport : %s" % [report.get("output", ""), conversion_report])
	EditorInterface.get_resource_filesystem().scan()
func _cancel_conversion() -> void:
	if conversion_pid > 0 and OS.is_process_running(conversion_pid): OS.kill(conversion_pid)
	conversion_pid = -1; _log("Conversion arrêtée. Sources conservées ; un éventuel fichier .partial.glb reste à examiner.")
func _editor_checks() -> void:
	await load("res://tests/workshop_editor.gd").new().run(self)
