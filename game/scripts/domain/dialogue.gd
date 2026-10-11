class_name DialogueModel
extends RefCounted

# Presentation-independent manual dialogue; no timers or story decisions.
var lines: Array[String] = []
var speaker: String = ""
var index: int = 0
var active: bool = false

func begin(record: Dictionary, locale: String) -> bool:
	var localized: Variant = record.get(locale, record.get("fr", {}))
	if not localized is Dictionary:
		return false
	var content: Variant = localized.get("lines", [])
	if not content is Array or content.is_empty():
		return false
	for line: Variant in content:
		if not line is String or line.is_empty():
			return false
	lines.assign(content)
	speaker = str(localized.get("speaker", ""))
	index = 0
	active = true
	return true

func current_line() -> String:
	return lines[index] if active else ""

func advance() -> void:
	if not active:
		return
	index += 1
	if index >= lines.size():
		active = false
