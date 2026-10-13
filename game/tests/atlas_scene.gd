extends SceneTree
const Atlas=preload("res://scripts/domain/atlas.gd")
const Island=preload("res://scripts/domain/island.gd")
const Comfort=preload("res://scripts/services/comfort_store.gd")
const Slots=preload("res://scripts/services/save_slots.gd")
const Mon=preload("res://scripts/domain/pokemon.gd")
var checks:=0
var failures:=0
var folder: String=""
func check(ok: bool,label: String) -> void:
 checks+=1
 if not ok:failures+=1;push_error(label)
func pad(world: Node,button: JoyButton) -> void:
 var event:=InputEventJoypadButton.new();event.button_index=button;event.pressed=true;world._input(event)
func proof(tag: String) -> void:
 if folder.is_empty() or DisplayServer.get_name()=="headless":return
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png(folder+"/"+tag+".png")==OK,"Real renderer proof "+tag)
func _initialize() -> void:call_deferred("run")
func run() -> void:
 for arg: String in OS.get_cmdline_user_args():
  if arg.begins_with("--atlas-proof="):folder=arg.trim_prefix("--atlas-proof=")
 var prefix: String="tests_atlas_scene" if folder.is_empty() else "tests_atlas_render"
 var path: String="user://"+prefix+"_comfort.json";DirAccess.remove_absolute(path)
 var world: Node=load("res://main.tscn").instantiate();world.comfort=Comfort.new(path);world.slots=Slots.new("user://"+prefix+"_campaign");world.preferences_path="user://"+prefix+"_locale.json";root.add_child(world)
 await process_frame;await process_frame;world._set_locale("fr")
 var session: Node=root.get_node("Session");var a: RefCounted=session.campaign.adventure
 world._open_menu("atlas")
 check(world.pause_menu.body.get_node("AtlasRegion").item_count==7,"Actual atlas lists six islands plus former Aether")
 var old_camera: Transform3D=world.camera.transform;var old_size: float=world.camera.size
 for region: String in Atlas.REGIONS:
  for site: int in range(4):
   world._open_menu("atlas");world.pause_menu.atlas_pages.selected=region;world.pause_menu.render()
   var before: Dictionary=a.snapshot();var pos: Array=session.campaign.players[1].position.duplicate()
   world.pause_menu.body.get_node("AtlasSite%d" % site).pressed.emit();await process_frame
   check(world.atlas_studio.active and not world.world_geometry.visible and not world.gameplay_layer.visible,"Real studio opens isolated proposed site "+region+str(site))
   if region=="tropical" and site==0:
    var studio: Node=world.atlas_studio;studio.toggle_walk()
    var original_scale: float=Engine.time_scale
    var distances: Array=[]
    for multiplier: float in [1.0,4.0]:
     Engine.time_scale=multiplier;studio.visitor_position=Vector3(0,0,11);studio.visitor.position=studio.visitor_position
     studio.step(Vector2.RIGHT,.04*multiplier);distances.append(studio.visitor_position.distance_to(Vector3(0,0,11)))
    Engine.time_scale=original_scale
    check(distances[0]>.1 and is_equal_approx(distances[1],distances[0]*4),"Actual atlas walking also respects x4 movement")
    studio.toggle_walk()
   if site==1:await proof("studio-"+region)
   world._travel("trail");world._slot_action("new",3);world._play_scene("lab-tour");world._contextual_action("cut");world._island_action("i-nurse")
   check(not world.photo_mode.start(world) and not world._begin_pokemon_battle([Mon.make("rattata",8,900000)]),"Modal studio blocks other modes")
   for i: int in range(3):await physics_frame
   check(a.snapshot()==before and session.campaign.players[1].position==pos,"Visiting site changes no campaign, party, money or position")
   pad(world,JOY_BUTTON_B);await process_frame
   check(not world.atlas_studio.active and world.world_geometry.visible and world.gameplay_layer.visible and world.pause_menu.visible and world.pause_menu.page=="atlas" and world.camera.transform.is_equal_approx(old_camera) and is_equal_approx(world.camera.size,old_size),"Controller Back restores camera/world/atlas")
 world.pause_menu.close();check(not world.atlas_studio.open(world,"not-a-region",0),"Invalid atlas site does not open or hide world")
 pad(world,JOY_BUTTON_START);check(world.pause_menu.visible,"Controller Start opens pause menu")
 pad(world,JOY_BUTTON_B);pad(world,JOY_BUTTON_X);check(world.pause_menu.visible and world.pause_menu.page=="bag","Controller X opens actual bag")
 pad(world,JOY_BUTTON_B);pad(world,JOY_BUTTON_B);pad(world,JOY_BUTTON_Y);check(world.pause_menu.page=="journal","Controller Y opens actual journal")
 world.pause_menu.close();world._open_interaction("guide");world.dialogue_panel.show();var index: int=world.dialogue.index
 pad(world,JOY_BUTTON_A);check(world.dialogue.index==index+1,"Controller A advances world dialogue once")
 while world.dialogue.active:pad(world,JOY_BUTTON_A)
 world.dialogue_panel.hide()
 a.island.start(a);world._travel("isle-port");world._travel("isle-shop");world._island_action("i-counter")
 var balls: int=int(a.bag['poke-ball']);var cash: int=a.money
 var quantity: SpinBox=world.pause_menu.body.find_child("ShopQuantity_poke-ball",true,false);quantity.value=3
 var row: Node=quantity.get_parent();row.get_child(1).pressed.emit()
 check(a.money==cash and a.bag['poke-ball']==balls and world.pause_menu.body.get_node("CommerceConfirmation")!=null,"Quantity buy prompts confirmation without premature charge")
 world.pause_menu.body.get_node("CommerceConfirmation/ConfirmCommerce").pressed.emit()
 check(a.money==cash-600 and a.bag['poke-ball']==balls+3,"Actual confirmation buys exactly selected quantity")
 world.pause_menu.commerce_pages.offer({"kind":"item","item":"poke-ball","count":99,"sell":true});cash=a.money;balls=a.bag['poke-ball']
 world.pause_menu.body.get_node("CommerceConfirmation/ConfirmCommerce").pressed.emit()
 check(a.money==cash and a.bag['poke-ball']==balls,"Insufficient sell inventory causes no partial transaction")
 world.pause_menu.close();world._island_action("i-clothier");cash=a.money
 var next_shirt: int=(int(a.appearance.shirt)+1)%4
 world.pause_menu.body.find_child("Clothing_shirt_"+str(next_shirt),true,false).pressed.emit()
 world.pause_menu.body.get_node("CommerceConfirmation/ConfirmCommerce").pressed.emit()
 check(a.money==cash-100 and a.appearance.shirt==next_shirt and world.pause_menu.page=="wardrobe","Actual wardrobe confirmation updates campaign and avatar")
 await proof("wardrobe")
 world.pause_menu.close();world._travel("isle-port");world._travel("isle-center");world._island_action("i-eggkeeper")
 var egg: Dictionary=a.nursery.eggs[0].duplicate(true);var uid: int=a.next_uid
 world.pause_menu.close();world._island_action("i-eggkeeper")
 check(a.nursery.eggs.size()==1 and a.nursery.eggs[0]==egg and a.next_uid==uid and world.pause_menu.page=="nursery","Repeated physical NPC gift cannot duplicate or reroll egg")
 world.pause_menu.close();world._save();world._load();a=session.campaign.adventure
 check(a.nursery.eggs[0]==egg and a.appearance.shirt==next_shirt,"Disk load retains wardrobe and gifted egg")
 a.island.flags.checkpoint=true;a.island.flags["relay-west"]=true;a.island.flags["relay-east"]=true;a.island.flags.keeper=true
 world._travel("isle-port");a.records.scenes["isle-arrival"]=true;world._travel("isle-jungle")
 var point: Vector3=Island.OBSTACLES['field-cut'].position
 check(not session._can_step(Vector2(point.x-1,point.z),Vector2(point.x,point.z)),"Authoritative movement blocks uncleared rendered tree")
 check(world._island_action("i-field-cut") and session._can_step(Vector2(point.x-1,point.z),Vector2(point.x,point.z)),"Actual contextual interaction removes tree and authoritative blocker")
 world._save();world._load();a=session.campaign.adventure;check(a.island.cleared.has("field-cut"),"Obstacle clearance survives disk reload")
 world._open_menu("settings")
 world.pause_menu.body.get_node("Display_resolution").item_selected.emit(2)
 world.pause_menu.body.get_node("Display_reduced_motion").toggled.emit(true)
 world.pause_menu.body.get_node("Display_world_labels").toggled.emit(false)
 world.pause_menu.body.get_node("Display_fps_limit").item_selected.emit(2)
 check(world.comfort.data.resolution=="1920x1080" and world.comfort.data.reduced_motion and not world.comfort.data.world_labels and Engine.max_fps==60,"Actual display/comfort widgets apply independent local preferences")
 check(not world.battle_panel.animations_enabled and world.world_geometry.find_children("*","Label3D",true,false).all(func(node: Node):return not node.visible),"Reduced motion suppresses battle effects and hidden labels stay hidden")
 if DisplayServer.get_name()!="headless":check(DisplayServer.window_get_size()==Vector2i(1920,1080),"Real window resized to FHD without changing gameplay coordinates")
 await process_frame;await process_frame
 if DisplayServer.get_name()!="headless":check(root.get_texture().get_image().get_size()==Vector2i(1920,1080),"FHD setting updates the rendered viewport as well as native window")
 await proof("settings-fhd")
 if DisplayServer.get_name()!="headless":
  world.pause_menu.body.get_node("Display_window_mode").item_selected.emit(1)
  check(DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_WINDOWED and DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS),"Borderless option changes actual window flags")
  world.pause_menu.body.get_node("Display_window_mode").item_selected.emit(2)
  check(DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_FULLSCREEN,"Fullscreen option applies native window mode")
  world.pause_menu.body.get_node("Display_window_mode").item_selected.emit(0)
  world.pause_menu.body.get_node("Display_vsync").toggled.emit(false)
  check(DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_WINDOWED and not DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS) and DisplayServer.window_get_vsync_mode()==DisplayServer.VSYNC_DISABLED,"Windowed mode and vsync disable restore correctly")
  world.pause_menu.body.get_node("Display_vsync").toggled.emit(true)
 world.pause_menu.close();world._save();world._load()
 check(world.comfort.data.resolution=="1920x1080" and world.comfort.data.reduced_motion and Comfort.new(path).data==world.comfort.data,"Campaign load preserves all local display preferences")
 world.comfort.set_option("reduced_motion",false);world.comfort.set_option("combat_animations",true);world._apply_comfort()
 world._begin_pokemon_battle([Mon.make("rattata",8,900000)])
 var deadline: int=Time.get_ticks_msec()+12000
 while world.pokemon_battle.busy and Time.get_ticks_msec()<deadline:await create_timer(0.01).timeout
 check(not world.pokemon_battle.busy and world.pokemon_battle.last_error.is_empty(),"Native battle available for presentation check")
 index=world.battle_panel.event_index;Engine.time_scale=4;await create_timer(1.0).timeout
 check(world.battle_panel.event_index==index and is_equal_approx(world.battle_panel.message.modulate.a,1.0),"Optional transition finishes without advancing battle text at x4")
 pad(world,JOY_BUTTON_A);check(world.battle_panel.event_index==index+1,"Controller A advances battle text exactly once")
 world.comfort.set_option("combat_animations",false);world._apply_comfort();world.battle_panel.render()
 check(not world.battle_panel.animations_enabled and world.battle_panel.message.modulate==Color.WHITE,"Disabling transitions leaves readable text immediately")
 Engine.time_scale=1;world.pokemon_battle.finish("escaped")
 while world.battle_panel.event_index<world.pokemon_battle.events.size():world.battle_panel.advance()
 world.comfort.set_option("resolution","1280x720");world.comfort.set_option("fps_limit",0);world._apply_comfort()
 print("ATLAS SCENE: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
