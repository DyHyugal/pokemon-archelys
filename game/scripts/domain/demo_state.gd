extends RefCounted
const Campaign=preload("res://scripts/domain/campaign.gd")
const Mon=preload("res://scripts/domain/pokemon.gd")
const Records=preload("res://scripts/domain/journey_records.gd")
const STARTERS=["bulbasaur","charmander","squirtle"]
const LOCATIONS=["town","trail","center","shop","home"]
var campaign:=Campaign.new()
var starter: String=""
var location: String="town"
var position:=Vector3(0,0,10)
var flags: Dictionary={}
func _init() -> void:
 campaign.add_player(1,"Démo");campaign.adventure.initialize();campaign.adventure.island.start(campaign.adventure)
func choose(id: String) -> bool:
 if id not in STARTERS or not starter.is_empty() or campaign.adventure.in_battle:return false
 var a: RefCounted=campaign.adventure
 a.team=[];a.boxes=[];a.storage_slots={};a.next_uid=1;a.pending=[];a.records=Records.new()
 a.bag={"poke-ball":8,"potion":4,"lucky-egg":1};a.money=600;a.cap=10
 a.add(Mon.make(id,6,1));starter=id;a.exploration.location="isle-port"
 if "isle-port" not in a.exploration.visited:a.exploration.visited.append("isle-port")
 return true
func travel(id: String) -> bool:
 if id not in LOCATIONS or starter.is_empty() or campaign.adventure.in_battle:return false
 location=id;position=Vector3(0,0,10) if id=="town" else Vector3(0,0,9)
 campaign.adventure.exploration.location={"town":"isle-port","trail":"isle-jungle","center":"isle-center","shop":"isle-shop","home":"isle-port"}[id]
 if campaign.adventure.exploration.location not in campaign.adventure.exploration.visited:campaign.adventure.exploration.visited.append(campaign.adventure.exploration.location)
 return true
func snapshot() -> Dictionary:
 return {"format":"archelys-demo-1","campaign":campaign.snapshot(),"starter":starter,"location":location,"position":[position.x,position.y,position.z],"flags":flags.duplicate()}
static func validate(v: Variant) -> bool:
 if not v is Dictionary or v.get("format")!="archelys-demo-1" or v.get("starter") not in STARTERS or v.get("location") not in LOCATIONS or not v.get("flags") is Dictionary:return false
 if not v.get("campaign") is Dictionary or not Campaign.validate(v.campaign) or int(v.campaign.participants)!=1:return false
 if not v.get("position") is Array or v.position.size()!=3:return false
 for x: Variant in v.position:
  if (not x is int and not x is float) or not is_finite(float(x)) or absf(float(x))>50:return false
 if float(v.position[1])!=0:return false
 var x: float=float(v.position[0]);var z: float=float(v.position[2])
 if v.location=="town" and (x< -25 or x>25 or z< -24 or z>15):return false
 if v.location=="trail" and (absf(x)>14 or z< -18 or z>13):return false
 if v.location in ["center","shop","home"] and (absf(x)>8.5 or absf(z)>9.5):return false
 if v.campaign.adventure.exploration.location!={"town":"isle-port","trail":"isle-jungle","center":"isle-center","shop":"isle-shop","home":"isle-port"}[v.location]:return false
 for id: Variant in v.flags:
  if id not in ["trainer","survey","supplies","complete"] or v.flags[id]!=true:return false
 if v.flags.has("complete") and not (v.flags.has("trainer") and v.flags.has("survey")):return false
 return true
func restore(v: Dictionary) -> bool:
 if not validate(v):return false
 var c:=Campaign.new()
 if not c.restore(v.campaign):return false
 campaign=c;starter=v.starter;location=v.location;position=Vector3(v.position[0],0,v.position[2]);flags=v.flags.duplicate();return true
func save(path: String) -> Error:
 if starter.is_empty() or campaign.adventure.in_battle:return ERR_BUSY
 var v:=snapshot()
 if not validate(v):return ERR_INVALID_DATA
 var f:=FileAccess.open(path+".tmp",FileAccess.WRITE)
 if not f:return FileAccess.get_open_error()
 f.store_string(JSON.stringify(v));f.flush();f.close()
 var check: Variant=JSON.parse_string(FileAccess.get_file_as_string(path+".tmp"))
 if not validate(check):return ERR_INVALID_DATA
 if FileAccess.file_exists(path):
  var previous:=JSON.new()
  # A corrupt primary must never replace a valid recovery copy.
  if previous.parse(FileAccess.get_file_as_string(path))==OK and validate(previous.data):
   var error: int=DirAccess.copy_absolute(path,path+".backup")
   if error!=OK:return error
 return DirAccess.rename_absolute(path+".tmp",path)
func objective(lang: String) -> String:
 if flags.has("complete"):return "Démo terminée : explore et prépare ton équipe." if lang=="fr" else "Demo complete: explore and prepare your party."
 var index: int=0 if starter.is_empty() else (1 if not flags.has("survey") else (2 if not flags.has("trainer") else 3))
 return ["Choisis ton premier Pokémon.","Parle à Vyna, puis relève la balise du sentier.","Affronte le dresseur du sentier ; soins et boutique au havre.","Retourne voir Vyna au havre pour conclure la démo."][index] if lang=="fr" else ["Choose your first Pokémon.","Talk to Vyna, then survey the trail beacon.","Battle the trail trainer; healing and shop in town.","Return to Vyna in town to finish the demo."][index]
