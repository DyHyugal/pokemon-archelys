extends "res://scripts/world/visual_district.gd"
const Atlas=preload("res://scripts/domain/atlas.gd")
func build_proposal(region: String,site: int) -> void:
 var p: Array=Atlas.REGIONS[region].colors
 box(Vector3(50,0.12,40),Vector3(0,-0.6,0),"73a6b6")
 box(Vector3(34,0.5,27),Vector3(0,-0.25,0),p[0])
 box(Vector3(5,0.04,25),Vector3(0,0.02,0),"d4cebd")
 box(Vector3(30,0.04,3),Vector3(0,0.03,4),"d4cebd")
 var count: int=6 if site!=3 else 4
 for i: int in range(count):
  var x: float=(-7 if i%2==0 else 7);var z: float=-7+(i/2)*6
  var height: float=3.8 if region=="tech" else 2.5
  if region=="celestial":height=3
  box(Vector3(4.5,height,3.8),Vector3(x,height/2,z),p[1])
  box(Vector3(5.2,0.28,4.6),Vector3(x,height+0.14,z),p[2])
  for side: int in [-1,1]:
   box(Vector3(0.75,0.9,0.12),Vector3(x+side*1.35,1.6,z+1.95),"8bc4cd")
  box(Vector3(1.1,1.9,0.13),Vector3(x,0.95,z+1.96),"506a71")
  if region in ["dragon","winter"]:
   for side: int in [-1,1]:box(Vector3(0.2,height,0.2),Vector3(x+side*2.1,height/2,z+2),"826449")
  if region in ["tech","aether"]:
   box(Vector3(4.6,0.12,0.12),Vector3(x,2.2,z+2.05),"59c5cf")
  if region=="mystic":sphere(0.18,Vector3(x,2.5,z+2.15),"c1a7e3")
  if region=="celestial":
   for side: int in [-1,1]:cylinder(0.22,2.8,Vector3(x+side*2.4,1.4,z+2.3),p[2])
 for side: int in [-1,1]:
  for z: int in [-8,0,8]:
   cylinder(0.2,2.4,Vector3(side*13,1.2,z),"887555")
   var crown:=sphere(0.85,Vector3(side*13,2.7,z),p[3]);leaves.append(crown)
 if region=="tropical":
  cylinder(4,2,Vector3(0,1,-11),"69625c");cylinder(2.4,0.1,Vector3(0,2.05,-11),"da814d")
 if region=="winter":
  for side: int in [-1,1]:cylinder(3,4,Vector3(side*12,2,-11),"dce8e9")
 if region=="dragon":
  for side: int in [-1,1]:box(Vector3(2,6,2),Vector3(side*4,3,-9),"99846a")
  box(Vector3(10,1,2),Vector3(0,6,-9),"99846a")
 if region=="celestial":
  for i: int in range(4):cylinder(0.65,4,Vector3(-6+i*4,2,-9),"cab78c")
  cylinder(2,4.8,Vector3(0,2.4,-12),"e1d9b6")
 if site==3 and Atlas.REGIONS[region].occupied:
  box(Vector3(9,5,4),Vector3(0,2.5,-8),"46565d")
  for side: int in [-1,1]:box(Vector3(0.2,3,0.2),Vector3(side*4,1.5,-5.5),"c06561")
 if site==2:box(Vector3(5,0.2,4),Vector3(0,0.1,5),p[2])
 set_process(true)
