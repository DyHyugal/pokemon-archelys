extends RefCounted
## Playable proposed opening, independent of final island/casting choices.
const ORDER=["briefing","trail","beacon","boss","ending"]
var flags: Dictionary={}
func snapshot() -> Dictionary:return {"flags":flags.duplicate()}
static func validate(value: Variant) -> bool:
	if not value is Dictionary or not value.get("flags") is Dictionary:return false
	for key: Variant in value.flags:
		if key not in ORDER or value.flags[key]!=true:return false
	for i: int in range(1,ORDER.size()):
		if value.flags.has(ORDER[i]) and not value.flags.has(ORDER[i-1]):return false
	return true
func restore(value: Dictionary) -> void:flags=value.flags.duplicate()
func begin(owner: RefCounted) -> bool:
	if owner.in_battle or not owner.initialized or owner.exploration.location!="village" or flags.has("briefing"):return false
	if not owner.grant_items({"poke-ball":5,"potion":3}):return false
	flags.briefing=true;return true
func can_enter(owner: RefCounted,target: String) -> bool:
	if target=="trail":return flags.has("briefing") and owner.records.scenes.has("slice-prologue")
	if target=="trial":return flags.has("beacon")
	return true
func entered(target: String) -> void:
	if target=="trail" and flags.has("briefing"):flags.trail=true
func beacon(owner: RefCounted) -> bool:
	if owner.in_battle or owner.exploration.location!="trail" or not flags.has("trail") or flags.has("beacon"):return false
	flags.beacon=true;return true
func won(owner: RefCounted,id: String) -> bool:
	if id!="slice-boss" or not flags.has("beacon") or flags.has("boss"):return false
	flags.boss=true;owner.raise_cap(18);owner.money=mini(999999,owner.money+500);return true
func finish(owner: RefCounted) -> bool:
	if not flags.has("boss") or flags.has("ending") or not owner.records.scenes.has("slice-ending"):return false
	flags.ending=true;return true
func objective(language: String="fr") -> String:
	var index:=0
	while index<ORDER.size() and flags.has(ORDER[index]):index+=1
	var fr=["Commencer le prologue depuis le menu Aventure.","Terminer le prologue, puis rejoindre le sentier au nord du village.","Activer la balise du sentier (à l'est).","Rejoindre l'épreuve au nord et vaincre son gardien d'essai.","Consulter la scène de conclusion depuis le menu Aventure.","Parcours terminé : explorer, compléter le Pokédex et préparer l'équipe."]
	var en=["Start the prologue from the Adventure menu.","Finish the prologue, then enter the trail north of the village.","Activate the trail beacon (east side).","Reach the northern trial and defeat its test keeper.","Watch the ending from the Adventure menu.","Journey complete: explore, fill the Pokédex and prepare your party."]
	return (fr if language=="fr" else en)[index]
