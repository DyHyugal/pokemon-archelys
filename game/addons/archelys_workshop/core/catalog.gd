@tool
extends RefCounted
## Only project-local resources. Raw source dumps are never silently copied to res://.
const PATH = "res://data/workshop/library.json"
static func read_catalog() -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH)) if FileAccess.file_exists(PATH) else null
	return value if value is Dictionary and value.get("schema") == 1 and value.get("assets") is Array else {"schema": 1, "assets": []}

static func entry_errors(entry: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	for key in ["id", "label", "path", "source", "rights"]:
		if not entry.get(key) is String or entry[key].strip_edges().is_empty(): errors.append("Champ requis : " + key)
	if not errors.is_empty(): return errors
	var path: String = entry.path
	if not path.begins_with("res://") or path.contains("..") or path.get_extension().to_lower() not in ["png", "jpg", "jpeg", "webp", "glb"]: errors.append("Ressource locale PNG/JPG/WebP/GLB requise")
	elif not FileAccess.file_exists(path): errors.append("Ressource absente : " + path)
	return errors

static func register(entry: Dictionary) -> String:
	var errors := entry_errors(entry)
	if not errors.is_empty(): return "\n".join(errors)
	var catalog := read_catalog()
	for row: Dictionary in catalog.assets:
		if row.id == entry.id: return "Identifiant existant préservé"
	var record := entry.duplicate(true)
	record.sha256 = FileAccess.get_sha256(record.path)
	catalog.assets.append(record)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(PATH.get_base_dir()))
	var file := FileAccess.open(PATH + ".tmp", FileAccess.WRITE)
	if file == null: return "Bibliothèque non inscriptible"
	file.store_string(JSON.stringify(catalog, "\t")); file.close()
	var error := DirAccess.rename_absolute(ProjectSettings.globalize_path(PATH + ".tmp"), ProjectSettings.globalize_path(PATH))
	return "" if error == OK else "Enregistrement impossible"

static func validate_map(root: Node) -> PackedStringArray:
	var errors := PackedStringArray()
	var ids: Dictionary = {}
	var events: Dictionary = {}
	var found := false
	for node in root.find_children("*", "", true, false):
		if not node.get_script() in [preload("res://addons/archelys_workshop/nodes/object_2d.gd"), preload("res://addons/archelys_workshop/nodes/object_3d.gd")]: continue
		found = true
		if node.object_id.is_empty() or ids.has(node.object_id): errors.append("Identifiant vide/dupliqué : " + node.object_id)
		ids[node.object_id] = true
		if node.interaction != null:
			for error: String in node.interaction.errors(): errors.append(node.object_id + " : " + error)
			if events.has(node.interaction.event_id): errors.append("Événement dupliqué : " + node.interaction.event_id)
			events[node.interaction.event_id] = true
	if not found: errors.append("Aucun objet Atelier dans la map")
	return errors
