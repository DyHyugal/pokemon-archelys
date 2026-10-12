extends RefCounted
## Bounded laboratory geography. Story unlocks are test placeholders.
const Island=preload("res://scripts/domain/island.gd")
const Mon=preload("res://scripts/domain/pokemon.gd")
const PRICES={"poke-ball":200,"great-ball":600,"potion":200,"antidote":200,"paralyze-heal":200,"oran-berry":80,"thunder-stone":3000,"fire-stone":3000}
static var LOCATIONS: Array=["village","center","shop","cove","district","trail","trial"]+Island.LOCATIONS
var location: String="village"
var visited: Array=["village"]
var cleared: Dictionary={}
var difficulty: String="normal"
var battle_style: String="set"
var bag_healing: bool=true
var cap_enabled: bool=true
var nuzlocke: String="off" # off -> on -> retired; never re-enabled
var claims: Dictionary={}
var dead: Array=[]
var shiny_odds: int=4096
var exp_multiplier: int=1
func snapshot() -> Dictionary:
	return {"location":location,"visited":visited.duplicate(),"cleared":cleared.duplicate(),"difficulty":difficulty,"battle_style":battle_style,"bag_healing":bag_healing,"cap_enabled":cap_enabled,"nuzlocke":nuzlocke,"claims":claims.duplicate(true),"dead":dead.duplicate(),"exp_multiplier":exp_multiplier,"shiny_odds":shiny_odds}
static func validate(data: Variant) -> bool:
	if not data is Dictionary or not Mon.integer(data.get("shiny_odds"),1,4096):return false
	if data.get("battle_style","set") not in ["set","shift"] or not data.get("bag_healing",true) is bool:return false
	if data.get("location") not in LOCATIONS or not data.get("visited") is Array or data.location not in data.visited or data.visited.size()>LOCATIONS.size():return false
	var seen: Array=[]
	for id: Variant in data.visited:
		if id not in LOCATIONS or id in seen:return false
		seen.append(id)
	if data.get("difficulty") not in ["chill","normal","hard"] or not data.get("cap_enabled") is bool or data.get("nuzlocke") not in ["off","on","retired"]:return false
	if not data.get("cleared") is Dictionary or not data.get("claims") is Dictionary or not data.get("dead") is Array or not Mon.integer(data.get("exp_multiplier"),1,5):return false
	for key: Variant in data.cleared:
		if key not in ["cut","rock-smash","strength","climb","surf"] or data.cleared[key]!=true:return false
	for key: Variant in data.claims:
		if key not in LOCATIONS or not data.claims[key] is Dictionary or data.claims[key].get("result") not in ["reserved","caught","failed"] or not Mon.integer(data.claims[key].get("uid"),1,1000000):return false
	seen=[]
	for uid: Variant in data.dead:
		if not Mon.integer(uid,1,1000000) or uid in seen:return false
		seen.append(uid)
	return true
func restore(data: Dictionary) -> bool:
	if not validate(data):return false
	location=data.location;visited=data.visited.duplicate();cleared=data.cleared.duplicate();difficulty=data.difficulty;cap_enabled=data.cap_enabled;nuzlocke=data.nuzlocke;claims=data.claims.duplicate(true);dead=[];exp_multiplier=int(data.exp_multiplier);shiny_odds=int(data.shiny_odds)
	battle_style=data.get("battle_style","set");bag_healing=data.get("bag_healing",true)
	for uid: Variant in data.dead:dead.append(int(uid))
	for claim: Dictionary in claims.values():claim.uid=int(claim.uid)
	return true
func enter(target: String) -> bool:
	if target not in LOCATIONS:return false
	location=target
	cleared.erase("surf")
	if target not in visited:visited.append(target)
	return true
func field_unlocked(action: String, victories: Dictionary) -> bool:
	if action in ["flash","fish","cut","rock-smash"]:return true # early laboratory flag
	if action in ["surf","strength","fly","climb"]:return victories.has("trainer-1")
	return false
func enable_challenge() -> bool:
	if nuzlocke!="off":return false
	nuzlocke="on";return true
func retire_challenge() -> bool:
	if nuzlocke!="on":return false
	nuzlocke="retired";return true
func record_deaths(team: Array) -> void:
	if nuzlocke!="on":return
	for mon: Dictionary in team:
		if mon.hp==0 and mon.uid not in dead:dead.append(int(mon.uid))
func can_heal(mon: Dictionary) -> bool:return nuzlocke!="on" or mon.uid not in dead
func game_over(team: Array, boxes: Array) -> bool:
	return nuzlocke=="on" and not (team+boxes).any(func(mon: Dictionary):return mon.uid not in dead)
func reserve_encounter(zone: String, uid: int) -> bool:
	if nuzlocke!="on":return true
	if claims.has(zone):return false
	claims[zone]={"result":"reserved","uid":uid};return true
func may_capture(zone: String, uid: int) -> bool:
	return nuzlocke!="on" or (claims.has(zone) and claims[zone].result=="reserved" and int(claims[zone].uid)==uid)
func settle_encounter(zone: String, uid: int, caught: bool) -> void:
	if nuzlocke=="on" and may_capture(zone,uid):claims[zone].result="caught" if caught else "failed"
