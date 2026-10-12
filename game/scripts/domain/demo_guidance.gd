extends RefCounted
static func target(state: RefCounted) -> String:
 if state.chapter.flags.has("started"):return state.chapter.target(state)
 if state.starter.is_empty() or state.flags.has("complete"):return ""
 if not state.flags.has("survey"):return "survey" if state.location=="trail" else ("gate" if state.location=="town" else "exit")
 if not state.flags.has("trainer"):return "trainer" if state.location=="trail" else ("gate" if state.location=="town" else "exit")
 return "vyna" if state.location=="town" else "exit"
static func title(id: String,lang: String) -> String:
 if id.begins_with("go-"):return preload("res://scripts/domain/demo_chapter.gd").name_of(id.trim_prefix("go-"),lang)
 var fr={"roadblock":"Contrôle RR","relay-west":"Relais ouest","relay-east":"Relais est","spring-keeper":"Championne","post-a":"Responsable RR 1","post-b":"Responsable RR 2","hyu":"Hyu","raidon":"Raidon","camp-nurse":"Soins du camp","surf":"Surf","surf-return":"Surf","surf-secret":"Cache du bassin","spring-fish":"Pêche aux sources","chapter-grass":"Herbes de canopée","cut":"Coupe","rock-smash":"Éclate-Roc","strength":"Force","expedition-cache":"Relevés de terrain","fish":"Pêcher","fossils":"Fossiles","door-center":"Centre Pokémon","door-shop":"Boutique","door-home":"Maison","gate":"Sentier","exit":"Sortie","vyna":"Vyna","professor":"Professeur","resident":"Habitant","nurse":"Soins","merchant":"Achats","clothier":"Vêtements","pc":"PC","mirror":"Personnalisation","supplies":"Provisions","survey":"Balise","trainer":"Dresseur","grass":"Hautes herbes"}
 var en={"roadblock":"RR checkpoint","relay-west":"West relay","relay-east":"East relay","spring-keeper":"Champion","post-a":"RR leader 1","post-b":"RR leader 2","hyu":"Hyu","raidon":"Raidon","camp-nurse":"Camp healing","surf":"Surf","surf-return":"Surf","surf-secret":"Pool cache","spring-fish":"Spring fishing","chapter-grass":"Canopy grass","cut":"Cut","rock-smash":"Rock Smash","strength":"Strength","expedition-cache":"Field notes","fish":"Fishing","fossils":"Fossils","door-center":"Pokémon Center","door-shop":"Shop","door-home":"Home","gate":"Trail","exit":"Exit","vyna":"Vyna","professor":"Professor","resident":"Resident","nurse":"Healing","merchant":"Shop","clothier":"Clothing","pc":"PC","mirror":"Customization","supplies":"Supplies","survey":"Beacon","trainer":"Trainer","grass":"Tall grass"}
 return (fr if lang=="fr" else en).get(id,id)
static func tasks(state: RefCounted,lang: String) -> Array:
 var labels: Array=["Choisir un partenaire","Relever la balise du sentier","Vaincre le dresseur","Retourner voir Vyna"] if lang=="fr" else ["Choose a partner","Survey the trail beacon","Defeat the trainer","Return to Vyna"]
 var done: Array=[not state.starter.is_empty(),state.flags.has("survey"),state.flags.has("trainer"),state.flags.has("complete")]
 var out: Array=[]
 for i: int in range(labels.size()):out.append({"text":labels[i],"done":done[i]})
 return out
