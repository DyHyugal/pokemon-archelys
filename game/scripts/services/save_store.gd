class_name SaveStore
extends RefCounted

const Campaign = preload("res://scripts/domain/campaign.gd")

static func write_snapshot(path: String, data: Dictionary) -> Error:
	if not Campaign.validate(data):
		return ERR_INVALID_DATA
	var file := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(data))
	file.flush()
	file.close()
	# Validate serialization before replacing the live file.
	var read_back := FileAccess.open(path + ".tmp", FileAccess.READ)
	var parser := JSON.new()
	var parse_error := parser.parse(read_back.get_as_text())
	var parsed: Variant = parser.data
	read_back.close()
	if parse_error != OK or not parsed is Dictionary or not Campaign.validate(parsed):
		return ERR_INVALID_DATA
	if FileAccess.file_exists(path) and read_snapshot(path).is_empty():
		# Never discard corrupt or unsupported originals during recovery.
		var preserved: String=path+".invalid-%d-%d.backup" % [Time.get_unix_time_from_system(),Time.get_ticks_usec()]
		var preserve_error:=DirAccess.copy_absolute(path,preserved)
		if preserve_error!=OK:return preserve_error
	if FileAccess.file_exists(path) and not read_snapshot(path).is_empty():
		# Preserve each original schema once, separately from rolling backups.
		var previous: int=int(read_snapshot(path).schema)
		var original_path: String=path+".v%d.backup" % previous
		if previous<int(data.schema) and not FileAccess.file_exists(original_path):
			var migration_error := DirAccess.copy_absolute(path,original_path)
			if migration_error != OK:return migration_error
		var backup_error := DirAccess.copy_absolute(path, path + ".backup")
		if backup_error != OK:
			return backup_error
	return DirAccess.rename_absolute(path + ".tmp", path)

static func read_snapshot(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		return {}
	var parsed: Variant = parser.data
	if not parsed is Dictionary or not Campaign.validate(parsed):
		return {}
	return parsed
