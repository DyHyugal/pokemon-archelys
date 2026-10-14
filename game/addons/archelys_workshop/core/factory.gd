@tool
extends RefCounted
const Object2D = preload("res://addons/archelys_workshop/nodes/object_2d.gd")
const Object3D = preload("res://addons/archelys_workshop/nodes/object_3d.gd")
static func make(entry: Dictionary, dimension: int) -> Node:
	var path: String = entry.get("path", "")
	if not preload("res://addons/archelys_workshop/core/catalog.gd").entry_errors(entry).is_empty(): return null
	var node: Node
	if path.get_extension().to_lower() == "glb":
		if dimension != 3: return null
		var resource = load(path)
		if not resource is PackedScene: return null
		node = Object3D.new(); node.model = resource
		node.model_scale = float(entry.get("scale", 1.0))
	else:
		if dimension != 2: return null
		var texture = load(path)
		if not texture is Texture2D: return null
		if entry.has("region"):
			var r: Array = entry.region
			if r.size() != 4: return null
			var atlas := AtlasTexture.new(); atlas.atlas = texture; atlas.region = Rect2(r[0], r[1], r[2], r[3]); texture = atlas
		node = Object2D.new(); node.texture = texture; node.height_pixels = float(entry.get("height", 160))
	node.object_id = entry.id; node.source_id = entry.id; node.label = entry.label; node.name = entry.id.validate_node_name()
	return node
