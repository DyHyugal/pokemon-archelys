extends RefCounted
## Owner's retopologized, rigged pilot. Keep gameplay movement outside animation.
const Appearance=preload("res://scripts/domain/appearance.gd")
const PALETTE=preload("res://assets/tripo/chibi_palette.gdshader")
const WALK_SPEED=1.7
const RUN_SPEED=5.4
static func create() -> Node3D:
 var actor:=Node3D.new();actor.name="TripoHero";actor.set_meta("tripo_pilot",true)
 var visual: Node3D=load("res://assets/tripo/chibi.glb").instantiate()
 visual.name="TripoVisual";visual.scale=Vector3.ONE*1.85;actor.add_child(visual)
 for part: Node in visual.find_children("*","MeshInstance3D",true,false):
  var original: Material=part.get_active_material(0)
  if not original is StandardMaterial3D:continue
  var material:=ShaderMaterial.new();material.shader=PALETTE
  material.set_shader_parameter("base_texture",original.albedo_texture)
  part.material_override=material
 var player: AnimationPlayer=visual.find_child("AnimationPlayer",true,false)
 if player:
  var library:=AnimationLibrary.new()
  for name: String in ["walk","run"]:
   if not player.has_animation(name):continue
   var animation: Animation=player.get_animation(name).duplicate(true)
   animation.loop_mode=Animation.LOOP_LINEAR
   for track: int in range(animation.get_track_count()):
    if animation.track_get_type(track)!=Animation.TYPE_POSITION_3D or not str(animation.track_get_path(track)).contains("Hips"):continue
    var origin: Vector3=animation.track_get_key_value(track,0)
    for key: int in range(animation.track_get_key_count(track)):
     var value: Vector3=animation.track_get_key_value(track,key)
     value.x=origin.x;value.z=0.028655
     animation.track_set_key_value(track,key,value)
   library.add_animation(name,animation)
  if library.has_animation("walk"):
   # Supplied file has no idle: freeze the first walk pose, no invented idle motion.
   var idle: Animation=library.get_animation("walk").duplicate(true);idle.length=.1;idle.loop_mode=Animation.LOOP_LINEAR
   for track: int in range(idle.get_track_count()):
    var value: Variant=idle.track_get_key_value(track,0)
    for key: int in range(idle.track_get_key_count(track)-1,-1,-1):idle.track_remove_key(track,key)
    idle.track_insert_key(track,0,value)
   library.add_animation("idle",idle)
  for name: String in player.get_animation_library_list():player.remove_animation_library(name)
  player.add_animation_library("",library)
  animate(actor,false,false)
 return actor
static func animate(actor: Node3D,moving: bool,running: bool,speed: float=0.0) -> void:
 var player: AnimationPlayer=actor.find_child("AnimationPlayer",true,false)
 if not player:return
 var name: String="run" if moving and running else ("walk" if moving else "idle")
 if not player.has_animation(name):return
 if player.current_animation!=name:player.play(name,.12)
 # Calibrate cycle speed using the authored root travel removed above.
 var authored_speed: float=2.36 if running else .648
 player.speed_scale=clampf(speed/authored_speed,.5,3.0) if moving else 1.0
static func apply(actor: Node3D,look: Dictionary) -> void:
 for part: Node in actor.find_children("*","MeshInstance3D",true,false):
  var material: Material=part.material_override
  if not material is ShaderMaterial or material.shader!=PALETTE:continue
  for field: String in ["skin","shirt","pants","hair"]:
   material.set_shader_parameter(field+"_tint",Appearance.color(look,field))
   material.set_shader_parameter("change_"+field,int(look[field])!=int(Appearance.DEFAULT[field]))
 actor.set_meta("appearance",look.duplicate())
