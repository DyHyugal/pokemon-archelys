class_name PreferencesStore
extends RefCounted

const DEFAULTS := {"language":"fr", "camera_size":16.0}
const PATH := "user://preferences.json"

static func validate(value: Variant) -> bool:
	return value is Dictionary and value.get("language") in ["fr","en"] and (value.get("camera_size") is float or value.get("camera_size") is int) and is_finite(float(value.camera_size)) and float(value.camera_size)>=12.0 and float(value.camera_size)<=22.0

static func read(path: String = PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return DEFAULTS.duplicate()
	var parser := JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK or not validate(parser.data):
		return DEFAULTS.duplicate()
	return parser.data

static func write(value: Dictionary, path: String = PATH) -> Error:
	if not validate(value):
		return ERR_INVALID_DATA
	var file := FileAccess.open(path+".tmp",FileAccess.WRITE)
	if file==null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(value));file.flush();file.close()
	return DirAccess.rename_absolute(path+".tmp",path)
