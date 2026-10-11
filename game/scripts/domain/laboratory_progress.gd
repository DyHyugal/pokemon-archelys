class_name LaboratoryProgress
extends RefCounted

# Original test content, independent of the final story and item catalogue.
const OBJECTIVES: Array[String] = ["guide", "sign", "crate"]
var completed: Dictionary = {}
var tokens: int = 0

func complete(id: String) -> bool:
	if id not in OBJECTIVES or completed.has(id):
		return false
	completed[id] = true
	if id == "crate":
		tokens = 1
	return true

func snapshot() -> Dictionary:
	return {"completed": completed.duplicate(), "tokens": tokens}

static func validate(value: Variant) -> bool:
	if not value is Dictionary or not value.get("completed") is Dictionary:
		return false
	var amount: Variant = value.get("tokens")
	if not (amount is int or amount is float) or not is_finite(float(amount)) or float(amount) != floorf(float(amount)) or float(amount)<0.0 or float(amount)>1.0:
		return false
	for id: Variant in value.completed:
		if id not in OBJECTIVES or value.completed[id] != true:
			return false
	return int(amount) == (1 if value.completed.has("crate") else 0)

func restore(value: Dictionary) -> bool:
	if not validate(value):
		return false
	completed = value.completed.duplicate()
	tokens = int(value.tokens)
	return true
