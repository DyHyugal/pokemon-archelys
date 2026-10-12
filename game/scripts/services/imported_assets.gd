extends RefCounted
## Approved local exports only; visual registration does not change collisions/doors.
static func validate(v: Variant) -> bool:
 if not v is Dictionary or v.get("schema")!=1 or not v.get("assets") is Dictionary:return false
 for id: Variant in v.assets:
  var a: Variant=v.assets[id]
  if not id is String or not a is Dictionary:return false
  if not a.get("path") is String or not a.path.begins_with("res://assets/imported/") or not a.path.ends_with(".glb") or ".." in a.path:return false
  if not a.get("scale") is float and not a.get("scale") is int:return false
  if not is_finite(float(a.scale)) or a.scale<=0 or a.scale>100:return false
  if not a.get("rotation") is float and not a.get("rotation") is int:return false
  if not is_finite(float(a.rotation)):return false
  for field: String in ["source","rights","sha256"]:
   if not a.get(field) is String or a[field].is_empty():return false
  if a.sha256.length()!=64 or not a.sha256.is_valid_hex_number():return false
 return true
static func data() -> Dictionary:
 var parser:=JSON.new()
 if parser.parse(FileAccess.get_file_as_string("res://assets/imported/registry.json"))!=OK or not validate(parser.data):return {}
 return parser.data.assets
static func instantiate(id: String) -> Node3D:
 var assets: Dictionary=data()
 if not assets.has(id) or not ResourceLoader.exists(assets[id].path):return null
 var scene: Resource=load(assets[id].path)
 if not scene is PackedScene:return null
 var node: Node=scene.instantiate()
 if not node is Node3D:node.free();return null
 node.scale=Vector3.ONE*float(assets[id].scale);node.rotation_degrees.y=float(assets[id].rotation);return node
