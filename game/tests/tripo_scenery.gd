extends SceneTree
const Scenery=preload("res://scripts/world/tripo_scenery.gd")
const State=preload("res://scripts/domain/demo_state.gd")
var checks:=0
var failures:=0
var folder: String=""
func check(ok: bool,label: String) -> void:
 checks+=1
 if not ok:failures+=1;push_error(label)
func _initialize() -> void:run.call_deferred()
func reachable(world: Node3D,target: Vector3,start: Vector3) -> bool:
 var queue: Array[Vector2i]=[Vector2i(roundi(start.x*2),roundi(start.z*2))];var seen: Dictionary={queue[0]:true};var index:=0
 while index<queue.size():
  var cell: Vector2i=queue[index];index+=1
  var at:=Vector3(cell.x*.5,0,cell.y*.5)
  if at.distance_to(target)<1.9:return true
  for direction: Vector2i in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
   var next:=cell+direction
   if not seen.has(next) and world.can_walk(Vector3(next.x*.5,0,next.y*.5)):
    seen[next]=true;queue.append(next)
 return false
func shot(world: Node3D,id: String,position: Vector3,size: float) -> void:
 if folder.is_empty() or DisplayServer.get_name()=="headless":return
 world.camera.size=size;world.camera.position=position;world.camera.look_at(Vector3(0,0,-2))
 for i: int in range(3):await process_frame
 await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png(folder+"/"+id+".png")==OK,"Actual world capture "+id)
func run() -> void:
 for arg: String in OS.get_cmdline_user_args():
  if arg.begins_with("--scenery-proof="):folder=arg.trim_prefix("--scenery-proof=")
 if not folder.is_empty():root.size=Vector2i(1920,1080)
 var stage:=Node3D.new();root.add_child(stage)
 var environment:=WorldEnvironment.new();var env:=Environment.new();env.background_mode=Environment.BG_COLOR;env.background_color=Color("1b343d");env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.ambient_light_color=Color.WHITE;env.ambient_light_energy=.25;environment.environment=env;stage.add_child(environment)
 var light:=DirectionalLight3D.new();light.rotation_degrees=Vector3(-52,-35,0);light.light_energy=.65;light.shadow_enabled=true;stage.add_child(light)
 var entries: Dictionary=preload("res://scripts/services/imported_assets.gd").data();var total:=0
 for id: String in entries:
  if not id.begins_with("pack-"):continue
  total+=1
  var model:=Scenery.create(id.trim_prefix("pack-"),Vector2(3,2),4)
  check(model!=null,"Supplied model loads: "+id)
  if model==null:continue
  var b:=Scenery.bounds(model)
  check(b.size.x<=3.001 and b.size.z<=2.001 and b.size.y<=4.001 and absf(b.position.y)<.001,"Fits footprint and grounded pivot: "+id)
  model.free()
 check(total==34,"All 34 exports are registered")
 var world: Node3D=load("res://scripts/world/demo_world.gd").new();stage.add_child(world)
 var state:=State.new();state.choose("charmander");var before: Dictionary=state.campaign.snapshot();var used: Dictionary={}
 for location: String in ["town","trail","center","shop","home","canopy","springs","post"]:
  state.location=location;state.position=Vector3(0,0,9);world.build(state)
  check(world.can_walk(state.position),"Safe arrival: "+location)
  for node: Node in world.geometry.find_children("*","Node3D",true,false):
   if node.has_meta("scenery_id"):used[node.get_meta("scenery_id")]=true
  for id: String in world.points:
   if id in ["grass","chapter-grass","surf-secret","surf-return"]:continue
   check(reachable(world,world.points[id],state.position),"Interaction reachable: "+location+"/"+id)
  await shot(world,location,Vector3(0,29,33) if location=="town" else Vector3(0,22,25),44 if location=="town" else 27)
  if location=="town":
   state.position=Vector3(-7,0,-5);world.recover_position(state)
   check(world.can_walk(state.position) and state.position.distance_to(Vector3(-7,0,-5))<4,"Old save on new prop moved nearby")
   world.hero.position=Vector3(0,0,2);world.camera.size=18;world.follow()
   if not folder.is_empty():
    await process_frame;await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(folder+"/town-player.png")
 check(used.size()==34,"Every supplied model is actually placed in the demo")
 check(state.campaign.snapshot()==before,"Scenery never changes roster, bag, progression or campaign")
 print("TRIPO SCENERY: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
