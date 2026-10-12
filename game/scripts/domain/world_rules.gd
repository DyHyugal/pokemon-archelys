class_name WorldRules
extends RefCounted

const Island=preload("res://scripts/domain/island.gd")
const INTERACTIONS := {"guide":Vector3(3,0,3), "sign":Vector3(-3,0,-3), "crate":Vector3(6,0,6)}

const SERVICE_POINTS={"healing":Vector3(0,0,3),"trainer-1":Vector3(6,0,-4),"trainer-2":Vector3(10,0,-4)}

static func interaction_points() -> Dictionary:
	var points:=INTERACTIONS.duplicate();points.merge(SERVICE_POINTS);return points

static func local_points(location: String) -> Dictionary:
	if location in Island.LOCATIONS:return Island.points(location)
	match location:
		"trail":return {"exit":Vector3(0,0,8),"beacon":Vector3(6,0,-2),"trial-gate":Vector3(0,0,-8)}
		"trial":return {"exit-trial":Vector3(0,0,8),"slice-boss":Vector3(0,0,-4)}
		"center":return {"exit":Vector3(0,0,7),"nurse":Vector3(0,0,-3)}
		"shop":return {"exit":Vector3(0,0,7),"counter":Vector3(0,0,-3)}
		"cove":return {"exit":Vector3(0,0,7),"fish":Vector3(0,0,-3),"surf":Vector3(4,0,-3)}
		"district":return {"exit":Vector3(0,0,7),"visuals":Vector3(0,0,3)}
	return {"journey-gate":Vector3(0,0,-6),"center-door":Vector3(-8,0,2.2),"shop-door":Vector3(8,0,2.2),"pier":Vector3(0,0,9),"district-gate":Vector3(0,0,-9),"cut":Vector3(-11,0,3),"rock-smash":Vector3(11,0,3),"strength":Vector3(11,0,6),"climb":Vector3(-11,0,8)}
static func local_walkable(pos: Vector2,location: String) -> bool:
	if location in Island.LOCATIONS:return Island.walkable(pos,location)
	if location in ["trail","trial"]:
		if absf(pos.x)>12 or absf(pos.y)>10:return false
		if location=="trail":
			for side: int in [-1,1]:
				for z: int in [-7,1,7]:
					if pos.distance_to(Vector2(side*10,z))<0.7:return false
			for rock: Vector2 in [Vector2(-7,-2),Vector2(8,4)]:
				if pos.distance_to(rock)<1.6:return false
		elif location=="trial":
			for x: int in [-6,6]:
				for z: int in [-7,2]:
					if pos.distance_to(Vector2(x,z))<0.65:return false
			if pos.distance_to(Vector2(0,-4))<0.45:return false
		return true
	if location in ["center","shop"]:return absf(pos.x)<5.5 and pos.y>-5 and pos.y<8
	if location=="cove":return absf(pos.x)<7 and pos.y<9 and (pos.y>=-2 or (absf(pos.x)<1 and pos.y>=-3))
	if location=="district":
		if absf(pos.x)>14 or absf(pos.y)>10:return false
		for house: Vector2 in HOUSES:
			if absf(pos.x-house.x)<2 and absf(pos.y-house.y)<1.8:return false
		for tree: Vector2 in TREES:
			if pos.distance_to(tree)<0.8:return false
		return true
	return walkable(pos)

const HOUSES: Array[Vector2] = [Vector2(-8, 0), Vector2(8, 0), Vector2(-8, 6)]
const TREES: Array[Vector2] = [Vector2(-12,-5), Vector2(12,-5), Vector2(10,7), Vector2(-4,7)]

static func walkable(pos: Vector2, ignore_interaction: String = "") -> bool:
	if absf(pos.x) > 14.0 or absf(pos.y) > 10.0:
		return false
	for id: String in interaction_points():
		if id==ignore_interaction:
			continue
		var point: Vector3=interaction_points()[id]
		var radius: float=0.8 if id=="crate" else (0.6 if id in SERVICE_POINTS else 0.4)
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
	for id: String in interaction_points():
		var point: Vector3=interaction_points()[id]
		var center:=Vector2(point.x,point.z)
		var radius: float=0.8 if id=="crate" else (0.6 if id in SERVICE_POINTS else 0.4)
		if origin.distance_to(center)<radius and destination.distance_to(center)>origin.distance_to(center) and walkable(destination,id):
			return true
	return false
