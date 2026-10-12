extends CanvasLayer
signal finished
const Atlas=preload("res://scripts/domain/atlas.gd")
const Visual=preload("res://scripts/world/atlas_visual.gd")
var active:=false
var world: Node3D
var scene: Node3D
var panel: PanelContainer
var camera_transform: Transform3D
var camera_size: float
var old_visibility: Dictionary={}
var hud_visible: bool=true
var angle:=0.0
var distance:=24.0
func _ready() -> void:layer=25;visible=false
func open(owner: Node3D,region: String,site: int) -> bool:
 if active or owner.get_node("/root/Session").active_network or owner.battle_panel.visible or not Atlas.valid(region,site) or owner.pokemon_battle.active or owner.dialogue.active or owner.cinematic.active or owner.photo_mode.active:return false
 world=owner;hud_visible=world.gameplay_layer.visible;world.gameplay_layer.hide();camera_transform=world.camera.transform;camera_size=world.camera.size
 old_visibility={world.world_geometry:world.world_geometry.visible}
 for avatar: Node3D in world.avatars.values():old_visibility[avatar]=avatar.visible
 for node: Node3D in old_visibility:node.hide()
 world.pause_menu.close();world.get_node("/root/Session").submit_axis(Vector2.ZERO)
 scene=Visual.new();world.add_child(scene);scene.build_proposal(region,site);world._comfort_nodes(scene)
 panel=PanelContainer.new();panel.position=Vector2(20,75);panel.custom_minimum_size.x=360;panel.theme=world.ui_theme;add_child(panel)
 var column:=VBoxContainer.new();panel.add_child(column)
 var heading:=Label.new();heading.text=Atlas.label(region,world.locale)+"\n"+Atlas.site(region,site,world.locale);column.add_child(heading)
 var note:=Label.new();note.text="Maquette 3D de volumes / 3D massing study\nConcepts détaillés dans le chat ; aucun choix final.";column.add_child(note)
 for offset: int in [-45,45]:
  var amount: int=offset;var turn:=Button.new();turn.text="Rotation %d°" % amount;column.add_child(turn);turn.pressed.connect(func():angle+=amount;frame())
 var zoom:=HSlider.new();zoom.min_value=14;zoom.max_value=30;zoom.value=distance;column.add_child(zoom);zoom.value_changed.connect(func(value: float):distance=value;frame())
 var back:=Button.new();back.text="Retour / Back • Esc";column.add_child(back);back.pressed.connect(close);back.grab_focus()
 active=true;visible=true;frame();return true
func frame() -> void:
 var radians: float=deg_to_rad(angle)
 world.camera.position=Vector3(sin(radians)*24,20,cos(radians)*24);world.camera.look_at(Vector3.ZERO);world.camera.size=distance
func close() -> void:
 if not active:return
 active=false;visible=false
 for node: Node3D in old_visibility:
  if is_instance_valid(node):node.visible=old_visibility[node]
 world.gameplay_layer.visible=hud_visible
 world.camera.transform=camera_transform;world.camera.size=camera_size
 scene.queue_free();panel.queue_free();old_visibility.clear();finished.emit()
