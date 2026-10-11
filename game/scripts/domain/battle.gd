class_name BattleModel
extends RefCounted

# Minimal deterministic turn laboratory, NOT a complete Gen IX engine.
var units: Dictionary = {}
var before_combat: Dictionary = {}
var raid: bool = false
var turn_index: int = 0

func begin(roster: Dictionary, is_raid: bool) -> void:
	units = roster.duplicate(true)
	before_combat = units.duplicate(true)
	raid = is_raid
	turn_index = 0

func resolve(actions: Array) -> Array[String]:
	var valid: Array = []
	var used: Dictionary = {}
	for action: Dictionary in actions:
		var actor: String = str(action.get("actor", ""))
		var target: String = str(action.get("target", ""))
		if not units.has(actor) or not units.has(target) or used.has(actor):
			continue
		if int(units[actor].hp) <= 0 or int(units[target].hp) <= 0:
			continue
		if raid and units[actor].side == units[target].side:
			continue
		# Priority and power originate in trusted move data, not client submissions.
		used[actor] = true
		valid.append({"actor": actor, "target": target,
			"priority": int(units[actor].get("priority", 0)),
			"speed": int(units[actor].speed)})
	valid.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a.priority != b.priority:
			return a.priority > b.priority
		if a.speed != b.speed:
			return a.speed > b.speed
		return str(a.actor) < str(b.actor)) # Stable prototype tie-break, not Gen IX.
	var log: Array[String] = []
	for action: Dictionary in valid:
		if int(units[action.actor].hp) <= 0 or int(units[action.target].hp) <= 0:
			continue
		var damage: int = maxi(1, int(units[action.actor].get("power", 20)))
		units[action.target].hp = maxi(0, int(units[action.target].hp) - damage)
		log.append("%s → %s : %d" % [action.actor, action.target, damage])
	turn_index += 1
	return log

func abandon() -> void:
	units = before_combat.duplicate(true)
	turn_index = 0
