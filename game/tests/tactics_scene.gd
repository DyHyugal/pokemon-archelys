extends SceneTree
const Slots=preload("res://scripts/services/save_slots.gd")
var checks:=0
var failures:=0
func check(ok: bool,label: String) -> void:
 checks+=1
 if not ok:failures+=1;push_error(label)
func drain(world: Node) -> void:
 while world.battle_panel.event_index<world.pokemon_battle.events.size():world.battle_panel.advance()
func press(world: Node,needle: String) -> bool:
 for control: Node in world.battle_panel.actions.get_children():
  if control is Button and not control.disabled and control.text.contains(needle):control.pressed.emit();return true
 return false
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var world: Node=load("res://main.tscn").instantiate();world.slots=Slots.new("user://tests_tactics_campaign");world.preferences_path="user://tests_tactics_preferences.json";root.add_child(world)
 await process_frame;await process_frame
 world._set_locale("fr")
 var campaign: RefCounted=root.get_node("Session").campaign
 var before: Dictionary=campaign.snapshot()
 world._start_tactics_test();drain(world)
 check(world.pokemon_battle.active and world.pokemon_battle.sandbox and world.pokemon_battle.adventure!=campaign.adventure,"World starts sandbox with separate adventure, not owner team")
 check(world.battle_panel.cards.text.contains("ESSAI SANS SAUVEGARDE"),"Sandbox status visible")
 var surf_count:=0;var rock_count:=0;var protect_count:=0
 for control: Node in world.battle_panel.actions.get_children():
  if not control is Button:continue
  if control.text.begins_with("Surf"):surf_count+=1;check(control.text.contains("ET allié"),"Surf announces friendly fire instead of misleading per-enemy buttons")
  if control.text.begins_with("Éboulement"):rock_count+=1;check(control.text.contains("tous les adversaires"),"Rock Slide announces enemy area targeting")
  if control.text.begins_with("Abri"):protect_count+=1;check(control.text.contains("soi-même"),"Protect shown as self-targeted")
 check(surf_count==1 and rock_count==1 and protect_count==1,"One actionable button for each area/self move")
 check(press(world,"Surf") and world.pokemon_battle.turn==0 and world.pokemon_battle.queued.size()==1,"Actual Surf button queues one choice before turn starts")
 check(press(world,"Abri") and world.pokemon_battle.turn==1 and world.pokemon_battle.adventure.team[1].hp==147,"Actual ally Protect button resolves global turn and avoids Surf damage")
 drain(world)
 world._save();check(not FileAccess.file_exists(world.slots.path(1)),"Campaign cannot be saved mid-sandbox")
 check(campaign.snapshot()==before,"Sandbox damage, observations and rewards have not touched campaign")
 check(press(world,"Terminer l’essai") and not world.battle_panel.visible and campaign.snapshot()==before,"UI can exit sandbox without mutating campaign")
 world._start_tactics_test();drain(world);world.battle_panel.locale="en";world.battle_panel.render()
 check(world.battle_panel.cards.text.contains("UNSAVED SANDBOX") and press(world,"Surf"),"English labels and actual area command work")
 check(press(world,"Helping Hand"),"Second actor exposes actual ally support button")
 check(world.pokemon_battle.events.any(func(e: Dictionary):return e.en.contains("is helping Blastoise")),"Support UI resolves Helping Hand on correct ally")
 drain(world);world._stop_tactics_test()
 check(campaign.snapshot()==before,"Repeated/reset sandbox remains isolated including exit callback")
 world._start_tactics_test();drain(world);world.pokemon_battle.finish("lost");world.battle_panel.render()
 check(campaign.snapshot()==before,"Sandbox defeat never teleports or debits actual owner campaign")
 Engine.time_scale=1
 print("TACTICS SCENE: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
