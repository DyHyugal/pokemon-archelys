extends RefCounted
const Chapter=preload("res://scripts/domain/demo_chapter.gd")
var game: CanvasLayer
func _init(owner: CanvasLayer) -> void:game=owner
func t(fr: String,en: String) -> String:return game.t(fr,en)
func vyna() -> void:
 var state: RefCounted=game.state
 var column: VBoxContainer=game.popup(t("Vyna — suite de la démo (proposition)","Vyna — demo continuation (proposal)"))
 if not state.chapter.flags.has("started"):
  game.button(column,t("Continuer vers la canopée","Continue to the canopy"),func():
   if not state.chapter.begin(state):game.talk([t("Configuration de chapitre invalide ou prérequis manquants.","Invalid chapter configuration or missing prerequisites.")]);return
   game.persist_auto();game.world.build(state)
   game.clear_modal();game.play_scene("demo-canopy-briefing"),"BeginDemoChapter")
 elif not state.campaign.adventure.records.scenes.has("demo-canopy-briefing"):
  game.button(column,t("Reprendre la présentation","Resume briefing"),func():game.clear_modal();game.play_scene("demo-canopy-briefing"),"ResumeChapterBriefing")
 elif state.chapter.flags.has("reported") and not state.campaign.adventure.records.scenes.has("demo-checkpoint-report"):
  game.button(column,t("Reprendre le rapport","Resume report"),func():game.clear_modal();game.play_scene("demo-checkpoint-report"),"ResumeChapterReport")
 elif state.chapter.flags.has("admin-b") and not state.chapter.flags.has("reported"):
  game.button(column,t("Faire le rapport","Report back"),func():
   state.chapter.report(state);game.persist_auto();game.clear_modal();game.play_scene("demo-checkpoint-report"),"ReportDemoChapter")
 else:game.button(column,t("Notre objectif","Our objective"),func():game.talk([state.objective(game.locale)]),"ChapterObjective")
 game.button(column,t("Retour","Back"),game.clear_modal)
func interact(id: String) -> bool:
 var state: RefCounted=game.state
 if id.begins_with("go-"):
  var destination: String=id.trim_prefix("go-")
  if not state.chapter.can_enter(state,destination):game.talk([t("Passage verrouillé : ","Locked passage: ")+state.objective(game.locale)])
  else:game.travel(destination)
  return true
 if id in ["roadblock","spring-keeper","post-a","post-b"]:
  var battle_id: String={"roadblock":"demo-roadblock","spring-keeper":"demo-spring-keeper","post-a":"demo-post-a","post-b":"demo-post-b"}[id]
  var opponents: Array=state.chapter.opponents(state,battle_id)
  if opponents.is_empty():game.talk([state.objective(game.locale)])
  else:game.begin_battle(opponents,battle_id)
  return true
 if id in ["relay-west","relay-east"]:
  var ok: bool=state.chapter.relay(state,id)
  if ok:game.world.build(state);game.persist_auto()
  game.talk([t("Relais réactivé.","Relay restored.") if ok else t("Relais déjà relevé ou inaccessible.","Relay already restored or inaccessible.")]);return true
 if id in ["surf","surf-return"]:
  if not state.chapter.can_surf(state):game.talk([t("La championne des sources doit autoriser la traversée.","The spring champion must authorize crossing.")])
  else:state.chapter.surfing=true;game.feedback.text=t("Surf actif : traverse le bassin. Aucun Pokémon compatible requis.","Surf active: cross the pool. No compatible Pokémon required.")
  return true
 if id=="surf-secret":
  var ok: bool=state.chapter.secret(state);game.persist_auto();game.talk([t("Trois Super Balls récupérées, une seule fois.","Three Great Balls collected, once only.") if ok else t("Récompense déjà reçue, Surf verrouillé ou sac plein.","Reward already claimed, Surf locked or bag full.")]);return true
 if id=="camp-nurse":state.campaign.adventure.heal_team();game.persist_auto();game.talk([t("Soins et PP restaurés. Le PC reste au Centre du havre.","HP and PP restored. The PC remains at the haven Center.")]);return true
 if id=="hyu":game.talk([t("Hyu : les relais ouest et est alimentent l’accès aux sources. Je surveille le chemin pendant que tu les répares.","Hyu: west and east relays power the spring access. I'll watch the path while you repair them."),state.objective(game.locale)]);return true
 if id=="raidon":game.talk([t("Raidon : deux responsables gardent ce poste. Leurs équipes sont au même palier ; termine le premier avant d’affronter le second.","Raidon: two leaders guard this checkpoint. Their teams share one ceiling; finish the first before battling the second.")]);return true
 if id in ["chapter-grass","spring-fish"]:
  var mon: Dictionary=state.chapter.encounter(state)
  if not mon.is_empty():game.begin_battle([mon])
  return true
 return false
