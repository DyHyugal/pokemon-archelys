extends SceneTree
const Atlas=preload("res://scripts/domain/atlas.gd")
const Comfort=preload("res://scripts/services/comfort_store.gd")
var checks:=0
var failures:=0
var proof_folder: String=""
func check(ok: bool,text: String) -> void:
 checks+=1
 if not ok:failures+=1;push_error(text)
func _initialize() -> void:call_deferred("run")
func capture(id: String) -> void:
 if proof_folder.is_empty() or DisplayServer.get_name()=="headless":return
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().get_size()==Vector2i(1920,1080),"Actual FHD rendering "+id)
 check(root.get_texture().get_image().save_png(proof_folder+"/"+id+".png")==OK,"Real graphic asset capture "+id)
func run() -> void:
 for arg: String in OS.get_cmdline_user_args():
  if arg.begins_with("--assets-proof="):proof_folder=arg.trim_prefix("--assets-proof=")
 var prefix: String="tests_assets_scene" if proof_folder.is_empty() else "tests_assets_render"
 var world: Node=load("res://main.tscn").instantiate();world.preferences_path="user://"+prefix+"_locale.json";world.comfort=Comfort.new("user://"+prefix+"_comfort.json");root.add_child(world)
 await process_frame;await process_frame;world._set_locale("fr")
 if not proof_folder.is_empty():world.comfort.set_option("resolution","1920x1080");world._apply_comfort()
 var session: Node=root.get_node("Session")
 var original_environment: Environment=world.get_children().filter(func(node: Node):return node is WorldEnvironment)[0].environment
 var original: Dictionary=session.campaign.adventure.snapshot()
 for id: String in preload("res://scripts/domain/world_rules.gd").SERVICE_POINTS:
  var at: Vector3=preload("res://scripts/domain/world_rules.gd").SERVICE_POINTS[id]
  check(not session._can_step(Vector2(at.x-1,at.z),Vector2(at.x,at.z)),"Actual campaign NPC collision "+id)
 var avatar: Node3D=world.avatars.values()[0]
 check(avatar.find_child("Trainer_Backpack",true,false)!=null and avatar.find_children("Trainer_EyeWhite*","MeshInstance3D",true,false).size()==2,"World player uses new anime trainer geometry, bag and eyes")
 world._open_menu("atlas")
 for region: String in Atlas.REGIONS:
  check(world.atlas_studio.open(world,region,1),"Actual asset visit opens "+region)
  var studio: Node=world.atlas_studio
  check(studio.scene.find_child("Asset_house-"+region,true,false)!=null and studio.scene.find_child("Asset_landmark-"+region,true,false)!=null,"Region imports own building and major site "+region)
  await capture(region+"-overview")
  studio.panel.find_child("WalkVisit",true,false).pressed.emit()
  check(studio.walking and studio.visitor.visible and studio.visitor_position==Vector3(0,0,11),"Walk control places separate animated visitor "+region)
  studio.set_process(false)
  for i: int in range(10):studio.step(Vector2(1,0),0.05)
  check(studio.visitor_position.x>1.0 and session.campaign.adventure.snapshot()==original,"Visit movement changes no campaign data "+region)
  var before: Vector3=studio.visitor_position
  studio.visitor_position=Vector3(-8,0,-3.6);studio.visitor.position=studio.visitor_position
  for i: int in range(8):studio.step(Vector2(0,-1),0.05)
  check(studio.visitor_position.z>=-3.9 and not studio.scene.can_walk(Vector3(-8,0,-4)),"Visit collision stops wall traversal "+region)
  studio.visitor_position=Vector3(0,0,11);studio.visitor.position=studio.visitor_position
  studio.panel.find_child("VisitAvatarProfile",true,false).item_selected.emit(1)
  check(studio.visitor.find_child("Mannequin_Torso",true,false).material_override.albedo_color==Color("b74948") and session.campaign.adventure.appearance==original.appearance,"Avatar profile affects preview only "+region)
  await capture(region+"-walk")
  studio.close();await process_frame
  check(world.world_geometry.visible and not studio.active and studio.environment_node.environment==original_environment and session.campaign.adventure.snapshot()==original,"Closing visit returns original world unchanged "+region)
 world.pause_menu.close()
 world.photo_mode.start(world);world.photo_mode.distance=4;world.photo_mode.angle=0;world.photo_mode.frame();await capture("trainer-closeup");world.photo_mode.close()
 var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/archipelago/provenance.json"))
 check(data.assets.size()==21,"All original asset files have recorded provenance")
 for asset: Dictionary in data.assets:
  var path: String="res://"+String(asset.file).trim_prefix("game/")
  var packed: PackedScene=load(path)
  check(packed!=null and asset.sha256.length()==64,"Asset imported with recorded source/hash: "+path)
 print("ARCHIPELAGO ASSETS: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
