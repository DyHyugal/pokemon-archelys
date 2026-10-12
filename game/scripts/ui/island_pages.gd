extends RefCounted
const Island=preload("res://scripts/domain/island.gd")
var menu: CanvasLayer
func _init(owner: CanvasLayer) -> void:menu=owner
func t(fr: String,en: String) -> String:return menu.tr_text(fr,en)
func render() -> void:
 var a: RefCounted=menu.adventure
 menu.label(t("Première île — PROPOSITION JOUABLE, noms/graphismes/scénario/équipes provisoires.","First island — PLAYABLE PROPOSAL, provisional names/art/story/teams."))
 menu.label(a.island.objective(menu.locale))
 if not a.island.flags.has("started"):
  var start: Button=menu.button(menu.body,t("Ouvrir l'île proposée (équipe conservée)","Open proposed island (party retained)"),func():
   if a.island.start(a):menu.travel_requested.emit("isle-port",false))
  start.name="StartIsland";start.disabled=a.in_battle
 elif a.exploration.location not in Island.LOCATIONS:
  menu.button(menu.body,t("Rejoindre le havre proposé","Return to proposed haven"),func():menu.travel_requested.emit("isle-port",false))
 if a.island.flags.has("admin-b") and not a.island.flags.has("liberated"):
  menu.button(menu.body,t("Voir la libération proposée","Watch proposed liberation"),func():menu.scene_requested.emit("isle-liberation",false))
 menu.label(t("Progression principale","Main progress"))
 for key: String in ["checkpoint","relay-west","relay-east","keeper","admin-a","admin-b","liberated"]:
  var titles: Dictionary={"checkpoint":["Contrôle RR","RR checkpoint"],"relay-west":["Relais ouest","West relay"],"relay-east":["Relais est","East relay"],"keeper":["Sanctuaire","Sanctuary"],"admin-a":["Admin A — palier22","Admin A — ceiling22"],"admin-b":["Admin B — même palier22","Admin B — same ceiling22"],"liberated":["Libération / Vol","Liberation / Fly"]}
  menu.label(("✓ " if a.island.flags.has(key) else "○ ")+t(titles[key][0],titles[key][1]))
 menu.label(t("Botaniste : quête %s • relevés %d/3 • cadeau %s","Botanist: quest %s • surveys %d/3 • gift %s") % [str(a.island.flags.has("quest")),a.island.collected.size(),str(a.island.flags.has("gift"))])
 menu.label(t("Carte locale — nord en haut, chaque panneau est une transition à pied. Le havre permet Centre/boutique. Après libération : Vol seulement vers les lieux visités, sans Pokémon compatible.","Local map — north up; each sign is a walking transition. The haven offers Center/shop. After liberation: Fly only to visited places, no compatible Pokémon needed."))
 var diagram: Label=menu.label(t("Havre ⇄ Jungle ⇄ Caldeira ⇄ Galerie ⇄ Poste RR\n                 ↕\n           Sanctuaire","Haven ⇄ Jungle ⇄ Caldera ⇄ Gallery ⇄ RR outpost\n                  ↕\n             Sanctuary"));diagram.name="IslandMap"
 for id: String in Island.LOCATIONS:
  var target: String=id
  var visited: bool=id in a.exploration.visited
  var control: Button=menu.button(menu.body,("✓ " if visited else "○ ")+Island.name_of(id,menu.locale)+t(" — Vol"," — Fly"),func():menu.travel_requested.emit(target,true))
  control.disabled=not a.island.can_enter(a,id,true);control.name="IslandFly_"+id
 menu.label(t("Parcours conseillé : nouveau slot pour tester les niveaux ; les anciennes équipes puissantes peuvent trivialiser les combats. Rien n'est réinitialisé automatiquement.","Recommended: new slot for level testing; existing strong parties can trivialize battles. Nothing is automatically reset."))
