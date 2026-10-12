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
var walking: bool=false
var visitor: Node3D
var visitor_position:=Vector3(0,0,11)
var animation: AnimationPlayer
var visit_appearance: Dictionary={}
var mode_button: Button
var environment_node: WorldEnvironment
var original_environment: Environment
func _ready() -> void:layer=25;visible=false
func open(owner: Node3D,region: String,site: int) -> bool:
 if active or owner.get_node("/root/Session").active_network or owner.battle_panel.visible or not Atlas.valid(region,site) or owner.pokemon_battle.active or owner.dialogue.active or owner.cinematic.active or owner.photo_mode.active:return false
 world=owner
 for child: Node in world.get_children():
  if child is WorldEnvironment:
   environment_node=child;original_environment=child.environment
   var atmosphere: Environment=original_environment.duplicate()
   if region=="mystic":atmosphere.background_color=Color("59657c");atmosphere.ambient_light_color=Color("b8b5d4");atmosphere.ambient_light_energy=0.3
   elif region=="winter":atmosphere.background_color=Color("b5d3e2")
   elif region=="celestial":atmosphere.background_color=Color("c5dfef")
   child.environment=atmosphere;break
 hud_visible=world.gameplay_layer.visible;world.gameplay_layer.hide();camera_transform=world.camera.transform;camera_size=world.camera.size
 old_visibility={world.world_geometry:world.world_geometry.visible}
 for avatar: Node3D in world.avatars.values():old_visibility[avatar]=avatar.visible
 for node: Node3D in old_visibility:node.hide()
 world.pause_menu.close();world.get_node("/root/Session").submit_axis(Vector2.ZERO)
 scene=Visual.new();world.add_child(scene);scene.build_proposal(region,site);world._comfort_nodes(scene)
 set_process(true);visitor_position=Vector3(0,0,11);walking=false;visit_appearance=world.get_node("/root/Session").campaign.adventure.appearance.duplicate()
 visitor=preload("res://scripts/world/asset_kit.gd").trainer(scene,visitor_position,visit_appearance);visitor.name="VisitAvatar";visitor.hide()
 animation=visitor.find_child("AnimationPlayer",true,false)
 panel=PanelContainer.new();panel.position=Vector2(20,75);panel.custom_minimum_size.x=360;panel.theme=world.ui_theme;add_child(panel)
 var column:=VBoxContainer.new();panel.add_child(column)
 var heading:=Label.new();heading.text=Atlas.label(region,world.locale)+"\n"+Atlas.site(region,site,world.locale);column.add_child(heading)
 var note:=Label.new();note.text="Concept validé • assets de test" if world.locale=="fr" else "Approved concept • test assets";column.add_child(note)
 mode_button=Button.new();mode_button.name="WalkVisit";mode_button.text="Visiter à pied / Walk around";column.add_child(mode_button);mode_button.pressed.connect(toggle_walk)
 var profiles:=OptionButton.new();profiles.name="VisitAvatarProfile"
 for caption: String in ["Mon personnage / My character","Exploratrice / Explorer","Botaniste / Botanist","Uniforme RR / RR outfit"]:profiles.add_item(caption)
 column.add_child(profiles);profiles.item_selected.connect(func(index: int):
  var look: Dictionary=visit_appearance.duplicate()
  if index>0:look.shirt=[0,1,2,1][index];look.pants=index%3;look.skin=index;look.style=2 if index==1 else 1;look.hair=index%4
  preload("res://scripts/world/avatar_style.gd").apply(visitor,look))
 var help:=Label.new();help.text="Clavier / stick : marcher • B / Échap : retour" if world.locale=="fr" else "Keyboard / stick: walk • B / Escape: back";column.add_child(help)
 for offset: int in [-45,45]:
  var amount: int=offset;var turn:=Button.new();turn.text="Rotation %d°" % amount;column.add_child(turn);turn.pressed.connect(func():angle+=amount;frame())
 var zoom:=HSlider.new();zoom.min_value=14;zoom.max_value=30;zoom.value=distance;column.add_child(zoom);zoom.value_changed.connect(func(value: float):distance=value;frame())
 var back:=Button.new();back.text="Retour / Back • Esc";column.add_child(back);back.pressed.connect(close);back.grab_focus()
 active=true;visible=true;frame();return true
func toggle_walk() -> void:
 walking=not walking;visitor.visible=walking;mode_button.text="Vue d'ensemble / Overview" if walking else "Visiter à pied / Walk around";frame()
func step(axis: Vector2,delta: float) -> void:
 if not active or not walking:return
 var radians: float=deg_to_rad(angle)
 var direction:=Vector3(axis.x*cos(radians)+axis.y*sin(radians),0,-axis.x*sin(radians)+axis.y*cos(radians))
 var motion: Vector3=direction*4.0*minf(delta,0.1)/maxf(1.0,Engine.time_scale)
 var pieces: int=maxi(1,ceili(motion.length()/0.15))
 for i: int in range(pieces):
  var next: Vector3=visitor_position+Vector3(motion.x/pieces,0,0)
  if scene.can_walk(next):visitor_position=next
  next=visitor_position+Vector3(0,0,motion.z/pieces)
  if scene.can_walk(next):visitor_position=next
 var moved: bool=visitor.position.distance_to(visitor_position)>0.0001
 if moved:visitor.rotation.y=atan2(direction.x,direction.z)
 visitor.position=visitor_position
 if animation:
  if moved and not animation.is_playing():animation.play(animation.get_animation_list()[-1])
  elif not moved:animation.stop()
 frame()
func _process(delta: float) -> void:
 if active and walking:step(world.comfort.axis(),delta)
func frame() -> void:
 if walking:
  var a: float=deg_to_rad(angle)
  world.camera.position=visitor_position+Vector3(sin(a)*10,8,cos(a)*10);world.camera.look_at(visitor_position+Vector3(0,0.8,0));world.camera.size=clampf(distance*0.45,6,14);return
 var radians: float=deg_to_rad(angle)
 world.camera.position=Vector3(sin(radians)*24,20,cos(radians)*24);world.camera.look_at(Vector3.ZERO);world.camera.size=distance
func close() -> void:
 if not active:return
 active=false;visible=false
 for node: Node3D in old_visibility:
  if is_instance_valid(node):node.visible=old_visibility[node]
 if environment_node:environment_node.environment=original_environment
 world.gameplay_layer.visible=hud_visible
 world.camera.transform=camera_transform;world.camera.size=camera_size
 scene.queue_free();panel.queue_free();old_visibility.clear();finished.emit()
