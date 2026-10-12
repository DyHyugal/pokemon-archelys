extends CanvasLayer
signal finished
var focus_override: Node3D
var world: Node3D
var camera: Camera3D
var active:=false
var saving:=false
var original_transform:=Transform3D.IDENTITY
var original_size:=16.0
var layers: Dictionary={}
var labels: Dictionary={}
var panel: PanelContainer
var feedback: Label
var distance:=8.0
var angle:=0.0
var elevation:=1.0
var destination: String="user://photos"
var last_file: String=""
func text(fr: String,en: String) -> String:return fr if world.locale=="fr" else en
func _ready() -> void:
 layer=30;visible=false
 panel=PanelContainer.new();panel.position=Vector2(20,20);panel.custom_minimum_size.x=330;add_child(panel)
func start(owner: Node3D,view: Camera3D=null,focus: Node3D=null) -> bool:
 if active or owner.atlas_studio.active or owner.get_node("/root/Session").active_network or owner.pokemon_battle.active or owner.battle_panel.visible or owner.cinematic.active or owner.dialogue.active:return false
 world=owner;camera=owner.camera if view==null else view;focus_override=focus;original_transform=camera.transform;original_size=camera.size
 owner.get_node("/root/Session").submit_axis(Vector2.ZERO)
 layers.clear();labels.clear()
 for node: Node in owner.get_children():
  if node is CanvasLayer and node!=self:layers[node]=node.visible;node.hide()
 for node: Node in owner.find_children("*","Label3D",true,false):labels[node]=node.visible;node.hide()
 active=true;visible=true;distance=8 if focus_override==null else 4;angle=0 if focus_override==null else 90;elevation=1;render();frame();return true
func slider(parent: Node,caption: String,from: float,to: float,value: float,changed: Callable) -> void:
 var label:=Label.new();label.text=caption;parent.add_child(label)
 var control:=HSlider.new();control.min_value=from;control.max_value=to;control.step=0.5;control.value=value;parent.add_child(control);control.value_changed.connect(changed)
func render() -> void:
 for child: Node in panel.get_children():panel.remove_child(child);child.queue_free()
 var column:=VBoxContainer.new();panel.add_child(column)
 var title:=Label.new();title.text=text("Photo — Échap pour revenir","Photo — Escape to return");column.add_child(title)
 slider(column,text("Distance","Distance"),4,24,distance,func(value: float):distance=value;frame())
 slider(column,text("Angle","Angle"),-180,180,angle,func(value: float):angle=value;frame())
 slider(column,text("Hauteur du cadrage","Framing height"),0,3,elevation,func(value: float):elevation=value;frame())
 var save:=Button.new();save.text=text("Enregistrer une photo PNG","Save a PNG photo");column.add_child(save);save.pressed.connect(capture)
 var folder:=Button.new();folder.text=text("Ouvrir le dossier des photos","Open photos folder");column.add_child(folder);folder.pressed.connect(open_folder)
 var back:=Button.new();back.text=text("Revenir au jeu","Return to game");column.add_child(back);back.pressed.connect(close)
 feedback=Label.new();feedback.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;feedback.custom_minimum_size.x=310;column.add_child(feedback)
 feedback.text=text("La partie ne se déplace pas. Les décors animés restent animés. Export à la résolution courante, interface masquée.","Campaign movement is locked. Animated scenery stays animated. Export uses the current resolution and hides the UI.")
func frame() -> void:
 if not active:return
 var focus: Vector3=(world._local_position() if focus_override==null else focus_override.global_position)+Vector3(0,elevation,0)
 var radians: float=deg_to_rad(angle)
 camera.position=focus+Vector3(sin(radians)*distance,distance*0.7,cos(radians)*distance)
 camera.look_at(focus);camera.size=distance
func handle_key(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_ESCAPE:close()
func capture() -> void:
 if not active or saving:return
 if DisplayServer.get_name()=="headless":feedback.text=text("Export indisponible sans affichage graphique.","Export unavailable without a graphical display.");return
 saving=true;visible=false
 await RenderingServer.frame_post_draw
 var image: Image=get_viewport().get_texture().get_image()
 var error: Error=ERR_INVALID_DATA
 if image!=null and not image.is_empty():error=write_png(image)
 visible=active;saving=false
 if active:feedback.text=(text("Photo enregistrée : ","Photo saved: ")+ProjectSettings.globalize_path(last_file)) if error==OK else text("Échec de l'export : ","Export failed: ")+error_string(error)
func write_png(image: Image) -> Error:
 if image==null or image.is_empty():return ERR_INVALID_DATA
 var error: Error=DirAccess.make_dir_recursive_absolute(destination)
 if error!=OK:return error
 var suffix: String=str(Time.get_unix_time_from_system()).replace(".","-")+"-"+str(Time.get_ticks_usec())
 var candidate: String=destination.path_join("Archelys-"+suffix+".png")
 while FileAccess.file_exists(candidate):candidate=candidate.trim_suffix(".png")+"-new.png"
 error=image.save_png(candidate)
 if error==OK:last_file=candidate
 return error
func open_folder() -> void:
 var error: Error=DirAccess.make_dir_recursive_absolute(destination)
 if error==OK:error=OS.shell_open(ProjectSettings.globalize_path(destination))
 if error!=OK:feedback.text=error_string(error)
func close() -> void:
 if not active or saving:return
 active=false;visible=false;camera.transform=original_transform;camera.size=original_size
 for node: Node in layers:
  if is_instance_valid(node):node.visible=layers[node]
 for node: Node in labels:
  if is_instance_valid(node):node.visible=labels[node]
 layers.clear();labels.clear();world.get_node("/root/Session").submit_axis(Vector2.ZERO);
 if focus_override==null:world.last_walk_position=world._local_position()
 focus_override=null;finished.emit()
