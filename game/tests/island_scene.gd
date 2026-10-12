extends SceneTree
const Mon=preload("res://scripts/domain/pokemon.gd")
const Island=preload("res://scripts/domain/island.gd")
const Slots=preload("res://scripts/services/save_slots.gd")
var checks:=0
var failures:=0
func check(ok: bool,label: String) -> void:
 checks+=1
 if not ok:failures+=1;push_error(label)
func settle(world: Node) -> void:
 var deadline: int=Time.get_ticks_msec()+12000
 while world.pokemon_battle.busy and Time.get_ticks_msec()<deadline:await create_timer(0.01).timeout
 check(not world.pokemon_battle.busy and world.pokemon_battle.last_error.is_empty(),"Native simulator replies")
func texts(world: Node) -> void:
 while world.battle_panel.event_index<world.pokemon_battle.events.size():world.battle_panel.advance()
func cinematic(world: Node) -> void:
 var count: int=0
 while world.cinematic.active and count<10:world.cinematic.advance();world._render_shot();count+=1
 world.pause_menu.close()
func press(parent: Node,text: String) -> bool:
 for node: Node in parent.get_children():
  if node is Button and not node.disabled and node.text.contains(text):node.pressed.emit();return true
 return false
func battle(world: Node,id: String) -> void:
 check(world._island_action("i-"+id),"Actual interaction starts "+id)
 if not world.pokemon_battle.active:check(false,"Battle truly active");return
 await settle(world);texts(world)
 var rounds:=0
 while world.pokemon_battle.active and rounds<20:
  world.pause_menu.close()
  if world.pokemon_battle.replacement_needed():world.pokemon_battle.replace_fainted(1)
  else:world.battle_panel.execute({"kind":"move","slot":0})
  await settle(world);texts(world);rounds+=1
 check(world.pokemon_battle.result=="won","Actual Showdown victory: "+id)
 world.pause_menu.close()
func proof(world: Node,folder: String,tag: String) -> void:
 if DisplayServer.get_name()=="headless":return
 world.pause_menu.close();world.photo_mode.active=true;world.camera.size=22;world.camera.position=Vector3(0,17,18);world.camera.look_at(Vector3.ZERO)
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png(folder+"/"+tag+".png")==OK,"Rendered proposed zone: "+tag)
 world.photo_mode.active=false
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var folder: String=""
 for arg: String in OS.get_cmdline_user_args():
  if arg.begins_with("--island-proof="):folder=arg.trim_prefix("--island-proof=")
 var world: Node=load("res://main.tscn").instantiate();world.preferences_path="user://tests_island_prefs.json";world.slots=Slots.new("user://tests_island_campaign");root.add_child(world);await process_frame;await process_frame;world._set_locale("fr")
 var campaign: RefCounted=root.get_node("Session").campaign
 world._open_menu("island")
 check(world.pause_menu.body.get_node("StartIsland")!=null and press(world.pause_menu.body,"Ouvrir l'île"),"Actual chapter start button retains campaign")
 check(campaign.adventure.exploration.location=="isle-port" and world.displayed_location=="isle-port","Haven geometry and location loaded")
 if not folder.is_empty():await proof(world,folder,"01-haven-occupied")
 check(world._island_action("i-vyna") and world.cinematic.active,"Vyna begins actual proposed arrival cinematic")
 cinematic(world)
 check(campaign.adventure.records.scenes.has("isle-arrival"),"Manual arrival completion persisted")
 check(world._island_action("i-botanist") and world.dialogue.active,"Quest giver opens actual dialogue")
 while world.dialogue.active:world.dialogue.advance()
 world.dialogue_panel.hide()
 var a: RefCounted=campaign.adventure
 a.team=[Mon.make("charizard",50,1),Mon.make("blastoise",50,2)];a.next_uid=3;a.cap=10
 a.team[0].moves=[{"id":"flamethrower","pp":15}]
 for mon: Dictionary in a.team:a.records.observe(mon.species,true)
 await battle(world,"isle-checkpoint")
 check(a.island.flags.has("checkpoint") and a.cap==14,"Real checkpoint reward opens jungle and raises cap")
 world._travel("isle-jungle")
 check(world.displayed_location=="isle-jungle" and world._island_action("i-relay-west") and world._island_action("i-relay-east"),"Real jungle route and relay interactions")
 for id: String in Island.SAMPLES:check(world._island_action("i-"+id),"Actual survey interaction "+id)
 check(a.island.collected.size()==3 and world._island_action("i-jungle-cache"),"All surveys and one-time jungle supply acquired")
 if not folder.is_empty():await proof(world,folder,"02-jungle-relays")
 world._save();world._load();a=campaign.adventure
 check(a.island.collected.size()==3 and a.island.flags.has("relay-west") and a.exploration.location=="isle-jungle","Intermediate disk reload keeps objectives and current zone")
 world._travel("isle-shrine");await battle(world,"isle-keeper")
 check(a.cap==18 and a.island.flags.has("keeper"),"Native keeper establishes cap and cave access")
 world._travel("isle-jungle");world._travel("isle-caldera")
 if not folder.is_empty():await proof(world,folder,"03-caldera")
 world._travel("isle-cave");check(world._island_action("i-cave-cache"),"Cave pickup uses actual interaction")
 if not folder.is_empty():await proof(world,folder,"04-basalt-gallery")
 world._travel("isle-base");await battle(world,"isle-admin-a");var cap: int=a.cap
 a.heal_team();await battle(world,"isle-admin-b")
 check(a.cap==22 and a.cap==cap and a.island.flags.has("admin-b"),"Actual consecutive admins retain shared event cap")
 world._open_menu("island");check(press(world.pause_menu.body,"Voir la libération") and world.cinematic.active,"Liberation starts from actual menu")
 cinematic(world)
 check(a.island.flags.has("liberated") and a.records.scenes.has("isle-liberation"),"Manual ending changes persistent world state")
 world._travel("isle-port",true)
 check(world.displayed_location=="isle-port","Scenario-unlocked Fly returns to haven")
 if not folder.is_empty():await proof(world,folder,"05-haven-liberated")
 world._island_action("i-botanist")
 while world.dialogue.active:world.dialogue.advance()
 world.dialogue_panel.hide()
 check(a.island.flags.has("gift") and a.team.size()==3,"Companion reward via actual returning NPC")
 world._island_action("i-botanist")
 while world.dialogue.active:world.dialogue.advance()
 world.dialogue_panel.hide();check(a.team.size()==3,"Repeating NPC cannot duplicate companion")
 world._travel("isle-shop");world._island_action("i-counter")
 var balls: int=int(a.bag['poke-ball']);world.pause_menu.exploration_pages.transaction("poke-ball",1,false)
 check(a.bag['poke-ball']==balls+1,"Island shop uses existing atomic purchase UI")
 world.pause_menu.close();world._travel("isle-port");world._travel("isle-center");a.team[0].hp=1;world._island_action("i-nurse")
 check(a.team[0].hp==Mon.stats(a.team[0]).hp,"Island Center heals through actual interaction")
 world._set_locale("en");world._open_menu("island")
 check(world.pause_menu.body.get_node("IslandMap").text.contains("Haven") and a.island.dialogue("resident","en").en.lines[0].contains("barriers are down"),"English map and liberated resident dialogue")
 world.pause_menu.close();world._save();world._load();a=campaign.adventure
 check(a.island.flags.has("liberated") and a.island.flags.has("gift") and a.exploration.location=="isle-center","Final disk reload retains liberation/reward/place")
 check(preload("res://scripts/domain/solo_adventure.gd").validate(a.snapshot()),"End-to-end proposed island save valid")
 print("ISLAND SCENE: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
