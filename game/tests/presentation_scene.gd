extends SceneTree
const Comfort=preload("res://scripts/services/comfort_store.gd")
const AvatarStyle=preload("res://scripts/world/avatar_style.gd")
var checks:=0
var failures:=0
func check(value: bool,message: String) -> void:
 checks+=1
 if not value:failures+=1;push_error(message)
func press(menu: CanvasLayer,text: String) -> bool:
 for node: Node in menu.body.get_children():
  if node is Button and node.text.contains(text):node.pressed.emit();return true
 return false
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var world: Node=load("res://main.tscn").instantiate();world.preferences_path="user://tests_presentation_prefs.json";world.comfort=Comfort.new("user://tests_presentation_scene_comfort.json");root.add_child(world)
 await process_frame;await process_frame;world._set_locale("fr")
 var a: RefCounted=world.get_node("/root/Session").campaign.adventure;var original: Dictionary=a.snapshot()
 world._open_menu("appearance")
 var style: OptionButton=world.pause_menu.body.get_node("Appearance_style");style.select(2);style.item_selected.emit(2)
 var skin: OptionButton=world.pause_menu.body.get_node("Appearance_skin");skin.select(3);skin.item_selected.emit(3)
 check(a.appearance.style==2 and a.appearance.skin==3,"Actual character controls update campaign")
 var avatar: Node3D=world.avatars.values()[0]
 var look: BoneAttachment3D=avatar.get_node("PrototypeLook")
 check(look.bone_name=="Head" and look.use_external_skeleton and look.find_child("Hair",true,false)!=null,"Prototype hairstyle attaches to rig Head bone")
 var head: MeshInstance3D=avatar.find_child("Mannequin_Head",true,false)
 check(head!=null and head.material_override.albedo_color==Color("452f29"),"Actual avatar skin material changes")
 check(a.team==original.team and a.bag==original.bag,"Character menu leaves party and bag intact")
 var saved: Dictionary=world.get_node("/root/Session").campaign.snapshot();a.set_appearance("skin",0)
 world.get_node("/root/Session").campaign.restore(saved);world._apply_appearance()
 check(avatar.find_child("Mannequin_Head",true,false).material_override.albedo_color==Color("452f29"),"Restored campaign reapplies rendered appearance")
 world._open_menu("settings")
 var theme: OptionButton=world.pause_menu.body.get_node("InterfaceTheme");theme.select(1);theme.item_selected.emit(1)
 check(world.ui_theme.get_color("font_color","Label").srgb_to_linear().get_luminance()<0.1 and world.pause_menu.panel.theme==world.ui_theme,"Settings apply light palette to real menu")
 if DisplayServer.get_name()!="headless":
  for arg: String in OS.get_cmdline_user_args():
   if arg.begins_with("--ui-proof="):
    await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(arg.trim_prefix("--ui-proof="))
 world._open_menu("photo");var transform: Transform3D=world.camera.transform;var distance: float=world.camera.size
 check(press(world.pause_menu,"Ouvrir le mode photo") and world.photo_mode.active and not world.gameplay_layer.visible and not world.pause_menu.visible,"Actual Photo button enters modal view and hides HUD")
 var state: String=JSON.stringify(world.get_node("/root/Session").campaign.snapshot())
 var photo_sliders: Array=world.photo_mode.panel.get_child(0).get_children().filter(func(node: Node):return node is HSlider)
 photo_sliders[0].value=5;photo_sliders[1].value=90;await process_frame
 check(world.camera.size==5 and world.camera.transform!=transform,"Photo controls update actual camera")
 check(not world._open_interaction("guide") and not world._contextual_action("crate"),"Photo blocks world interactions and rewards")
 world._travel("cove");world._open_menu("home");world._play_scene("lab-tour");world._slot_action("new",1)
 check(world.photo_mode.active and not world.pause_menu.visible and not world.cinematic.active and JSON.stringify(world.get_node("/root/Session").campaign.snapshot())==state,"Photo blocks travel/menu/cinematics/new campaign without altering save")
 if DisplayServer.get_name()=="headless":
  world.photo_mode.capture();check(not world.photo_mode.saving and world.photo_mode.feedback.text.contains("indisponible"),"Headless export explicitly refused")
 else:
  world.photo_mode.destination="user://tests_photo_render";world.photo_mode.capture()
  while world.photo_mode.saving:await process_frame
  var file: String=world.photo_mode.last_file;var image:=Image.load_from_file(file)
  check(image!=null and image.get_size()==root.size and world.photo_mode.active,"Actual rendered PNG capture exports viewport and restores photo controls")
  for arg: String in OS.get_cmdline_user_args():
   if arg.begins_with("--photo-proof="):image.save_png(arg.trim_prefix("--photo-proof="))
  DirAccess.remove_absolute(file)
 var event:=InputEventKey.new();event.keycode=KEY_ESCAPE;event.pressed=true;world._input(event)
 check(not world.photo_mode.active and world.gameplay_layer.visible and world.pause_menu.visible and world.pause_menu.page=="photo" and world.camera.transform==transform and world.camera.size==distance,"Escape restores camera/HUD/menu exactly")
 world._set_locale("en");world._open_menu("appearance")
 check(world.pause_menu.body.get_children().any(func(node: Node):return node is Label and node.text=="Skin"),"Character controls localize in English")
 world.queue_free();await process_frame
 print("PRESENTATION SCENE: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
