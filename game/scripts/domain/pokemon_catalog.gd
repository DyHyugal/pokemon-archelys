extends RefCounted
## Read-only, deliberately bounded laboratory catalogue.
const WILD_BASES=["rattata","pikachu","bulbasaur","charmander","squirtle"]
const FISH_BASE="magikarp"
const FISH_MAX_LEVEL=20
static var cached: Dictionary = {}
static func data() -> Dictionary:
	if cached.is_empty(): cached=JSON.parse_string(FileAccess.get_file_as_string("res://data/pokemon/laboratory.json"))
	return cached
static func species(id: String) -> Dictionary:
	return data().species.get(id,{})
static func move(id: String) -> Dictionary:
	return data().moves.get(id,{})
static func name_of(id: String, language: String="fr") -> String:
	var record: Dictionary=species(id) if data().species.has(id) else data().moves.get(id,data().items.get(id,{}))
	return record.get("names",{}).get(language,id)
static func effectiveness(type: String, targets: Array) -> float:
	var result: float=1.0
	for target: String in targets:
		result*=float(data().chart.get(type,{}).get(target,1.0))
	return result
static func legal_species(id: String, level: int) -> String:
	var record:=species(id)
	if record.is_empty():return ""
	var seen: Array=[]
	while record.has("previous") and level<int(record.get("minimum_level",1)):
		if id in seen:return ""
		seen.append(id)
		id=record.previous;record=species(id)
		if record.is_empty():return ""
	seen.clear()
	while record.has("evolution") and record.evolution.has("level") and level>=int(record.evolution.level):
		if id in seen:return ""
		seen.append(id)
		id=record.evolution.target;record=species(id)
		if record.is_empty():return ""
	return id

static func text(group: String,id: String,language: String="fr") -> String:
	return data().get(group,{}).get(id,{}).get(language,id)

static func lineage(id: String) -> Array:
	var result: Array=[]
	while not id.is_empty():
		if id in result or species(id).is_empty():return []
		result.append(id);id=species(id).get("previous","")
	return result
