@tool
extends RefCounted
var checks := 0
var failures := 0
func check(value: bool, label: String) -> void:
	checks += 1
	if not value: failures += 1; push_error(label)
func run(plugin: EditorPlugin) -> void:
	# Plugin initialization precedes restoration of the editor's previous scene.
	await plugin.get_tree().create_timer(2).timeout
	EditorInterface.open_scene_from_path("res://data/workshop/example.tscn")
	for i in 30: await plugin.get_tree().process_frame
	var root := EditorInterface.get_edited_scene_root()
	check(root != null and root.get_script() == plugin.Map2D, "Real Godot editor opens authored map")
	if root == null or root.get_script() != plugin.Map2D: plugin.get_tree().quit(1); return
	check(plugin.dock.is_inside_tree() and plugin.library.item_count >= 4, "Plugin dock and palette loaded in editor")
	var before := root.get_child_count()
	plugin.library.select(0); plugin._place()
	for i in 3: await plugin.get_tree().process_frame
	check(root.get_child_count() == before + 1 and plugin.selected_object != null and plugin.selected_object.owner == root, "Palette placement creates an owned scene object")
	if plugin.selected_object == null: plugin.get_tree().quit(1); return
	var placed: Node = plugin.selected_object
	var undo := plugin.get_undo_redo(); var history := undo.get_history_undo_redo(undo.get_object_history_id(root))
	history.undo(); check(root.get_child_count() == before, "Native Ctrl+Z history removes placed object")
	history.redo(); check(root.get_child_count() == before + 1 and placed.owner == root, "Redo restores owned placement")
	EditorInterface.get_selection().clear(); EditorInterface.get_selection().add_node(placed)
	for i in 3: await plugin.get_tree().process_frame
	plugin._create_event(); plugin.fr.text = "Scène créée dans l'éditeur"; plugin._append_step()
	check(placed.interaction.steps.size() == 1 and placed.interaction.steps[0].french == plugin.fr.text, "Visual event form adds persisted declarative step")
	history.undo(); check(placed.interaction.steps.is_empty(), "Undo edits event resource in scene history")
	history.redo(); check(placed.interaction.steps.size() == 1, "Redo restores event step")
	var packed := PackedScene.new(); packed.pack(root)
	var path := "user://workshop-editor-roundtrip.tscn"; ResourceSaver.save(packed, path)
	var reopened = load(path).instantiate()
	check(reopened.get_node(NodePath(str(placed.name))).interaction.steps[0].french == plugin.fr.text, "Save/reopen retains visual placement and authored dialogue")
	reopened.free()
	# Undo all test modifications; no project scene is saved by this test.
	history.undo(); history.undo(); history.undo()
	EditorInterface.get_selection().clear()
	check(root.get_child_count() == before, "Editor checks leave original example structurally unchanged")
	var screenshot := OS.get_environment("ARCHELYS_WORKSHOP_SCREENSHOT")
	if not screenshot.is_empty() and DisplayServer.get_name() != "headless":
		plugin._show_dock()
		for i in 10: await plugin.get_tree().process_frame
		check(plugin.dock.is_visible_in_tree(), "Workshop dock can be revealed in the graphical editor")
		print("WORKSHOP DOCK PARENT: ", plugin.dock.get_parent().get_class())
		RenderingServer.force_draw(false)
		plugin.get_viewport().get_texture().get_image().save_png(screenshot)
	print("WORKSHOP EDITOR: %d checks, %d failures" % [checks, failures])
	plugin.get_tree().quit(1 if failures else 0)
