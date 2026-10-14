extends RefCounted
## Pauses at dialogue, battle and warp boundaries. Only acknowledged victories resume.
var flags: Dictionary = {}
var inventory: Dictionary = {}
var active: Resource
var index: int = 0
var waiting: String = ""
var locale: String = "fr"
var checkpoint_flags: Dictionary = {}
var checkpoint_inventory: Dictionary = {}

func begin(event: Resource) -> bool:
	if active != null or event == null or not event.errors().is_empty(): return false
	if not event.required_flag.is_empty() and not flags.get(event.required_flag, false): return false
	if not event.forbidden_flag.is_empty() and flags.get(event.forbidden_flag, false): return false
	if not event.once_flag.is_empty() and flags.get(event.once_flag, false): return false
	checkpoint_flags = flags.duplicate(true); checkpoint_inventory = inventory.duplicate(true)
	active = event; index = 0; waiting = ""
	return true

func next() -> Dictionary:
	if active == null: return {"action": "idle"}
	if not waiting.is_empty(): return {"action": "waiting", "kind": waiting}
	while index < active.steps.size():
		var step = active.steps[index]
		index += 1
		match step.action:
			"set_flag": flags[step.key] = step.value
			"require_flag":
				if flags.get(step.key, false) != step.value:
					cancel(); return {"action": "blocked"}
			"give_item": inventory[step.key] = int(inventory.get(step.key, 0)) + step.quantity
			"dialogue":
				waiting = "dialogue"
				return {"action": "dialogue", "text": step.english if locale == "en" and not step.english.is_empty() else step.french}
			"battle":
				waiting = "battle"; return {"action": "battle", "id": step.key}
			"warp":
				waiting = "warp"; return {"action": "warp", "id": step.key, "position": step.destination}
	if not active.once_flag.is_empty(): flags[active.once_flag] = true
	active = null
	checkpoint_flags.clear(); checkpoint_inventory.clear()
	return {"action": "finished"}

func acknowledge(kind: String, success: bool = true) -> bool:
	if waiting.is_empty() or kind != waiting: return false
	if not success: cancel()
	else: waiting = ""
	return true

func cancel() -> void:
	if active != null:
		flags = checkpoint_flags.duplicate(true); inventory = checkpoint_inventory.duplicate(true)
	active = null; waiting = ""; index = 0
	checkpoint_flags.clear(); checkpoint_inventory.clear()

func snapshot() -> Dictionary:
	return {"schema": 1, "flags": flags.duplicate(true), "inventory": inventory.duplicate(true)}

func restore(record: Variant) -> bool:
	if active != null or not record is Dictionary or record.get("schema") != 1: return false
	if not record.get("flags") is Dictionary or not record.get("inventory") is Dictionary: return false
	for key in record.flags:
		if not key is String or key.is_empty() or not record.flags[key] is bool: return false
	for key in record.inventory:
		if not key is String or key.is_empty() or not record.inventory[key] is float and not record.inventory[key] is int: return false
		var amount: float = float(record.inventory[key])
		if not is_finite(amount) or amount < 0 or amount > 1000000 or amount != floor(amount): return false
	flags = record.flags.duplicate(true); inventory = record.inventory.duplicate(true)
	return true
