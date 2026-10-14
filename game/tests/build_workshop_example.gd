extends SceneTree
const Map = preload("res://addons/archelys_workshop/nodes/map_2d.gd")
const Prop = preload("res://addons/archelys_workshop/nodes/object_2d.gd")
const Event = preload("res://addons/archelys_workshop/core/event.gd")
const Step = preload("res://addons/archelys_workshop/core/step.gd")
const Factory = preload("res://addons/archelys_workshop/core/factory.gd")

func step(action: String, key: String = "", fr: String = "", en: String = "") -> Resource:
	var value := Step.new(); value.action = action; value.key = key; value.french = fr; value.english = en; return value
func object(root: Node, node: Node, at: Vector2) -> void:
	root.add_child(node); node.owner = root; node.position = at
func _initialize() -> void:
	var library: Dictionary = preload("res://addons/archelys_workshop/core/catalog.gd").read_catalog()
	var hero := AtlasTexture.new(); hero.atlas = load("res://assets/drawn/calibration/hero-sheet.png"); hero.region = Rect2(186, 33, 148, 318)
	for annex: bool in [false, true]:
		var map := Map.new(); map.map_id = "workshop-annex" if annex else "workshop-example"; map.name = "AtelierAnnexe" if annex else "AtelierExemple"; map.actor_texture = hero; map.spawn = Vector2(0, 160)
		var ground := Sprite2D.new(); var surface := AtlasTexture.new(); surface.atlas = load("res://assets/drawn/calibration/ground.png"); surface.region = Rect2(0, 0, 627, 627); ground.texture = surface; ground.scale = Vector2(2, 1.5); ground.z_index = -10; map.add_child(ground); ground.owner = map
		var house := Factory.make(library.assets[1], 2); house.blocking_size = Vector2(190, 70); object(map, house, Vector2(-260, -40))
		var tree := Factory.make(library.assets[0], 2); tree.blocking_size = Vector2(25, 25); object(map, tree, Vector2(300, 50))
		var guide := Prop.new(); guide.name = "guide"; guide.object_id = "guide"; guide.label = "Guide de l'atelier"; guide.texture = hero; guide.height_pixels = 80; guide.tint = Color(.85, .7, 1); object(map, guide, Vector2(70, 140))
		var event := Event.new(); event.event_id = "guide-welcome"; event.once_flag = "welcomed"
		event.steps.assign([step("dialogue", "", "Cette map se modifie dans Godot : objets, collisions et événements. Aucun décor USUL n'est inclus.", "Edit this map in Godot: objects, collisions and events. No USUM scenery is included."), step("give_item", "workshop-token"), step("set_flag", "gate-open"), step("dialogue", "", "Un jeton a été ajouté. Le passage à droite apparaît. Sauvegarder puis recharger conserve les flags et la langue.", "A token was added. The passage appears on the right. Saving preserves flags and language.")]); guide.interaction = event
		var gate := Prop.new(); gate.name = "passage"; gate.object_id = "passage"; gate.label = "Passage"; gate.texture = hero; gate.height_pixels = 65; gate.tint = Color.CYAN; gate.visible_if = "gate-open"; object(map, gate, Vector2(200, 170))
		var transition := Event.new(); transition.event_id = "passage"; transition.required_flag = "gate-open"; transition.steps.assign([step("warp", "workshop-example" if annex else "workshop-annex")]); gate.interaction = transition
		var trainer := Prop.new(); trainer.name = "trainer"; trainer.object_id = "trainer"; trainer.texture = hero; trainer.height_pixels = 80; trainer.tint = Color(1, .6, .5); object(map, trainer, Vector2(-100, 170))
		var challenge := Event.new(); challenge.event_id = "challenge"; challenge.once_flag = "trainer-won"; challenge.steps.assign([step("dialogue", "", "Combat de contrôle Showdown : équipe de laboratoire provisoire.", "Showdown control battle: temporary laboratory team."), step("battle", "workshop-trainer"), step("set_flag", "trainer-won"), step("dialogue", "", "Victoire confirmée par le moteur. Cette étape ne se valide pas sur défaite.", "The engine confirmed victory. Losing does not complete this step.")]); trainer.interaction = challenge
		var packed := PackedScene.new(); packed.pack(map)
		var path := "res://data/workshop/annex.tscn" if annex else "res://data/workshop/example.tscn"
		var error := ResourceSaver.save(packed, path); map.free()
		if error != OK: push_error(error_string(error)); quit(1); return
	print("WORKSHOP EXAMPLE: two editable scenes generated"); quit()
