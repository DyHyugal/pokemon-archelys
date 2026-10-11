extends RefCounted
## Prototype selection. No final hero design or cosmetic economy implied.
const Mon=preload("res://scripts/domain/pokemon.gd")
const COLORS={"skin":["edc5a0","bc8559","794b36","452f29"],"shirt":["397da3","b74948","48845c","b79544"],"pants":["283342","655047","344c43"],"hair":["302927","805635","c9a158","37384c"]}
const DEFAULT={"skin":1,"shirt":0,"pants":0,"hair":0,"style":0,"face":0}
static func validate(value: Variant) -> bool:
 if not value is Dictionary or value.size()!=DEFAULT.size():return false
 for field: String in DEFAULT:
  var count: int=COLORS[field].size() if COLORS.has(field) else (3 if field=="style" else 2)
  if not Mon.integer(value.get(field),0,count-1):return false
 return true
static func normalized(value: Dictionary) -> Dictionary:
 var result: Dictionary={}
 for key: String in DEFAULT:result[key]=int(value[key])
 return result
static func color(value: Dictionary,field: String) -> Color:return Color(COLORS[field][int(value[field])])
