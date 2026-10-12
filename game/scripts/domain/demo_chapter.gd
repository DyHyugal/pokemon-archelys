extends RefCounted
## SPOILERS DEV: proposed continuation, not the final island/raid sequence.
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
const Mon=preload("res://scripts/domain/pokemon.gd")
const LOCATIONS=["canopy","springs","post"]
const NAMES={"town":["Havre","Haven"],"trail":["Sentier","Trail"],"center":["Centre","Center"],"shop":["Boutique","Shop"],"home":["Maison","Home"],"canopy":["Canopée des relais","Relay canopy"],"springs":["Sources du sanctuaire","Sanctuary springs"],"post":["Poste de contrôle RR","RR checkpoint"]}
const ROUTES={"town":["trail"],"trail":["town","canopy"],"canopy":["trail","springs","post"],"springs":["canopy"],"post":["canopy"]}
const FLAGS=["started","roadblock","relay-west","relay-east","keeper","admin-a","admin-b","reported","surf-secret"]
const IDS=["demo-roadblock","demo-spring-keeper","demo-post-a","demo-post-b"]
const WATER=Rect2(-12,2,7,7)
const WATERS={"canopy":WATER,"springs":Rect2(-13.5,-6.5,9,7),"town":Rect2(9,8,9,7)}
var flags: Dictionary={}
var ceilings: Dictionary={}
var visited: Array=[]
var surfing: bool=false # Transient, reconstructed from legal position when loading.
static func name_of(id: String,lang: String) -> String:return NAMES.get(id,[id,id])[0 if lang=="fr" else 1]
static func definitions() -> Dictionary:
 var parser:=JSON.new()
 if parser.parse(FileAccess.get_file_as_string("res://data/demo/chapter.json"))!=OK or not validate_definitions(parser.data):return {}
 return parser.data
static func validate_definitions(v: Variant) -> bool:
 if not v is Dictionary or v.get("status")!="temporary-demo-fixtures" or not v.get("battles") is Dictionary or not v.get("encounters") is Dictionary:return false
 if v.battles.size()!=IDS.size():return false
 var mapping: Dictionary={"demo-roadblock":["trail","roadblock"],"demo-spring-keeper":["springs","keeper"],"demo-post-a":["post","admin-a"],"demo-post-b":["post","admin-b"]}
 var caps: Array=[]
 for id: String in IDS:
  var entry: Variant=v.battles.get(id)
  if not entry is Dictionary or entry.get("location") not in LOCATIONS+["trail"] or entry.get("flag") not in FLAGS or not Mon.integer(entry.get("cap"),10,100) or not Mon.integer(entry.get("money"),0,999999):return false
  if entry.location!=mapping[id][0] or entry.flag!=mapping[id][1]:return false
  if not entry.get("team") is Array or entry.team.is_empty() or entry.team.size()>6:return false
  caps.append(int(entry.cap))
  var ace: int=0
  for member: Variant in entry.team:
   if not member is Dictionary or not member.get("species") is String or Catalog.species(member.species).is_empty() or not Mon.integer(member.get("level"),1,100) or member.get("role") not in ["setter","beneficiary","dps"]:return false
   if Catalog.legal_species(member.species,int(member.level))!=member.species:return false
   ace=maxi(ace,int(member.level))
   var mon: Dictionary=Mon.make(member.species,int(member.level),900000)
   if member.get("ability",mon.ability) not in Catalog.species(member.species).abilities:return false
   if member.has("moves"):
    if not member.moves is Array or member.moves.is_empty() or member.moves.size()>4:return false
    var moves: Array=[]
    for move: Variant in member.moves:
     if not move is String or Catalog.move(move).is_empty() or not Mon.legal_move(mon,move) or move in moves:return false
     moves.append(move)
  if int(entry.cap)!=ace:return false
 if caps[0]>caps[1] or caps[1]>caps[2] or caps[2]!=caps[3]:return false
 for place: Variant in v.encounters:
  var pool: Variant=v.encounters[place]
  if place not in ["canopy","springs"] or not pool is Dictionary or pool.get("method") not in ["grass","fishing"] or not Mon.integer(pool.get("minimum"),1,100) or not Mon.integer(pool.get("maximum"),int(pool.minimum),100):return false
  if not pool.get("bases") is Array or pool.bases.is_empty():return false
  for id: Variant in pool.bases:
   if not id is String or Catalog.species(id).is_empty():return false
 return true
func snapshot() -> Dictionary:return {"flags":flags.duplicate(),"visited":visited.duplicate(),"ceilings":ceilings.duplicate()}
static func validate(v: Variant) -> bool:
 if not v is Dictionary or not v.get("flags") is Dictionary or not v.get("visited") is Array:return false
 for id: Variant in v.flags:
  if id not in FLAGS or v.flags[id]!=true:return false
 if not v.get("ceilings",{}) is Dictionary:return false
 var awards: Dictionary={"demo-roadblock":"roadblock","demo-spring-keeper":"keeper","demo-post-a":"admin-a","demo-post-b":"admin-b"}
 for id: Variant in v.get("ceilings",{}):
  if id not in IDS or not Mon.integer(v.ceilings[id],10,100) or not v.flags.has(awards[id]):return false
 for id: String in awards:
  if v.flags.has(awards[id]) and not v.get("ceilings",{}).has(id):return false
 if v.get("ceilings",{}).has("demo-post-b") and v.ceilings["demo-post-b"]!=v.ceilings["demo-post-a"]:return false
 var f: Dictionary=v.flags
 var dependencies: Dictionary={"roadblock":["started"],"relay-west":["roadblock"],"relay-east":["roadblock"],"keeper":["relay-west","relay-east"],"admin-a":["keeper"],"admin-b":["admin-a"],"reported":["admin-b"],"surf-secret":["keeper"]}
 for id: String in dependencies:
  if f.has(id) and not dependencies[id].all(func(required: String):return f.has(required)):return false
 var seen: Array=[]
 for id: Variant in v.visited:
  if id not in LOCATIONS or id in seen or not f.has("roadblock"):return false
  if id=="springs" and not (f.has("relay-west") and f.has("relay-east")):return false
  if id=="post" and not f.has("keeper"):return false
  seen.append(id)
 return true
func restore(v: Dictionary) -> void:
 ceilings={}
 for id: String in v.get("ceilings",{}):ceilings[id]=int(v.ceilings[id])
 flags=v.flags.duplicate();visited=v.visited.duplicate();surfing=false
func begin(state: RefCounted) -> bool:
 if state.campaign.adventure.in_battle or state.location!="town" or not state.flags.has("complete") or not state.campaign.adventure.records.scenes.has("demo-return") or flags.has("started") or definitions().is_empty():return false
 flags.started=true;return true
func accessible(id: String) -> bool:
 if id=="canopy":return flags.has("roadblock")
 if id=="springs":return flags.has("relay-west") and flags.has("relay-east")
 if id=="post":return flags.has("keeper")
 return true
func can_enter(state: RefCounted,target: String,flight: bool=false) -> bool:
 if state.campaign.adventure.in_battle or not state.flags.has("complete") or not flags.has("started"):return false
 if flight:return target in visited and accessible(target)
 return target in ROUTES.get(state.location,[]) and accessible(target)
func relay(state: RefCounted,id: String) -> bool:
 if state.campaign.adventure.in_battle or state.location!="canopy" or not flags.has("roadblock") or id not in ["relay-west","relay-east"] or flags.has(id):return false
 flags[id]=true;return true
func can_battle(state: RefCounted,id: String,resolving: bool=false) -> bool:
 if (state.campaign.adventure.in_battle and not resolving) or not flags.has("started") or id not in IDS:return false
 var data: Dictionary=definitions().get("battles",{}).get(id,{})
 if data.is_empty() or state.location!=data.location or flags.has(data.flag):return false
 if id=="demo-roadblock":return state.flags.has("complete") and state.campaign.adventure.records.scenes.has("demo-canopy-briefing")
 if id=="demo-spring-keeper":return flags.has("relay-west") and flags.has("relay-east")
 if id=="demo-post-a":return flags.has("keeper")
 return flags.has("admin-a")
func opponents(state: RefCounted,id: String) -> Array:
 if not can_battle(state,id):return []
 var out: Array=[]
 for entry: Dictionary in definitions().battles[id].team:
  var mon: Dictionary=Mon.make(entry.species,int(entry.level),900000+out.size());mon.ability=entry.get("ability",mon.ability)
  if entry.has("moves"):
   mon.moves=[]
   for move: String in entry.moves:mon.moves.append({"id":move,"pp":Catalog.move(move).pp})
  out.append(mon)
 return out
func won(state: RefCounted,id: String) -> bool:
 if not can_battle(state,id,true):return false
 var data: Dictionary=definitions().battles[id];flags[data.flag]=true
 var tier: int=int(ceilings.get("demo-post-a",data.cap)) if id=="demo-post-b" else int(data.cap)
 ceilings[id]=tier;state.campaign.adventure.raise_cap(tier);state.campaign.adventure.money=mini(999999,state.campaign.adventure.money+int(data.money));return true
func can_surf(state: RefCounted) -> bool:return flags.has("keeper") and not state.campaign.adventure.in_battle
func secret(state: RefCounted) -> bool:
 var a: RefCounted=state.campaign.adventure
 if state.location!="canopy" or not can_surf(state) or flags.has("surf-secret") or int(a.bag.get("great-ball",0))+3>999:return false
 a.bag['great-ball']=int(a.bag.get('great-ball',0))+3;flags['surf-secret']=true;return true
func report(state: RefCounted) -> bool:
 if state.location!="town" or state.campaign.adventure.in_battle or not flags.has("admin-b") or flags.has("reported"):return false
 flags.reported=true;return true
func encounter(state: RefCounted) -> Dictionary:
 var a: RefCounted=state.campaign.adventure;var pool: Dictionary=definitions().get("encounters",{}).get(state.location,{})
 if a.in_battle or pool.is_empty() or not accessible(state.location):return {}
 var level: int=a.rng.randi_range(int(pool.minimum),int(pool.maximum));var base: String=pool.bases[a.rng.randi_range(0,pool.bases.size()-1)]
 return a.wild(level,Catalog.legal_species(base,level))
static func habitats(id: String) -> Array:
 var out: Array=[]
 for place: String in definitions().get("encounters",{}):
  var pool: Dictionary=definitions().encounters[place];var levels: Array=[]
  for base: String in pool.bases:
   for level: int in range(int(pool.minimum),int(pool.maximum)+1):
    if Catalog.legal_species(base,level)==id and level not in levels:levels.append(level)
  if not levels.is_empty():levels.sort();out.append({"place":place,"method":pool.method,"minimum":levels[0],"maximum":levels[-1],"level":levels[0]})
 return out
func objective(lang: String) -> String:
 var texts: Array
 if not flags.has("roadblock"):texts=["Affronte le contrôle RR au nord du sentier.","Battle the RR checkpoint north of the trail."]
 elif not flags.has("relay-west") or not flags.has("relay-east"):texts=["Réactive les deux relais de la canopée.","Reactivate both canopy relays."]
 elif not flags.has("keeper"):texts=["Rejoins les sources et affronte la championne.","Reach the springs and battle their champion."]
 elif not flags.has("admin-a"):texts=["Rejoins le poste de contrôle et affronte le premier responsable.","Reach the checkpoint and battle its first leader."]
 elif not flags.has("admin-b"):texts=["Affronte le second responsable RR au même palier.","Battle the second RR leader at the same level ceiling."]
 elif not flags.has("reported"):texts=["Retourne voir Vyna au havre pour faire ton rapport.","Return to Vyna in the haven to report."]
 else:texts=["Chapitre de démo terminé. Divinité et suite de l’île restent à construire.","Demo chapter complete. Divinity and remaining island still to be built."]
 return texts[0 if lang=="fr" else 1]

func target(state: RefCounted) -> String:
 var goal: Dictionary
 if not state.campaign.adventure.records.scenes.has("demo-canopy-briefing") or (flags.has("reported") and not state.campaign.adventure.records.scenes.has("demo-checkpoint-report")):goal={"place":"town","point":"vyna"}
 elif flags.has("reported"):return ""
 elif not flags.has("roadblock"):goal={"place":"trail","point":"roadblock"}
 elif not flags.has("relay-west"):goal={"place":"canopy","point":"relay-west"}
 elif not flags.has("relay-east"):goal={"place":"canopy","point":"relay-east"}
 elif not flags.has("keeper"):goal={"place":"springs","point":"spring-keeper"}
 elif not flags.has("admin-a"):goal={"place":"post","point":"post-a"}
 elif not flags.has("admin-b"):goal={"place":"post","point":"post-b"}
 else:goal={"place":"town","point":"vyna"}
 if state.location==goal.place:return goal.point
 if state.location in ["center","shop","home"]:return "exit"
 var queue: Array=[[state.location]];var seen: Array=[state.location]
 while not queue.is_empty():
  var route: Array=queue.pop_front()
  for next: String in ROUTES.get(route[-1],[]):
   if next in seen:continue
   var path: Array=route+[next]
   if next==goal.place:
    if state.location=="town":return "gate"
    if state.location=="trail" and path[1]=="town":return "exit"
    return "go-"+path[1]
   seen.append(next);queue.append(path)
 return ""
func tasks(lang: String) -> Array:
 var labels: Array=["Passer le contrôle RR","Réactiver le relais ouest","Réactiver le relais est","Vaincre la championne des sources","Premier responsable RR","Second responsable RR — même palier","Rapport à Vyna"] if lang=="fr" else ["Pass the RR checkpoint","Restore west relay","Restore east relay","Defeat the spring champion","First RR leader","Second RR leader — shared ceiling","Report to Vyna"]
 var ids: Array=["roadblock","relay-west","relay-east","keeper","admin-a","admin-b","reported"];var out: Array=[]
 for i: int in range(ids.size()):out.append({"text":labels[i],"done":flags.has(ids[i])})
 return out

static func is_water(place: String,at: Vector2) -> bool:
 if place=="town":return at.x>9 and at.x<18 and at.y>8 and at.y<=15 and not (at.x>10 and at.x<12) # Preserve the original shoreline and dry dock.
 return place in WATERS and WATERS[place].has_point(at)
static func at_shore(place: String,at: Vector2) -> bool:
 if place not in WATERS or is_water(place,at) or not WATERS[place].grow(.6).has_point(at):return false
 if place=="town" and WATERS[place].has_point(at):return minf(absf(at.x-10),absf(at.x-12))<=.6
 return true
