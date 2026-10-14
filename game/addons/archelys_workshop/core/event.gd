@tool
extends Resource
const Step = preload("res://addons/archelys_workshop/core/step.gd")
@export var event_id: String = ""
@export var required_flag: String = ""
@export var forbidden_flag: String = ""
@export var once_flag: String = ""
@export var steps: Array[Step] = []

func errors() -> PackedStringArray:
	var result := PackedStringArray()
	if event_id.strip_edges().is_empty(): result.append("Identifiant d'événement manquant")
	if steps.is_empty(): result.append("Événement sans étape")
	for i in steps.size():
		var step = steps[i]
		if step == null:
			result.append("Étape %d vide" % (i + 1)); continue
		if step.action not in ["dialogue", "set_flag", "require_flag", "give_item", "battle", "warp"]:
			result.append("Action inconnue à l'étape %d" % (i + 1))
		if step.action == "dialogue" and step.french.strip_edges().is_empty(): result.append("Dialogue FR vide")
		if step.action in ["set_flag", "require_flag", "give_item", "battle", "warp"] and step.key.strip_edges().is_empty(): result.append("Référence vide : " + step.action)
		if step.action == "give_item" and (step.quantity < 1 or step.quantity > 999): result.append("Quantité hors limites")
		if not step.destination.is_finite(): result.append("Position non finie")
	return result
