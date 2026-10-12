extends RefCounted
## Personal discovery history, independent of views and encounter generation.
const Island=preload("res://scripts/domain/island.gd")
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
var seen: Dictionary={}
var caught: Dictionary={}
var scenes: Dictionary={}
const SCENES=["lab-tour","lab-note","slice-prologue","slice-ending","isle-arrival","isle-liberation"]
func observe(id: String, owned: bool=false) -> void:
 if not Catalog.data().species.has(id):return
 seen[id]=true
 if owned:caught[id]=true
func snapshot() -> Dictionary:return {"seen":seen.duplicate(),"caught":caught.duplicate(),"scenes":scenes.duplicate()}
static func validate(value: Variant) -> bool:
 if not value is Dictionary:return false
 for key: String in ["seen","caught","scenes"]:
  if not value.get(key) is Dictionary:return false
  for id: Variant in value[key]:
   if value[key][id]!=true:return false
   if key=="scenes":
    if id not in SCENES:return false
   elif not Catalog.data().species.has(id):return false
 for id: String in value.caught:
  if not value.seen.has(id):return false
 return true
func restore(value: Dictionary) -> bool:
 if not validate(value):return false
 seen=value.seen.duplicate();caught=value.caught.duplicate();scenes=value.scenes.duplicate();return true
static func habitats(id: String) -> Array:
 var result: Array=[]
 # Same source and legality rules as actual laboratory encounter generation.
 for base: String in Catalog.WILD_BASES:
  for level: int in range(2,101):
   if Catalog.legal_species(base,level)==id:
    if "village" not in result:result.append("village")
    if "trail" not in result:result.append("trail")
    break
 for level: int in range(2,Catalog.FISH_MAX_LEVEL+1):
  if Catalog.legal_species(Catalog.FISH_BASE,level)==id:
   result.append("cove");break
 for location: String in Island.POOLS:
  for base: String in Island.POOLS[location]:
   for level: int in range(8,15 if location=="isle-jungle" else 19):
    if Catalog.legal_species(base,level)==id and location not in result:result.append(location)
 return result
