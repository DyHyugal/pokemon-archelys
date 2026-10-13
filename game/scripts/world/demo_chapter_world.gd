extends RefCounted
## Gameplay layouts retained; owner-provided Tripo scenery replaces the blockout.
const Chapter=preload("res://scripts/domain/demo_chapter.gd")
const Kit=preload("res://scripts/world/asset_kit.gd")
static func build(world: Node3D,state: RefCounted) -> void:
 var place: String=state.location
 world.box(Vector3(32,.2,36),Vector3(0,-.1,-2),"6f9271" if place=="canopy" else ("babda0" if place=="springs" else "b4ab91"))
 world.box(Vector3(4,.04,30),Vector3(0,.02,-2),"dbcba7")
 if place=="canopy":
  world.points={"go-trail":Vector3(0,0,12),"go-springs":Vector3(0,0,-17),"go-post":Vector3(12,0,-5),"relay-west":Vector3(-7,0,-5),"relay-east":Vector3(7,0,-9),"surf":Vector3(-4.5,0,5),"surf-return":Vector3(-9,0,1.5),"surf-secret":Vector3(-9,0,5),"chapter-grass":Vector3(5,0,2)}
  world.npc("hyu",Vector3(-4,0,-11),0);world.npc("camp-nurse",Vector3(4,0,-11),1)
  for id: String in ["relay-west","relay-east"]:world.box(Vector3(.6,1,.6),world.points[id]+Vector3(0,.5,0),"87b4ad" if state.chapter.flags.has(id) else "b69d76")
  world.box(Vector3(7,.04,7),Vector3(-8.5,.06,5.5),"4797a9")
  world.scenery("treasure-chest",world.points['surf-secret'],Vector2(.7,.7),.6)
  world.box(Vector3(6,.05,6),Vector3(6,.05,2),"407754")
  for x: int in [-12,11]:
   for z: int in [-14,-7,0,10]:
    Kit.place(world.geometry,"palm",Vector3(x,0,z),1);world.blockers.append(Rect2(Vector2(x-.35,z-.35),Vector2(.7,.7)))
  Kit.place(world.geometry,"bench",Vector3(6,0,-12),.8)
  world.scenery("camping-tent",Vector3(6,0,-15),Vector2(4,2),3)
  world.blockers.append(Rect2(Vector2(4,-16),Vector2(4,2)))
  for at: Vector3 in [Vector3(-12,0,2),Vector3(12,0,6)]:world.scenery("palm-plant",at,Vector2(2,2),2.3)
 elif place=="springs":
  world.points={"go-canopy":Vector3(0,0,12),"spring-fish":Vector3(-3.5,0,-2)}
  world.npc("spring-keeper",Vector3(0,0,-10),2)
  world.box(Vector3(9,.06,7),Vector3(-9,.06,-3),"4797a9")
  for x: int in [-12,12]:
   for z: int in [-13,-7,5]:
    Kit.place(world.geometry,"rock",Vector3(x,0,z),1.2);world.blockers.append(Rect2(Vector2(x-.6,z-.6),Vector2(1.2,1.2)))
  world.scenery("fantasy-temple",Vector3(0,0,-17),Vector2(8,4),8)
  world.scenery("arena-platform",Vector3(0,-.12,-10),Vector2(5,5),.4)
  world.scenery("rock-cave",Vector3(11,0,-16),Vector2(5,4),4)
  world.blockers.append(Rect2(Vector2(-4,-19),Vector2(8,4)))
  world.blockers.append(Rect2(Vector2(8.5,-18),Vector2(5,4)))
 else:
  world.points={"go-canopy":Vector3(0,0,12)}
  world.npc("post-a",Vector3(-4,0,-7),3);world.npc("post-b",Vector3(4,0,-7),3);world.npc("raidon",Vector3(-5,0,4),1)
  for side: int in [-1,1]:
   world.box(Vector3(.3,1.6,24),Vector3(side*10,.8,-2),"9b8a72")
   for z: int in [-13,-2,7]:Kit.place(world.geometry,"rock",Vector3(side*12,0,z),.8)
  world.scenery("gazebo",Vector3(0,0,-16),Vector2(8,4),7)
  world.blockers.append(Rect2(Vector2(-4,-18),Vector2(8,4)))
  world.scenery("guard-post",Vector3(-7,0,-12),Vector2(3,3),3.5)
  world.blockers.append(Rect2(Vector2(-8.5,-13.5),Vector2(3,3)))
  world.scenery("barrier-gate",Vector3(0,0,8),Vector2(5,.8),1.5)
  world.blockers.append(Rect2(Vector2(-2.5,7.6),Vector2(5,.8)))
  world.scenery("traffic-barrier",Vector3(7,0,7),Vector2(2,.8),1.3)
  world.blockers.append(Rect2(Vector2(6,6.6),Vector2(2,.8)))
 # Portal markers do not collide: story guards run before every transition.
 for id: String in world.points:
  if not id.begins_with("go-"):continue
  var sign:=Label3D.new();sign.text=Chapter.name_of(id.trim_prefix("go-"),"fr");sign.position=world.points[id]+Vector3(0,1.4,0);sign.set_meta("caption_id",id);sign.font_size=24;sign.pixel_size=.006;sign.billboard=BaseMaterial3D.BILLBOARD_ENABLED;world.geometry.add_child(sign)
