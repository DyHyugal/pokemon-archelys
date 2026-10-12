extends "res://scripts/world/visual_district.gd"
## Original blockout. Geometry matches island authoritative blockers.
const Island=preload("res://scripts/domain/island.gd")
func build_island(location: String,state: RefCounted,language: String) -> void:
 var underground: bool=location in ["isle-cave","isle-base"]
 var ground: String="807b70" if underground else "76a77c"
 if location=="isle-caldera":ground="8e7465"
 if location=="isle-port":
  box(Vector3(60,0.2,50),Vector3(0,-0.8,0),"379eab")
  box(Vector3(31,0.35,24),Vector3(0,-0.25,0),"d7c698")
 else:box(Vector3(30,0.3,23),Vector3(0,-0.25,0),ground)
 box(Vector3(4,0.025,20),Vector3(0,0.015,0),"ceb998")
 if location=="isle-jungle":box(Vector3(13,0.025,3),Vector3(5,0.02,0),"ceb998")
 if location=="isle-port":
  box(Vector3(20,0.025,3),Vector3(0,0.02,0),"ceb998")
  for x: int in [-8,8]:
   box(Vector3(4.2,2.8,3.6),Vector3(x,1.4,-3),"e8e3cc")
   box(Vector3(5,0.3,4.3),Vector3(x,3,-3),"447d86" if x<0 else "a17058")
   box(Vector3(1.2,2,0.12),Vector3(x,1,-1.15),"3d6066")
  for at: Vector2 in [Vector2(-12,-7),Vector2(12,-7),Vector2(-12,7)]:palm(at)
 if location=="isle-jungle":
  for x: int in [-11,11]:
   for z: int in [-7,7]:palm(Vector2(x,z))
  for id: String in ["relay-west","relay-east"]:
   var at: Vector3=Island.points(location)["i-"+id]
   cylinder(0.5,0.6,at+Vector3(0,0.3,0),"716f64")
   sphere(0.28,at+Vector3(0,1,0),"77e4c8" if state.flags.has(id) else "cf885e")
 if location=="isle-caldera":
  cylinder(3.4,1.1,Vector3(0,0.55,0),"675e59")
  cylinder(2.8,0.12,Vector3(0,1.12,0),"e78648")
  for side: int in [-1,1]:box(Vector3(3,0.03,20),Vector3(side*6,0.025,0),"bdac94")
 if location=="isle-cave":
  for side: int in [-1,1]:box(Vector3(0.8,4,23),Vector3(side*9.8,2,0),"575b61")
  for side: int in [-1,1]:
   for z: int in [-6,0,6]:
    var crystal:=sphere(0.32,Vector3(side*8.7,1.1,z),"6ed0c5");crystal.material_override.emission_enabled=true;crystal.material_override.emission=Color("4b8f85")
 if location=="isle-shrine":
  cylinder(5,0.1,Vector3(0,0.05,-2),"c6c4af")
  for x: int in [-6,6]:
   for z: int in [-6,2]:cylinder(0.5,3,Vector3(x,1.5,z),"a8a995")
 if location=="isle-base":
  for x: int in [-10,10]:box(Vector3(0.4,3,20),Vector3(x,1.5,0),"596672")
  for x: int in [-7,7]:
   box(Vector3(3,1.3,2),Vector3(x,0.65,-7),"71888c")
   box(Vector3(2.5,0.15,1.5),Vector3(x,1.4,-7),"6fc2bc" if state.flags.has("liberated") else "c98555")
 if location in ["isle-center","isle-shop"]:
  box(Vector3(28,0.2,22),Vector3(0,-0.1,0),"c9c4b2")
  box(Vector3(28,3,0.4),Vector3(0,1.5,-10.5),"e8e7dc")
  box(Vector3(7,1,1.5),Vector3(0,0.5,-3),"78b4b7" if location=="isle-center" else "be966c")
 if location in ["isle-jungle","isle-caldera","isle-cave"]:
  box(Vector3(6,0.04,3),Vector3(-6,0.03,-5.5),"457b55" if location!="isle-cave" else "737b72")
 for id: String in Island.points(location):
  var at: Vector3=Island.points(location)[id]
  if id.trim_prefix("i-") in Island.OBSTACLES:
   if state.cleared.has(id.trim_prefix("i-")):continue
   var obstacle: Dictionary=Island.OBSTACLES[id.trim_prefix("i-")]
   if obstacle.action=="cut":box(Vector3(1.5,0.7,0.8),at+Vector3(0,0.35,0),"84634e")
   else:sphere(0.75,at+Vector3(0,0.6,0),"7b817d")
  var text: String=caption(id,language)
  if id.begins_with("i-go-"):
   cylinder(0.28,1.4,at+Vector3(0,0.7,0),"9a805b")
   box(Vector3(1.7,0.55,0.1),at+Vector3(0,1.25,0),"e4d5ad")
  elif id.begins_with("i-sample"):
   sphere(0.26,at+Vector3(0,0.25,0),"598752");sphere(0.12,at+Vector3(0,0.55,0),"d5a9d8")
  elif id.contains("cache"):
   box(Vector3(0.8,0.65,0.7),at+Vector3(0,0.325,0),"81745c" if state.caches.has(id.trim_prefix("i-")) else "d8ac65")
  elif id in ["i-vyna","i-resident","i-botanist","i-isle-checkpoint","i-isle-keeper","i-isle-admin-a","i-isle-admin-b","i-nurse","i-counter","i-clothier","i-eggkeeper"]:
   var npc: Node3D=load("res://assets/prototypes/mannequin.glb").instantiate();npc.position=at;add_child(npc)
  var label:=Label3D.new();label.text=text;label.position=at+Vector3(0,1.8,0);label.font_size=32;label.pixel_size=0.008;label.billboard=BaseMaterial3D.BILLBOARD_ENABLED;add_child(label)
 if location=="isle-port":
  for x: int in [-3,3]:
   box(Vector3(0.1,2.4,0.1),Vector3(x,1.2,-5),"72858a")
   box(Vector3(1.2,0.9,0.08),Vector3(x,2,-5),"63c0b0" if state.flags.has("liberated") else "a84c48")
 set_process(true)
func palm(at: Vector2) -> void:
 cylinder(0.22,2.8,Vector3(at.x,1.4,at.y),"957653")
 for i: int in range(4):
  var leaf:=sphere(0.7,Vector3(at.x+cos(i*PI/2)*0.6,2.8,at.y+sin(i*PI/2)*0.6),"448269");leaf.scale=Vector3(1.6,0.4,1.5);leaves.append(leaf)
static func caption(id: String,language: String) -> String:
 if id.trim_prefix("i-") in Island.OBSTACLES:return Island.OBSTACLES[id.trim_prefix("i-")].action
 if id.begins_with("i-go-"):return Island.name_of(id.trim_prefix("i-go-"),language)
 var names: Dictionary={"i-vyna":["Vyna — proposition","Vyna — proposal"],"i-resident":["Habitant","Resident"],"i-botanist":["Botaniste / quête","Botanist / quest"],"i-nurse":["Soins gratuits","Free healing"],"i-counter":["Boutique","Shop"],"i-clothier":["Vêtements","Clothing"],"i-eggkeeper":["Œuf cadeau","Gift egg"],"i-relay-west":["Relais ouest","West relay"],"i-relay-east":["Relais est","East relay"],"i-isle-checkpoint":["Contrôle RR","RR checkpoint"],"i-isle-keeper":["Gardien proposé","Proposed keeper"],"i-isle-admin-a":["Admin RR A","RR admin A"],"i-isle-admin-b":["Admin RR B","RR admin B"]}
 if names.has(id):return names[id][0 if language=="fr" else 1]
 if id.contains("sample"):return "Relevé / Survey"
 if id.contains("cache"):return "Réserve / Supply cache"
 return id
