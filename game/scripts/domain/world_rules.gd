class_name WorldRules
extends RefCounted

const HOUSES: Array[Vector2] = [Vector2(-8, 0), Vector2(8, 0), Vector2(-8, 6)]
const TREES: Array[Vector2] = [Vector2(-12,-5), Vector2(12,-5), Vector2(10,7), Vector2(-4,7)]

static func walkable(pos: Vector2) -> bool:
	if absf(pos.x) > 14.0 or absf(pos.y) > 10.0:
		return false
	for house: Vector2 in HOUSES:
		if absf(pos.x - house.x) < 2.0 and absf(pos.y - house.y) < 1.8:
			return false
	for tree: Vector2 in TREES:
		if pos.distance_to(tree) < 0.8:
			return false
	return true
