extends SceneTree
const Preview = preload("res://addons/archelys_workshop/runtime/preview.gd")
var checks := 0
var failures := 0
func check(value: bool, label: String) -> void:
	checks += 1
	if not value: failures += 1; push_error(label)
func _initialize() -> void: call_deferred("run")
func settle(battle: RefCounted) -> void:
	var deadline := Time.get_ticks_msec() + 10000
	while battle.busy and Time.get_ticks_msec() < deadline: await create_timer(.01).timeout
	check(not battle.busy and battle.last_error.is_empty(), "Real Showdown worker responds")
func find_preview(world: Node) -> Node:
	for child in world.get_children():
		if child.get_script() == Preview: return child
	return null
func run() -> void:
	var world = load("res://data/workshop/example.tscn").instantiate(); root.add_child(world); current_scene = world
	await process_frame; await process_frame
	var preview := find_preview(world)
	check(preview != null and preview.player is CharacterBody2D, "Authored scene creates preview actor")
	var movement := InputEventKey.new(); movement.physical_keycode = KEY_D; movement.keycode = KEY_D; movement.pressed = true
	var origin: Vector2 = preview.player.position; Input.parse_input_event(movement)
	for i in 4: await physics_frame
	movement.pressed = false; Input.parse_input_event(movement)
	check(preview.player.position.x > origin.x + 1, "Physical keyboard input moves authored preview actor")
	preview.player.position = origin
	check(not world.get_node("passage").visible, "Story-gated object starts hidden")
	preview._interact()
	check(preview.runner.waiting == "dialogue" and preview.message.text.begins_with("Cette map"), "Nearby authored NPC opens French dialogue")
	var first: String = preview.message.text
	await create_timer(.1).timeout
	check(preview.message.text == first and preview.runner.waiting == "dialogue", "Dialogue requires manual input")
	preview._language(); preview._interact()
	check(preview.runner.inventory.get("workshop-token") == 1 and world.get_node("passage").visible, "Reward and flag change actual map visibility")
	preview._interact(); preview._save()
	var record: Variant = JSON.parse_string(FileAccess.get_file_as_string(preview._save_path()))
	check(record.map == "workshop-example" and record.locale == "en" and record.state.inventory["workshop-token"] == 1, "Preview saves locale, flags and inventory under isolated map identity")
	preview.runner.flags.clear(); preview.runner.inventory.clear(); preview.locale = "fr"; preview._load_save()
	check(preview.locale == "en" and preview.runner.flags["gate-open"] and preview.runner.inventory["workshop-token"] == 1, "Reload restores complete authored state")
	var before: Dictionary = preview.runner.snapshot()
	var file := FileAccess.open(preview._save_path(), FileAccess.WRITE); file.store_string('{"schema":1,"map":"wrong"}'); file.close(); preview._load_save()
	check(preview.runner.snapshot() == before, "Wrong-map save preserves running session")
	preview.player.position = world.get_node("trainer").position + Vector2(30, 0)
	preview._interact(); preview._interact()
	check(preview.panel.visible and preview.battle != null and preview.battle.active, "Authored battle opens existing interface and real simulator")
	if preview.battle == null or not preview.battle.active:
		world.queue_free(); await process_frame; quit(1); return
	await settle(preview.battle)
	check(not preview.runner.flags.get("trainer-won", false), "Story victory unset before actual battle")
	var turns := 0
	while preview.battle.active and turns < 50:
		if preview.battle.current(0).hp <= 0:
			for i in preview.adventure.team.size():
				if preview.adventure.team[i].hp > 0:
					preview.battle.execute({"kind": "switch", "index": i}); break
		else:
			var moves: Array = preview.battle.available_moves(0)
			if moves.is_empty(): break
			preview.battle.execute({"kind": "move", "slot": moves[0]})
		await settle(preview.battle); turns += 1
	check(preview.battle.result == "won", "Encounter reaches genuine Showdown victory")
	preview._battle_finished(preview.battle.result)
	check(preview.runner.flags.get("trainer-won", false) and preview.runner.waiting == "dialogue", "Real victory advances authored scene")
	preview._interact(); preview.player.position = world.get_node("passage").position; preview._interact()
	for i in 10: await process_frame
	world = current_scene; preview = find_preview(world)
	check(world.map_id == "workshop-annex", "Authored passage loads registered destination")
	check(preview.runner.inventory["workshop-token"] == 1 and preview.runner.flags["trainer-won"] and preview.player.position == Vector2.ZERO, "Transition preserves story and applies arrival position")
	if DisplayServer.get_name() != "headless" and not OS.get_environment("ARCHELYS_WORKSHOP_PREVIEW_SCREENSHOT").is_empty():
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(OS.get_environment("ARCHELYS_WORKSHOP_PREVIEW_SCREENSHOT"))
	world.queue_free(); await process_frame; root.remove_meta("archelys_workshop")
	print("WORKSHOP PREVIEW: %d checks, %d failures" % [checks, failures]); quit(1 if failures else 0)
