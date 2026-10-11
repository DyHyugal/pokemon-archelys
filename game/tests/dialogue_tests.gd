extends SceneTree
const Dialogue = preload("res://scripts/domain/dialogue.gd")
var checks: int = 0
var failures: int = 0
func check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(label)
func _initialize() -> void:
	var record: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/dialogues/laboratory_guide.json"))
	var model := Dialogue.new()
	check(model.begin(record,"fr") and model.current_line().begins_with("Bienvenue"), "French resource missing")
	model.advance()
	check(model.active and model.index == 1, "A single advance must show exactly the next line")
	model.advance();model.advance()
	check(not model.active and model.current_line().is_empty(), "Last advance must close")
	check(model.begin(record,"en") and model.current_line().begins_with("Welcome"), "English resource missing")
	check(model.begin(record,"unknown") and model.current_line().begins_with("Bienvenue"), "Unknown locale must fall back to French")
	check(not model.begin({"fr":{"lines":[42]}},"fr") and model.current_line().begins_with("Bienvenue"), "Invalid record must preserve active dialogue")
	print("DIALOGUE TESTS: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
