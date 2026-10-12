extends RefCounted
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
const Mon=preload("res://scripts/domain/pokemon.gd")
static func data() -> Dictionary:
 var parser:=JSON.new()
 if parser.parse(FileAccess.get_file_as_string("res://data/demo/content.json"))!=OK:return {}
 return parser.data if validate(parser.data) else {}
static func validate(v: Variant) -> bool:
 if not v is Dictionary or v.get("status") not in ["temporary-demo-fixtures","owner-selection"]:return false
 for field: String in ["starter_level","wild_level","fishing_level"]:
  if not Mon.integer(v.get(field),1,100):return false
 for field: String in ["starters","wild"]:
  if not v.get(field) is Array or v[field].is_empty():return false
  var seen: Array=[]
  for id: Variant in v[field]:
   if not id is String or Catalog.species(id).is_empty() or id in seen:return false
   seen.append(id)
   if Catalog.legal_species(id,int(v.starter_level if field=="starters" else v.wild_level))!=id:return false
 for field: String in ["fishing","gift_egg"]:
  if not v.get(field) is String or Catalog.species(v[field]).is_empty():return false
 if Catalog.legal_species(v.fishing,int(v.fishing_level))!=v.fishing:return false
 if v.gift_egg not in preload("res://scripts/domain/nursery.gd").GIFTS:return false
 if not v.get("trainer") is Array or v.trainer.is_empty() or v.trainer.size()>6:return false
 for entry: Variant in v.trainer:
  if not entry is Dictionary or not Mon.integer(entry.get("level"),1,100) or not entry.get("species") is String or Catalog.species(entry.species).is_empty():return false
  if Catalog.legal_species(entry.species,int(entry.level))!=entry.species:return false
 return true
static func opponents() -> Array:
 var result: Array=[];var v: Dictionary=data()
 for i: int in range(v.get("trainer",[]).size()):result.append(Mon.make(v.trainer[i].species,int(v.trainer[i].level),900000+i))
 return result
