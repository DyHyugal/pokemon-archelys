extends RefCounted
## Presentation only: consumes the player's public Showdown protocol, never sets.
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
const STATUS={"brn":"burn","par":"paralysis","slp":"sleep","frz":"freeze","psn":"poison","tox":"toxic"}
const STATS={"atk":["Attaque","Attack"],"def":["Défense","Defense"],"spa":["Attaque Spéciale","Special Attack"],"spd":["Défense Spéciale","Special Defense"],"spe":["Vitesse","Speed"],"accuracy":["Précision","Accuracy"],"evasion":["Esquive","Evasion"]}
const FIELDS={"SunnyDay":["soleil","sun"],"RainDance":["pluie","rain"],"Sandstorm":["tempête de sable","sandstorm"],"Snow":["neige","snow"],"Hail":["grêle","hail"],"Electric Terrain":["terrain électrique","Electric Terrain"],"Grassy Terrain":["terrain herbu","Grassy Terrain"],"Misty Terrain":["terrain brumeux","Misty Terrain"],"Psychic Terrain":["terrain psychique","Psychic Terrain"]}
static func phrase(fr: String,en: String,lang: String) -> String:return fr if lang=="fr" else en
static func effect(value: String,lang: String) -> String:
 var clean: String=value.trim_prefix("move: ").trim_prefix("ability: ").trim_prefix("item: ")
 for group: String in ["moves","items","abilities"]:
  for id: String in Catalog.data()[group]:
   var entry: Dictionary=Catalog.data()[group][id]
   var names: Dictionary=entry.get("names",entry)
   if names.get("en","")==clean:return str(names.get(lang,clean))
 return clean
static func actor(value: String,roster: Array,lang: String) -> String:
 if not value.begins_with("p1") and not value.begins_with("p2"):return ""
 var token: String=value.get_slice(": ",1)
 if token.is_valid_int():
  for mon: Dictionary in roster:
   if int(mon.uid)==int(token):return Catalog.name_of(mon.species,lang)
 return phrase("Le Pokémon","The Pokémon",lang)
static func format_line(line: String,roster: Array) -> Dictionary:
 var parts:=line.split("|")
 if parts.size()<3:return {}
 var result: Dictionary={}
 for lang: String in ["fr","en"]:
  var who: String=actor(parts[2],roster,lang)
  var arg: String=parts[3] if parts.size()>3 else ""
  var text: String=""
  match parts[1]:
   "move":
    if arg.is_empty():continue
    text=phrase("%s utilise %s.","%s used %s.",lang) % [who,effect(arg,lang)]
   "switch","drag":text=phrase("%s entre en combat.","%s entered the battle.",lang) % who
   "faint":text=phrase("%s est K.O.","%s fainted.",lang) % who
   "-mega":text=phrase("%s méga-évolue !","%s Mega Evolved!",lang) % who
   "-damage","-heal":
    if arg.is_empty():continue
    var remaining: String=arg.get_slice(" ",0)
    if parts[2].begins_with("p2") and remaining.get_slice("/",1)=="100":remaining=remaining.get_slice("/",0)+"%"
    text=phrase("%s subit des dégâts. PV restants : %s.","%s took damage. Remaining HP: %s.",lang) % [who,remaining] if parts[1]=="-damage" else phrase("%s récupère des PV. PV restants : %s.","%s recovered HP. Remaining HP: %s.",lang) % [who,remaining]
   "-status","-curestatus":
    var status: String=Catalog.text("status_names",STATUS.get(arg,arg),lang)
    text=phrase("%s : %s.","%s: %s.",lang) % [who,status] if parts[1]=="-status" else phrase("%s ne souffre plus de %s.","%s recovered from %s.",lang) % [who,status]
   "cant":
    var reasons: Dictionary={"slp":["dort","is asleep"],"frz":["est gelé","is frozen"],"par":["est paralysé","is paralyzed"],"flinch":["est apeuré","flinched"],"recharge":["doit se recharger","must recharge"],"nopp":["n'a plus de PP","has no PP left"]}
    var why: Array=reasons.get(arg,["ne peut pas agir","cannot act"])
    text=phrase("%s %s ; aucune attaque.","%s %s; no attack.",lang) % [who,why[0 if lang=="fr" else 1]]
   "-boost","-unboost":
    if parts.size()<5 or not parts[4].is_valid_int():continue
    var stat: Array=STATS.get(arg,[arg,arg])
    text=phrase("%s : %s %s de %s cran(s).","%s: %s %s by %s stage(s).",lang) % [who,stat[0 if lang=="fr" else 1],phrase("augmente","rises",lang) if parts[1]=="-boost" else phrase("diminue","falls",lang),parts[4]]
   "-clearboost":text=phrase("Les modifications de statistiques de %s sont annulées.","%s's stat changes were reset.",lang) % who
   "-clearallboost":text=phrase("Toutes les modifications de statistiques sont annulées.","All stat changes were reset.",lang)
   "-weather","-fieldstart","-fieldend":
    var value: String=parts[2].trim_prefix("move: ")
    var field: Array=FIELDS.get(value,[effect(value,"fr"),effect(value,"en")])
    if value=="none":text=phrase("Le climat prend fin.","The weather ended.",lang)
    else:
     var ending: bool=parts[1]=="-fieldend"
     var ongoing: bool=parts.size()>3 and parts[3]=="[upkeep]"
     text=phrase("Fin du %s.","%s ended.",lang) % field[0 if lang=="fr" else 1] if ending else (phrase("Le %s se poursuit.","%s continues.",lang) if ongoing else phrase("Le %s s'installe.","%s started.",lang)) % field[0 if lang=="fr" else 1]
   "-crit":text=phrase("Coup critique sur %s !","A critical hit on %s!",lang) % who
   "-supereffective":text=phrase("C'est super efficace sur %s !","It's super effective on %s!",lang) % who
   "-resisted":text=phrase("Ce n'est pas très efficace sur %s…","It's not very effective on %s…",lang) % who
   "-immune":text=phrase("Cela n'affecte pas %s.","It doesn't affect %s.",lang) % who
   "-miss":text=phrase("L'attaque de %s manque sa cible.","%s's attack missed.",lang) % who
   "-fail":text=phrase("L'action de %s échoue.","%s's action failed.",lang) % who
   "-prepare":text=phrase("%s prépare %s.","%s is preparing %s.",lang) % [who,effect(arg,lang)]
   "-ability":text=phrase("Talent révélé de %s : %s.","%s's revealed ability: %s.",lang) % [who,effect(arg,lang)]
   "-item","-enditem":text=phrase("Objet de %s : %s.","%s's item: %s.",lang) % [who,effect(arg,lang)] if parts[1]=="-item" else phrase("%s consomme ou perd %s.","%s consumed or lost %s.",lang) % [who,effect(arg,lang)]
   "-activate","-start","-end","-singleturn","-singlemove":
    var descriptions: Dictionary={"confusion":["confusion","confusion"],"Substitute":["Clonage","Substitute"],"trapped":["piège","trapping"],"partiallytrapped":["piège persistant","partial trapping"]}
    var name: String=effect(arg,lang)
    if descriptions.has(arg):name=descriptions[arg][0 if lang=="fr" else 1]
    text=phrase("%s : fin de %s.","%s: %s ended.",lang) % [who,name] if parts[1]=="-end" else phrase("%s : %s s'active.","%s: %s activated.",lang) % [who,name]
  if text.is_empty():return {}
  result[lang]=text
 return result
