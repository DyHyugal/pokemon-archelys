extends RefCounted
const Content=preload("res://scripts/domain/demo_content.gd")
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
static func habitats(id: String) -> Array:
 var v:=Content.data();var out: Array=[]
 if id in v.get("wild",[]):out.append({"place":"trail","method":"grass","level":v.wild_level})
 if id==v.get("fishing",""):out.append({"place":"town","method":"fishing","level":v.fishing_level})
 out.append_array(preload("res://scripts/domain/demo_chapter.gd").habitats(id))
 return out
static func roster(records: RefCounted,filter: int,query: String,locale: String) -> Array:
 var out: Array=[]
 for id: String in Catalog.data().species:
  if filter==1 and not records.seen.has(id):continue
  if filter==2 and not records.caught.has(id):continue
  if not query.is_empty() and (not records.seen.has(id) or not Catalog.name_of(id,locale).to_lower().contains(query.to_lower())):continue
  out.append(id)
 return out
