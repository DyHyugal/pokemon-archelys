extends SceneTree
const Garc = preload("res://addons/archelys_workshop/core/garc.gd")
const Event = preload("res://addons/archelys_workshop/core/event.gd")
const Step = preload("res://addons/archelys_workshop/core/step.gd")
const Runner = preload("res://addons/archelys_workshop/core/event_runner.gd")
const Catalog = preload("res://addons/archelys_workshop/core/catalog.gd")
const Factory = preload("res://addons/archelys_workshop/core/factory.gd")
var checks := 0
var failures := 0
func check(value: bool, label: String) -> void:
	checks += 1
	if not value: failures += 1; push_error(label)
func write(path: String, bytes: PackedByteArray) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE); file.store_buffer(bytes); file.close()
func fixture() -> PackedByteArray:
	var bytes := PackedByteArray(); bytes.resize(111)
	for spec in [[0, "CRAG"], [36, "OTAF"], [52, "BTAF"], [92, "BMIF"]]:
		var data: PackedByteArray = str(spec[1]).to_ascii_buffer()
		for i in 4: bytes[spec[0] + i] = data[i]
	for spec in [[4, 36], [12, 4], [16, 104], [20, 111], [32, 4], [40, 16], [48, 0], [56, 40], [60, 2], [64, 5], [68, 0], [72, 3], [76, 3], [80, 3], [84, 7], [88, 4], [96, 12], [100, 7]]: bytes.encode_u32(spec[0], spec[1])
	bytes.encode_u16(8, 0xfeff); bytes.encode_u16(10, 0x600); bytes.encode_u16(44, 1)
	for i in 7: bytes[104 + i] = i + 1
	return bytes
func step(action: String, key: String = "") -> Resource:
	var resource := Step.new(); resource.action = action; resource.key = key; return resource
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var folder := "user://workshop-contracts-" + str(Time.get_ticks_usec())
	DirAccess.make_dir_recursive_absolute(folder)
	var path := folder.path_join("fixture.garc"); var bytes := fixture(); write(path, bytes)
	var original := FileAccess.get_sha256(path)
	var romfs := folder.path_join("romfs/a/0/1"); DirAccess.make_dir_recursive_absolute(romfs)
	write(romfs.path_join("7"), bytes)
	var header := PackedByteArray(); header.resize(512)
	for i in 4: header[256 + i] = "NCCH".to_ascii_buffer()[i]
	for i in 9: header[336 + i] = "CTR-P-A2B".to_ascii_buffer()[i]
	write(folder.path_join("HeaderNCCH0.bin"), header)
	var source := preload("res://addons/archelys_workshop/core/usul_source.gd").inspect(folder)
	check(source.game == "Pokémon Ultra-Lune" and source.resources.size() == 1 and source.resources[0].garc, "Dump identification checks NCCH product and locates known archive")
	var report := Garc.inspect(path)
	check(not report.has("error") and report.members == 1 and report.rows.size() == 2 and report.rows[1].sub == 2, "GARC subfile masks preserve non-contiguous IDs")
	var out := folder.path_join("output"); var extracted := Garc.extract(path, 0, 2, out)
	check(not extracted.has("error") and FileAccess.get_file_as_bytes(extracted.path) == PackedByteArray([4, 5, 6, 7]), "Extraction uses subfile byte ranges, not padding or neighbouring payload")
	check(FileAccess.get_sha256(path) == original and extracted.manifest.source_archive_sha256 == original, "Source is unchanged and provenance identifies it")
	check(Garc.extract(path, 0, 2, out).has("error"), "Existing extracted file is preserved")
	check(Garc.extract(path, 50, 0, out).has("error"), "Nonexistent member is refused")
	bytes.encode_u32(84, 500); write(path, bytes)
	check(Garc.inspect(path).has("error") and Garc.extract(path, 0, 0, out).has("error"), "Out-of-bounds archive rejected before extraction")
	bytes = fixture(); bytes.encode_u16(10, 0x400); write(path, bytes)
	check(Garc.inspect(path).has("error"), "Unsupported archive version is explicit")
	write(path, PackedByteArray([0, 1, 2])); check(Garc.inspect(path).has("error"), "Truncated ROM/archive rejected")
	bytes = fixture(); bytes.encode_u32(80, 2); write(path, bytes)
	check(Garc.inspect(path).has("error"), "Partially overlapping archive members are refused")
	check(Garc.classify(PackedByteArray([0x11, 0, 0, 1])).begins_with("LZ") and Garc.classify(PackedByteArray([66, 67, 72, 0])).begins_with("BCH"), "Compressed/console formats are not presented as Godot-ready models")
	var event := Event.new(); event.event_id = "test"; event.once_flag = "finished"
	var speech = step("dialogue"); speech.french = "Bonjour"; speech.english = "Hello"
	event.steps.assign([speech, step("battle", "workshop-trainer"), step("set_flag", "opened"), step("give_item", "token")])
	var runner := Runner.new(); runner.locale = "en"
	check(runner.begin(event) and runner.next().text == "Hello", "Localized authored dialogue starts")
	check(runner.next().action == "waiting" and runner.index == 1, "No timer/automatic dialogue advance")
	check(not runner.acknowledge("battle") and runner.waiting == "dialogue", "Wrong acknowledgement cannot skip dialogue")
	check(runner.acknowledge("dialogue") and runner.next().action == "battle", "Battle is a suspended external action")
	check(not runner.flags.has("opened") and not runner.inventory.has("token"), "No reward before battle completion")
	runner.acknowledge("battle", false)
	check(runner.active == null and not runner.flags.has("finished") and not runner.flags.has("opened"), "Defeat/cancellation aborts subsequent progression")
	check(runner.begin(event), "Failed battle leaves event repeatable")
	runner.next(); runner.acknowledge("dialogue"); runner.next(); runner.acknowledge("battle", true)
	check(runner.next().action == "finished" and runner.flags.opened and runner.flags.finished and runner.inventory.token == 1, "Victory permits authored rewards and once flag")
	check(not runner.begin(event) and runner.inventory.token == 1, "Completed event cannot duplicate reward")
	var saved: Variant = JSON.parse_string(JSON.stringify(runner.snapshot())); var restored := Runner.new()
	check(restored.restore(saved) and restored.flags.opened and restored.inventory.token == 1, "JSON save round-trip preserves persistent state")
	var before := restored.snapshot()
	check(not restored.restore({"schema": 1, "flags": {"bad": 1}, "inventory": {}}) and restored.snapshot() == before, "Malformed flags rejected without partial restore")
	check(not restored.restore({"schema": 1, "flags": {}, "inventory": {"token": -1}}), "Invalid inventory rejected")
	var gated := Event.new(); gated.event_id = "gate"; gated.required_flag = "permission"; gated.steps.assign([speech])
	check(not restored.begin(gated), "Story requirement blocks interaction")
	gated.required_flag = ""; gated.forbidden_flag = "opened"; check(not restored.begin(gated), "Forbidden story state blocks interaction")
	var invalid = step("unknown"); gated.steps.assign([invalid]); check(not gated.errors().is_empty(), "Unknown authored actions refused")
	var transactional := Event.new(); transactional.event_id = "rollback"; transactional.steps.assign([step("give_item", "bonus"), step("set_flag", "temporary"), step("battle", "workshop-trainer")])
	var isolated := Runner.new(); isolated.begin(transactional); isolated.next(); isolated.acknowledge("battle", false)
	check(isolated.flags.is_empty() and isolated.inventory.is_empty(), "Failure rolls back earlier event effects, preventing retry duplication")
	var catalog := Catalog.read_catalog(); var prop := Factory.make(catalog.assets[0], 2)
	check(prop != null and prop.texture is AtlasTexture and prop.texture.get_width() == catalog.assets[0].region[2], "Palette uses cropped original asset, not entire atlas")
	check(Factory.make(catalog.assets[0], 3) == null, "2D image cannot masquerade as a 3D object")
	prop.free()
	var model := Factory.make({"id": "original-arcade", "label": "Original fixture", "path": "res://assets/demo/arcade.glb", "source": "Original D69", "rights": "Original prototype"}, 3)
	check(model != null and model.model is PackedScene, "Existing GLB becomes an editable 3D placeable")
	model.blocking_size = Vector3(2, 2, 2); root.add_child(model)
	await process_frame
	check(model.find_children("*", "MeshInstance3D", true, false).size() > 0 and model.find_children("*", "CollisionShape3D", true, false).size() == 1, "3D placeable builds real visual geometry and explicit collision")
	model.queue_free(); await process_frame
	var map = load("res://data/workshop/example.tscn").instantiate()
	check(Catalog.validate_map(map).is_empty(), "Serialized example has valid authored events and unique IDs")
	map.get_node("guide").object_id = map.get_node("trainer").object_id
	check(not Catalog.validate_map(map).is_empty(), "Duplicate map IDs are detected")
	map.free()
	print("WORKSHOP CONTRACTS: %d checks, %d failures" % [checks, failures]); quit(1 if failures else 0)
