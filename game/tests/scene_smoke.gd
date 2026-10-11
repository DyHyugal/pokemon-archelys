extends SceneTree
func _initialize()->void:
	call_deferred("run")
func run()->void:
	var scene:PackedScene=load("res://main.tscn")
	var world:Node=scene.instantiate();root.add_child(world)
	await process_frame
	await process_frame
	var session:Node=root.get_node("Session")
	if world.avatars.size()!=1:
		push_error("Scene failed to instantiate avatar");quit(1);return
	var input:=InputEventKey.new();input.physical_keycode=KEY_D;input.pressed=true
	Input.parse_input_event(input)
	for step:int in range(20):await physics_frame
	input.pressed=false;Input.parse_input_event(input)
	if float(session.campaign.players[1].position[0]) <= 0.2:
		push_error("Movement input did not reach authoritative simulation");quit(1);return
	world._turn()
	if world.battle.units.Boss.hp >= 240:
		push_error("Battle UI did not resolve turn");quit(1);return
	world._save()
	if world.message.text != "Sauvegarde : OK":
		push_error("Save button did not persist");quit(1);return
	world._load()
	if world.message.text != "Chargée":
		push_error("Load button did not restore");quit(1);return
	print("SCENE SMOKE: avatar, input, authoritative movement, battle UI, save/load exercised")
	quit(0)
