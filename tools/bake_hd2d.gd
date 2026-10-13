extends SceneTree
## Offline sprite production from owner models. Never needed to run the demo.
const World=preload("res://scripts/world/demo_world.gd")
const State=preload("res://scripts/domain/demo_state.gd")
const Scenery=preload("res://scripts/world/tripo_scenery.gd")
const Actor=preload("res://scripts/world/tripo_actor.gd")
var stage: Node3D
var camera: Camera3D
var viewport: SubViewport
var out: String="res://assets/hd2d/"
var recipes: Dictionary={}
var sprites: Dictionary={}
func _initialize() -> void:run.call_deferred()
func photograph(node: Node3D,id: String,size: float=16.0,pixels: int=1024) -> Dictionary:
 stage.add_child(node);camera.size=size;viewport.size=Vector2i(pixels,pixels)
 camera.position=Vector3(0,18,20);camera.look_at(Vector3(0,3 if pixels==1024 else .85,0))
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 var image: Image=viewport.get_texture().get_image();image.convert(Image.FORMAT_RGBA8)
 var rect: Rect2i=image.get_used_rect()
 var anchor: Vector2=camera.unproject_position(Vector3.ZERO)-Vector2(rect.position)
 var crop: Image=image.get_region(rect)
 var error:=crop.save_png(out+id+".png")
 assert(error==OK)
 stage.remove_child(node)
 return {"path":out+id+".png","anchor":[anchor.x,anchor.y],"pixels_per_unit":pixels/size,"size":[rect.size.x,rect.size.y]}
func run() -> void:
 viewport=SubViewport.new();viewport.size=Vector2i(1024,1024);viewport.own_world_3d=true;viewport.transparent_bg=true;viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(viewport)
 stage=Node3D.new();viewport.add_child(stage)
 var environment:=WorldEnvironment.new();var env:=Environment.new();env.background_mode=Environment.BG_CLEAR_COLOR;env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.ambient_light_color=Color("fff1db");env.ambient_light_energy=.6;environment.environment=env;stage.add_child(environment)
 var light:=DirectionalLight3D.new();light.rotation_degrees=Vector3(-50,-30,0);light.light_energy=.85;stage.add_child(light)
 camera=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;stage.add_child(camera);camera.current=true
 var world: Node3D=World.new();root.add_child(world);world.hide()
 var state:=State.new();state.choose("charmander");state.chapter.flags.started=true
 var layouts: Dictionary={};var counter:=0
 for location: String in ["town","trail","center","shop","home","canopy","springs","post"]:
  state.location=location;state.position=Vector3(0,0,9);world.build(state)
  var layout: Dictionary={"props":[],"npcs":[],"points":{},"blockers":[]}
  for id: String in world.points:
   var point: Vector3=world.points[id];layout.points[id]=[point.x,point.y,point.z]
  for b: Rect2 in world.blockers:layout.blockers.append([b.position.x,b.position.y,b.size.x,b.size.y])
  for node: Node in world.geometry.get_children():
   if not node is Node3D:continue
   if node.name.begins_with("NPC_"):
    layout.npcs.append({"id":str(node.name).trim_prefix("NPC_"),"at":[node.position.x,node.position.y,node.position.z]});continue
   var id: String=str(node.get_meta("scenery_id",""))
   if node.name=="TripoShop":id="shop"
   if id.is_empty():continue
   var transform_key:=id+"/"+str(node.transform.basis)
   var key: String
   if recipes.has(transform_key):key=recipes[transform_key]
   else:
    key="prop-%03d" % counter;counter+=1;recipes[transform_key]=key
    var duplicate: Node3D=node.duplicate();duplicate.position=Vector3.ZERO;duplicate.visible=true
    sprites[key]=await photograph(duplicate,key)
    duplicate.free()
   layout.props.append({"id":id,"sprite":key,"at":[node.position.x,node.position.y,node.position.z]})
  layouts[location]=layout
  await process_frame
 var hero:=Actor.create();var animator: AnimationPlayer=hero.find_child("AnimationPlayer",true,false)
 for direction: int in range(4):
  hero.rotation.y=direction*PI/2
  for clip: String in ["idle","walk","run"]:
   animator.play(clip);animator.speed_scale=0
   var frames:=1 if clip=="idle" else 8
   for frame: int in range(frames):
    animator.seek(animator.get_animation(clip).length*frame/frames,true)
    var key: String="hero-%d-%s-%d" % [direction,clip,frame]
    sprites[key]=await photograph(hero,key,3.0,192)
 hero.free();world.queue_free()
 var manifest: Dictionary={"schema":1,"projection":[64,48],"sprites":sprites,"layouts":layouts,"source":"Owner Tripo exports, offline Godot render; not hand-drawn art","hero_frames":8,"directions":4}
 FileAccess.open(out+"manifest.json",FileAccess.WRITE).store_string(JSON.stringify(manifest,"  "))
 print("HD2D BAKE: ",counter," prop sprites, 68 character frames, 8 layouts; transparent PNGs saved")
 quit()
