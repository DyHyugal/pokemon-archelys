extends RefCounted
## SPOILERS DEV — original proposed island, no final names, casting or balance.
const Mon=preload("res://scripts/domain/pokemon.gd")
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
const LOCATIONS=["isle-port","isle-jungle","isle-caldera","isle-cave","isle-shrine","isle-base","isle-center","isle-shop"]
const NAMES={"isle-port":["Havre tropical","Tropical haven"],"isle-jungle":["Canopée des relais","Relay canopy"],"isle-caldera":["Caldeira des vents","Wind caldera"],"isle-cave":["Galerie de basalte","Basalt gallery"],"isle-shrine":["Sanctuaire des sources","Spring sanctuary"],"isle-base":["Poste RR occupé","Occupied RR outpost"],"isle-center":["Centre du havre","Haven Center"],"isle-shop":["Boutique du havre","Haven shop"]}
const ROUTES={"isle-port":["isle-center","isle-shop","isle-jungle","village"],"isle-center":["isle-port"],"isle-shop":["isle-port"],"isle-jungle":["isle-port","isle-caldera","isle-shrine"],"isle-shrine":["isle-jungle"],"isle-caldera":["isle-jungle","isle-cave"],"isle-cave":["isle-caldera","isle-base"],"isle-base":["isle-cave"]}
const POSITIONS={"isle-port":[Vector3(-8,0,0),Vector3(8,0,0),Vector3(0,0,-9),Vector3(0,0,9)],"isle-center":[Vector3(0,0,9)],"isle-shop":[Vector3(0,0,9)],"isle-jungle":[Vector3(0,0,9),Vector3(0,0,-9),Vector3(12,0,0)],"isle-shrine":[Vector3(0,0,9)],"isle-caldera":[Vector3(0,0,9),Vector3(0,0,-9)],"isle-cave":[Vector3(0,0,9),Vector3(0,0,-9)],"isle-base":[Vector3(0,0,9)]}
const POOLS={"isle-jungle":["bulbasaur","pikachu","rattata"],"isle-caldera":["vulpix","charmander"],"isle-cave":["kabuto","omanyte"]}
const FLAGS=["started","checkpoint","relay-west","relay-east","keeper","admin-a","admin-b","liberated","quest","gift"]
const CACHES={"port-cache":{"location":"isle-port","items":{"poke-ball":5}},"jungle-cache":{"location":"isle-jungle","items":{"potion":2}},"cave-cache":{"location":"isle-cave","items":{"great-ball":3}}}
const SAMPLES={"sample-a":Vector3(-8,0,-5),"sample-b":Vector3(8,0,-5),"sample-c":Vector3(7,0,5)}
const BATTLES={"isle-checkpoint":{"location":"isle-port","species":["rattata","pikachu"],"levels":[10,12],"cap":14,"flag":"checkpoint"},"isle-keeper":{"location":"isle-shrine","species":["vulpix","bulbasaur","squirtle"],"levels":[16,16,18],"cap":18,"flag":"keeper"},"isle-admin-a":{"location":"isle-base","species":["raticate","charmeleon"],"levels":[20,22],"cap":22,"flag":"admin-a"},"isle-admin-b":{"location":"isle-base","species":["raichu","wartortle"],"levels":[20,22],"cap":22,"flag":"admin-b"}}
var flags: Dictionary={}
var collected: Dictionary={}
var caches: Dictionary={}
static func name_of(location: String,lang: String) -> String:return NAMES.get(location,[location,location])[0 if lang=="fr" else 1]
func snapshot() -> Dictionary:return {"flags":flags.duplicate(),"collected":collected.duplicate(),"caches":caches.duplicate()}
static func validate(value: Variant) -> bool:
 if not value is Dictionary:return false
 for field: String in ["flags","collected","caches"]:
  if not value.get(field) is Dictionary:return false
  var keys: Array=FLAGS if field=="flags" else (SAMPLES.keys() if field=="collected" else CACHES.keys())
  for key: Variant in value[field]:
   if key not in keys or value[field][key]!=true:return false
 var f: Dictionary=value.flags
 if not f.has("started") and (not f.is_empty() or not value.collected.is_empty() or not value.caches.is_empty()):return false
 if f.has("keeper") and not (f.has("checkpoint") and f.has("relay-west") and f.has("relay-east")):return false
 if f.has("admin-a") and not f.has("keeper"):return false
 if f.has("admin-b") and not f.has("admin-a"):return false
 if f.has("liberated") and not f.has("admin-b"):return false
 if f.has("gift") and (not f.has("quest") or value.collected.size()!=3):return false
 if not value.collected.is_empty() and not f.has("quest"):return false
 return true
func restore(value: Dictionary) -> void:flags=value.flags.duplicate();collected=value.collected.duplicate();caches=value.caches.duplicate()
func start(owner: RefCounted) -> bool:
 if owner.in_battle or owner.exploration.nuzlocke=="on" or not owner.initialized or flags.has("started"):return false
 flags.started=true;return true
func can_enter(owner: RefCounted,target: String,flight: bool=false) -> bool:
 var current: String=owner.exploration.location
 if target not in LOCATIONS:
  return (target=="village" and (target in ROUTES[current] if not flight else owner.exploration.field_unlocked("fly",owner.victories))) if current in LOCATIONS else true
 if not flags.has("started"):return false
 if flight:return flags.has("liberated") and target in owner.exploration.visited and target not in ["isle-center","isle-shop"]
 if current not in LOCATIONS:return target=="isle-port"
 if target not in ROUTES[current]:return false
 if target=="isle-jungle":return owner.records.scenes.has("isle-arrival") and flags.has("checkpoint")
 if target in ["isle-caldera","isle-shrine"]:return flags.has("relay-west") and flags.has("relay-east")
 if target in ["isle-cave","isle-base"]:return flags.has("keeper")
 return true
func collect(owner: RefCounted,id: String) -> bool:
 if owner.in_battle or owner.exploration.location!="isle-jungle" or not flags.has("quest") or id not in SAMPLES or collected.has(id):return false
 collected[id]=true;return true
func relay(owner: RefCounted,id: String) -> bool:
 if owner.in_battle or not flags.has("checkpoint") or owner.exploration.location!="isle-jungle" or id not in ["relay-west","relay-east"] or flags.has(id):return false
 flags[id]=true;return true
func accept_quest(owner: RefCounted) -> bool:
 if owner.in_battle or owner.exploration.location!="isle-port" or not flags.has("started") or flags.has("quest"):return false
 flags.quest=true;return true
func gift(owner: RefCounted) -> String:
 if owner.in_battle or owner.exploration.location!="isle-port" or not flags.has("quest") or flags.has("gift") or collected.size()!=3:return "unavailable"
 if owner.team.size()+owner.boxes.size()>=246:return "full"
 var result: String=owner.add(Mon.make("pikachu",8,owner.next_uid))
 if result in ["team","pc"]:flags.gift=true
 return result
func cache(owner: RefCounted,id: String) -> bool:
 if owner.in_battle or id not in CACHES or caches.has(id) or not flags.has("started") or owner.exploration.location!=CACHES[id].location:return false
 var items: Dictionary=CACHES[id].items
 for item: String in items:
  if int(owner.bag.get(item,0))+int(items[item])>999:return false
 for item: String in items:owner.bag[item]=int(owner.bag.get(item,0))+int(items[item])
 caches[id]=true;return true
func can_battle(owner: RefCounted,id: String) -> bool:
 if owner.in_battle or not flags.has("started") or id not in BATTLES or flags.has(BATTLES[id].flag) or owner.exploration.location!=BATTLES[id].location:return false
 match id:
  "isle-checkpoint":return owner.records.scenes.has("isle-arrival")
  "isle-keeper":return flags.has("relay-west") and flags.has("relay-east")
  "isle-admin-a":return flags.has("keeper")
  "isle-admin-b":return flags.has("admin-a")
 return false
func opponents(owner: RefCounted,id: String) -> Array:
 if not can_battle(owner,id):return []
 var result: Array=[];var data: Dictionary=BATTLES[id]
 for i: int in range(data.species.size()):
  var level: int=int(data.levels[i]);var species: String=Catalog.legal_species(data.species[i],level)
  var mon: Dictionary=Mon.make(species,level,900000+i)
  if id=="isle-keeper" and i==0:mon.ability="drought"
  if id=="isle-keeper" and i==1:mon.ability="chlorophyll"
  result.append(mon)
 return result
func won(owner: RefCounted,id: String) -> bool:
 if id not in BATTLES or flags.has(BATTLES[id].flag):return false
 # Validate story dependencies without trusting a forged battle completion.
 var was: bool=owner.in_battle;owner.in_battle=false
 var allowed: bool=can_battle(owner,id);owner.in_battle=was
 if not allowed:return false
 flags[BATTLES[id].flag]=true;owner.raise_cap(int(BATTLES[id].cap));owner.money=mini(999999,owner.money+300);return true
func liberate(owner: RefCounted) -> bool:
 if owner.in_battle or not flags.has("admin-b") or flags.has("liberated") or not owner.records.scenes.has("isle-liberation"):return false
 flags.liberated=true;return true
func objective(lang: String) -> String:
 var fr: String="";var en: String=""
 if not flags.has("started"):fr="Ouvrir le prototype d'île depuis Aventure.";en="Open the island prototype from Adventure."
 elif not flags.has("checkpoint"):fr="Parler à Vyna au havre, regarder l'arrivée, puis libérer le contrôle RR.";en="Talk to Vyna, watch arrival, then defeat the RR checkpoint."
 elif not flags.has("relay-west") or not flags.has("relay-east"):fr="Dans la jungle, réactiver les deux relais (ouest et est).";en="In the jungle, reactivate the west and east relays."
 elif not flags.has("keeper"):fr="Rejoindre le sanctuaire à l'est et vaincre le gardien proposé.";en="Reach the eastern sanctuary and defeat the proposed keeper."
 elif not flags.has("admin-a"):fr="Traverser la caldeira et la galerie ; affronter le premier admin RR.";en="Cross the caldera and gallery; defeat the first RR admin."
 elif not flags.has("admin-b"):fr="Le second admin attend dans le même poste. Palier commun22.";en="The second admin waits in the same outpost. Shared ceiling22."
 elif not flags.has("liberated"):fr="Regarder la libération depuis Aventure, puis explorer l'île libérée.";en="Watch liberation from Adventure, then explore the freed island."
 else:fr="Île proposée terminée. Vol disponible vers ses lieux déjà visités ; quête botaniste facultative.";en="Proposed island complete. Fly to visited island locations; optional botanist quest."
 return fr if lang=="fr" else en
func dialogue(id: String,lang: String) -> Dictionary:
 var fr: Array=[];var en: Array=[];var who: String=""
 match id:
  "vyna":who="Vyna — proposition";fr=["Ces relais alimentaient le village. RR détourne leur énergie vers le poste de la caldeira.",objective("fr")];en=["These relays powered the village. RR diverts their energy to the caldera outpost.",objective("en")]
  "resident":who="Habitant / Resident";fr=["Les barrières sont tombées. Nous pouvons réparer le port." if flags.has("liberated") else "Le poste RR bloque les livraisons. Les premiers secours restent accessibles."];en=["The barriers are down. We can repair the port." if flags.has("liberated") else "RR blocks deliveries. First aid is still available."]
  "botanist":who="Botaniste / Botanist";fr=["Trois plantes balisent les anciens relais. Rapporte leurs relevés ; un compagnon d'essai t'attend.","Relevés : %d / 3. Le cadeau n'est donné qu'une fois." % collected.size()];en=["Three plants mark the old relays. Bring their surveys; a test companion awaits.","Surveys: %d / 3. The gift is only given once." % collected.size()]
 if id=="botanist" and flags.has("gift"):
  fr.append("Merci ! Le compagnon a déjà rejoint ton équipe ou ton PC.");en.append("Thank you! The companion already joined your party or PC.")
 return {lang:{"speaker":who,"lines":fr if lang=="fr" else en}}
static func points(location: String) -> Dictionary:
 var result: Dictionary={}
 if location not in LOCATIONS:return result
 for i: int in range(ROUTES[location].size()):result["i-go-"+ROUTES[location][i]]=POSITIONS[location][i]
 match location:
  "isle-port":result.merge({"i-vyna":Vector3(3,0,3),"i-resident":Vector3(-4,0,4),"i-botanist":Vector3(7,0,4),"i-isle-checkpoint":Vector3(3,0,-6),"i-port-cache":Vector3(-10,0,6)})
  "isle-center":result["i-nurse"]=Vector3(0,0,-3)
  "isle-shop":result["i-counter"]=Vector3(0,0,-3)
  "isle-jungle":
   result.merge({"i-relay-west":Vector3(-6,0,0),"i-relay-east":Vector3(6,0,0),"i-jungle-cache":Vector3(-10,0,5)})
   for id: String in SAMPLES:result["i-"+id]=SAMPLES[id]
  "isle-cave":result["i-cave-cache"]=Vector3(-6,0,-2)
  "isle-shrine":result["i-isle-keeper"]=Vector3(0,0,-4)
  "isle-base":result.merge({"i-isle-admin-a":Vector3(-4,0,-4),"i-isle-admin-b":Vector3(4,0,-4)})
 return result
static func walkable(pos: Vector2,location: String) -> bool:
 if absf(pos.x)>14 or absf(pos.y)>10:return false
 if location=="isle-port":
  for x: int in [-8,8]:
   if absf(pos.x-x)<2.1 and absf(pos.y+3)<1.8:return false
 if location=="isle-jungle":
  for x: int in [-11,11]:
   for z: int in [-7,7]:
    if pos.distance_to(Vector2(x,z))<0.8:return false
 for id: String in points(location):
  if id in ["i-vyna","i-resident","i-botanist","i-isle-checkpoint","i-isle-keeper","i-isle-admin-a","i-isle-admin-b"] and pos.distance_to(Vector2(points(location)[id].x,points(location)[id].z))<0.4:return false
 if location=="isle-caldera" and pos.distance_to(Vector2(0,0))<3.4:return false
 if location=="isle-cave" and absf(pos.x)>9:return false
 return true
static func grass(pos: Vector3,location: String) -> bool:
 return location in ["isle-jungle","isle-caldera","isle-cave"] and pos.x>=-9 and pos.x<=-3 and pos.z>=-7 and pos.z<=-4
static func wild(owner: RefCounted) -> Dictionary:
 var pool: Array=POOLS.get(owner.exploration.location,[])
 if pool.is_empty():return {}
 var level: int=mini(owner.cap,14 if owner.exploration.location=="isle-jungle" else 18)
 return owner.wild(maxi(8,level),pool[owner.rng.randi_range(0,pool.size()-1)])
