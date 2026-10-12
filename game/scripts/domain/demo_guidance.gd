extends RefCounted
static func target(state: RefCounted) -> String:
 if state.starter.is_empty() or state.flags.has("complete"):return ""
 if not state.flags.has("survey"):return "survey" if state.location=="trail" else ("gate" if state.location=="town" else "exit")
 if not state.flags.has("trainer"):return "trainer" if state.location=="trail" else ("gate" if state.location=="town" else "exit")
 return "vyna" if state.location=="town" else "exit"
static func title(id: String,lang: String) -> String:
 var fr={"door-center":"Centre Pokémon","door-shop":"Boutique","door-home":"Maison","gate":"Sentier","exit":"Sortie","vyna":"Vyna","professor":"Professeur","resident":"Habitant","nurse":"Soins","merchant":"Achats","clothier":"Vêtements","pc":"PC","mirror":"Personnalisation","supplies":"Provisions","survey":"Balise","trainer":"Dresseur","grass":"Hautes herbes"}
 var en={"door-center":"Pokémon Center","door-shop":"Shop","door-home":"Home","gate":"Trail","exit":"Exit","vyna":"Vyna","professor":"Professor","resident":"Resident","nurse":"Healing","merchant":"Shop","clothier":"Clothing","pc":"PC","mirror":"Customization","supplies":"Supplies","survey":"Beacon","trainer":"Trainer","grass":"Tall grass"}
 return (fr if lang=="fr" else en).get(id,id)
static func tasks(state: RefCounted,lang: String) -> Array:
 var labels: Array=["Choisir un partenaire","Relever la balise du sentier","Vaincre le dresseur","Retourner voir Vyna"] if lang=="fr" else ["Choose a partner","Survey the trail beacon","Defeat the trainer","Return to Vyna"]
 var done: Array=[not state.starter.is_empty(),state.flags.has("survey"),state.flags.has("trainer"),state.flags.has("complete")]
 var out: Array=[]
 for i: int in range(labels.size()):out.append({"text":labels[i],"done":done[i]})
 return out
