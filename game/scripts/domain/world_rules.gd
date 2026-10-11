class_name WorldRules
extends RefCounted

const INTERACTIONS := {"guide":Vector3(3,0,3), "sign":Vector3(-3,0,-3), "crate":Vector3(6,0,6)}

const HOUSES: Array[Vector2] = [Vector2(-8, 0), Vector2(8, 0), Vector2(-8, 6)]
const TREES: Array[Vector2] = [Vector2(-12,-5), Vector2(12,-5), Vector2(10,7), Vector2(-4,7)]

static func walkable(pos: Vector2, ignore_interaction: String = "") -> bool:
	if absf(pos.x) > 14.0 or absf(pos.y) > 10.0:
		return false
	for id: String in INTERACTIONS:
		if id==ignore_interaction:
			continue
		var point: Vector3=INTERACTIONS[id]
		var radius: float=0.8 if id=="crate" else 0.4
		if pos.distance_to(Vector2(point.x,point.z))<radius:
			return false
	for house: Vector2 in HOUSES:
		if absf(pos.x - house.x) < 2.0 and absf(pos.y - house.y) < 1.8:
			return false
	for tree: Vector2 in TREES:
		if pos.distance_to(tree) < 0.8:
			return false
	return true

static func can_step(origin: Vector2, destination: Vector2) -> bool:
	if walkable(destination):
		return true
	# A legacy save may be inside a newly added object. Permit outward steps
	# through that object only, still checking all other obstacles and bounds.
	for id: String in INTERACTIONS:
		var point: Vector3=INTERACTIONS[id]
		var center:=Vector2(point.x,point.z)
		var radius: float=0.8 if id=="crate" else 0.4
		if origin.distance_to(center)<radius and destination.distance_to(center)>origin.distance_to(center) and walkable(destination,id):
			return true
	return false
