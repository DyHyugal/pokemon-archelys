extends RefCounted
## Coordinates shared by the painted view, collision and interaction services.
const ROOT="res://assets/drawn/"
const BASE=["town","home","center","shop","trail"]
const TILE_PIXELS=64
const HERO_HEIGHT=80
const WALK_SPEED=2.8
const RUN_SPEED=5.4
static func layout(id: String) -> Dictionary:
 var result: Dictionary=original_layout(id)
 if id=="town":return town()
 # Preserve the painted interior/trail geometry while converting the old
 # rectangular 64x48 world projection to one square movement unit.
 for key: String in ["spawn"]:result[key][2]*=.75
 for key: String in result.points:result.points[key][2]*=.75
 for row: Dictionary in result.npcs:row.at[2]*=.75
 for list: String in ["walk","blockers"]:
  for row: Array in result[list]:row[1]*=.75;row[3]*=.75
 if result.has("grass"):result.grass[1]*=.75;result.grass[3]*=.75
 return result
static func town() -> Dictionary:
 var trees: Array=[]
 for x: float in [-10.5,-2.0,11.0]:
  for z: float in [-7.0,2.6,6.0]:trees.append({"kind":"tree","at":[x,0,4.4 if x==-2.0 and z==2.6 else z],"width":190})
 trees.append({"kind":"tree","at":[-5.8,0,5.8],"width":205})
 var props: Array=[{"kind":"center","at":[-5,0,-2.65],"width":480},{"kind":"home","at":[7.36,0,-2.65],"width":416},{"kind":"shop","at":[6.375,0,4.95],"width":416}]+trees
 var blocks: Array=[[-8.3,-5.3,6.6,2.4],[4.4,-5.3,5.9,2.4],[3.4,2.5,5.9,2.4]]
 for row: Dictionary in trees:blocks.append([row.at[0]-.24,row.at[2]-.24,.48,.48])
 return {"texture":"modular","size":[1536,1152],"origin":[768,576],"spawn":[0,0,2],"points":{"gate":[0,0,-8],"door-center":[-5,0,-2.4],"door-home":[6,0,-2.4],"door-shop":[4.5,0,5.2],"vyna":[1.8,0,.6],"professor":[-2.7,0,.6],"resident":[-7.4,0,.6]},"npcs":[{"id":"vyna","at":[1.8,0,.6],"color":"c18faf"},{"id":"professor","at":[-2.7,0,.6],"color":"f3e5c3"},{"id":"resident","at":[-7.4,0,.6],"color":"d3976a"}],"walk":[[-11.8,-8.9,23.6,16.7]],"blockers":blocks,"props":props}
static func original_layout(id: String) -> Dictionary:
 var common: Dictionary={"texture":"rooms","cell":[0,0],"size":[1088,612],"origin":[544,306],"spawn":[0,0,4.5],"points":{"exit":[0,0,4.5]},"npcs":[],"walk":[[-1,2.3,2,3.0]],"blockers":[]}
 match id:
  "town":
   return {"texture":"town","size":[1672,941],"origin":[836,440],"spawn":[0,0,2],"points":{"gate":[0,0,-8],"door-center":[-3.8,0,-2.4],"door-home":[3.1,0,-2.5],"door-shop":[3.4,0,6.3],"vyna":[1.8,0,.6],"professor":[-2.7,0,.6],"resident":[5.8,0,.6]},"npcs":[{"id":"vyna","at":[1.8,0,.6],"color":"c18faf"},{"id":"professor","at":[-2.7,0,.6],"color":"f3e5c3"},{"id":"resident","at":[5.8,0,.6],"color":"d3976a"}],"walk":[[-.8,-9,1.7,16.7],[-12.3,-.65,24.6,1.95],[-4.7,-2.8,1.8,3.9],[2.4,-2.9,1.6,4],[.4,5.6,4.8,2.1],[2.8,4.9,1.2,2.8]],"blockers":[]}
  "home":
   common.walk.append([-6.3,-2.7,12.6,5.2]);common.points.mirror=[4.8,0,-1.8];common.points.supplies=[-4.7,0,-.6]
   common.blockers=[[-5.3,-4.6,2.5,4.0],[1.6,-4.9,3.3,2.7]]
  "center":
   common.cell=[1,0];common.walk.append([-7,-.6,14,3.2]);common.points.nurse=[-2.7,0,-.3];common.points.pc=[5.5,0,1.0]
   common.npcs=[{"id":"nurse","at":[-2.7,0,-3.5],"color":"eaa1b6"}];common.blockers=[[-7,-1.5,1.6,3.4],[6,-2,1.8,4.5]]
  "shop":
   common.cell=[0,1];common.walk.append([-6.4,-.15,12.8,2.8]);common.points.merchant=[-1.4,0,-.1];common.points.clothier=[4.3,0,1.4];common.points.fossils=[-4.2,0,1.4]
   common.npcs=[{"id":"merchant","at":[-1.4,0,-2.9],"color":"cba477"},{"id":"clothier","at":[4.3,0,1.4],"color":"b4a0cc"},{"id":"fossils","at":[-4.2,0,1.4],"color":"cfac81"}]
  "trail":
   common.cell=[1,1];common.spawn=[0,0,5];common.points={"exit":[0,0,5.6],"survey":[-1.7,0,-4.9],"trainer":[1.0,0,-4.2],"grass":[4.0,0,-1.0],"cut":[-3,0,1.5],"rock-smash":[4.5,0,3.3],"strength":[-4,0,-2.5],"expedition-cache":[-4.5,0,2.3],"go-canopy":[0,0,-6]}
   common.walk=[[-.8,-6.2,1.8,12.4],[-2.5,-5.4,3,2.8],[.6,-2.9,5.7,4.1],[-5.6,-3.2,5.3,1.3],[-5.6,.3,5.3,2.6],[.4,2.9,5.3,1.1]]
   common.npcs=[{"id":"trainer","at":[1.0,0,-4.2],"color":"d78372"}];common.grass=[1.7,-2.8,4.5,3.1]
 return common
static func vector(row: Array) -> Vector3:return Vector3(row[0],row[1],row[2])
static func rect(row: Array) -> Rect2:return Rect2(row[0],row[1],row[2],row[3])
static func spawn(id: String) -> Vector3:return vector(layout(id).spawn)
static func walking(id: String,at: Vector3) -> bool:
 return layout(id).walk.any(func(row: Array):return rect(row).has_point(Vector2(at.x,at.z)))
static func in_grass(id: String,at: Vector3) -> bool:
 var map: Dictionary=layout(id)
 return map.has("grass") and rect(map.grass).has_point(Vector2(at.x,at.z))
