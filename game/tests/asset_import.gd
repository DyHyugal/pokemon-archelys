extends SceneTree
func _initialize()->void:
	var resource:PackedScene=load("res://assets/prototypes/mannequin.glb")
	if resource==null:quit(1);return
	var model:Node=resource.instantiate();root.add_child(model)
	var animator:AnimationPlayer=model.find_child("AnimationPlayer",true,false)
	var skeleton:Skeleton3D=model.find_child("Skeleton3D",true,false)
	# Imported node naming is not a stable contract, use type fallback.
	if skeleton==null:
		for child:Node in model.find_children("*","Skeleton3D",true,false):skeleton=child as Skeleton3D
	if animator==null or skeleton==null or skeleton.get_bone_count()<7:
		push_error("Rig or animation not imported");quit(1);return
	var actions:PackedStringArray=animator.get_animation_list()
	if actions.is_empty():push_error("Animation missing");quit(1);return
	animator.play(actions[-1]);animator.advance(0.25)
	print("GLB IMPORT: %d bones, %d animation(s), playback exercised" % [skeleton.get_bone_count(),actions.size()])
	quit(0)
