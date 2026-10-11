class_name CampaignModel
extends RefCounted

# Sandbox rules: no production game design or story is encoded here.
const LabProgress = preload("res://scripts/domain/laboratory_progress.gd")
const Adventure = preload("res://scripts/domain/solo_adventure.gd")
var adventure := Adventure.new()
var laboratory := LabProgress.new()

var participant_count: int = 1
var progress: int = 0
var level_cap: int = 10
var players: Dictionary = {}

func configure(count: int) -> void:
	participant_count = clampi(count, 1, 3)

func add_player(id: int, label: String) -> bool:
	if players.has(id):
		return true
	if players.size() >= participant_count:
		return false
	players[id] = {"name": label.left(32), "position": [float(players.size()) * 2.0, 0.0, 0.0]}
	return true

func all_at_gate() -> bool:
	if players.size() != participant_count:
		return false
	for record: Dictionary in players.values():
		var pos: Array = record["position"]
		if float(pos[2]) > -7.0 or absf(float(pos[0])) > 3.0:
			return false
	return true

func advance() -> bool:
	if not all_at_gate():
		return false
	progress += 1
	level_cap = maxi(level_cap, 10 + progress * 2)
	return true

func snapshot() -> Dictionary:
	# Network IDs are transient; persistence is prototype-only.
	return {"schema": 4, "adventure": adventure.snapshot(), "laboratory": laboratory.snapshot(), "participants": participant_count, "progress": progress,
		"level_cap": level_cap, "players": players.duplicate(true)}

static func validate(data: Dictionary) -> bool:
	if data.get("schema") != 1 and data.get("schema") != 2 and data.get("schema") != 3 and data.get("schema") != 4:
		return false
	if data.get("schema") >= 2 and not LabProgress.validate(data.get("laboratory")):
		return false
	if data.get("schema") >= 3 and not Adventure.validate(data.get("adventure")):
		return false
	if data.get("schema")==4 and not data.adventure.has("exploration"):return false
	for key: String in ["participants", "progress", "level_cap"]:
		if not data.has(key) or not (data[key] is int or data[key] is float):
			return false
		if not is_finite(float(data[key])) or float(data[key]) != float(int(data[key])):
			return false
	if int(data.participants) < 1 or int(data.participants) > 3 or int(data.progress) < 0:
		return false
	if int(data.level_cap) < 10 + int(data.progress) * 2:
		return false
	if not data.get("players") is Dictionary or data.players.size() > int(data.participants):
		return false
	for id: Variant in data.players:
		if not str(id).is_valid_int() or int(id) <= 0:
			return false
	for record: Variant in data.players.values():
		if not record is Dictionary or not record.get("name") is String:
			return false
		if record.name.length() == 0 or record.name.length() > 32:
			return false
		var pos: Variant = record.get("position")
		if not pos is Array or pos.size() != 3:
			return false
		for value: Variant in pos:
			if not (value is int or value is float) or not is_finite(float(value)) or absf(float(value)) > 100.0:
				return false
	return true

func restore(data: Dictionary) -> bool:
	if not validate(data):
		return false
	laboratory = LabProgress.new()
	if data.get("schema") >= 2:
		laboratory.restore(data.laboratory)
	adventure=Adventure.new()
	if data.get("schema")>=3:adventure.restore(data.adventure)
	participant_count = int(data.participants)
	progress = int(data.progress)
	level_cap = int(data.level_cap)
	players.clear()
	for id: Variant in data.players:
		players[int(id)] = data.players[id].duplicate(true)
	return true
