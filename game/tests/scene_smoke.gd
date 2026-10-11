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
	Input.parse_input_event(input.duplicate())
	for step:int in range(20):await physics_frame
	input.pressed=false;Input.parse_input_event(input.duplicate())
	if float(session.campaign.players[1].position[0]) <= 0.2:
		push_error("Movement input did not reach authoritative simulation");quit(1);return
	if world.camera.size != 16.0 or world.camera.position.distance_to(world._local_position()+world.CAMERA_OFFSET)>0.01:
		push_error("Closer camera did not follow the player");quit(1);return
	var distant:=InputEventKey.new();distant.keycode=KEY_E;distant.pressed=true
	root.push_input(distant,true)
	if world.dialogue.active:
		push_error("NPC opened dialogue outside interaction range");quit(1);return
	session.campaign.players[1].position=[3.0,0.0,2.0]
	for step:int in range(3):await physics_frame
	var interact:=InputEventKey.new();interact.keycode=KEY_E;interact.physical_keycode=KEY_E;interact.pressed=true
	root.push_input(interact.duplicate(),true)
	await process_frame
	interact.pressed=false;root.push_input(interact.duplicate(),true)
	if not world.dialogue.active or not world.dialogue_panel.visible:
		push_error("Nearby NPC did not open dialogue from input");quit(1);return
	var held: InputEventKey=interact.duplicate();held.pressed=true;held.echo=true
	root.push_input(held,true)
	if world.dialogue.index!=0:
		push_error("Held key skipped a dialogue line");quit(1);return
	var stopped: Array=session.campaign.players[1].position.duplicate()
	input.pressed=true;Input.parse_input_event(input.duplicate())
	for step:int in range(20):await physics_frame
	input.pressed=false;Input.parse_input_event(input.duplicate())
	if session.campaign.players[1].position != stopped or world.dialogue.index!=0:
		push_error("Dialogue allowed movement or advanced without a new interaction");quit(1);return
	for line:int in range(3):
		interact.pressed=true;root.push_input(interact.duplicate(),true)
		await process_frame
		interact.pressed=false;root.push_input(interact.duplicate(),true)
	if world.dialogue.active or world.dialogue_panel.visible:
		push_error("Manual dialogue did not close");quit(1);return
	world._turn()
	if world.battle.units.Boss.hp >= 100:
		push_error("Battle UI did not resolve turn");quit(1);return
	world._save()
	if world.message.text != "Sauvegarde : OK":
		push_error("Save button did not persist");quit(1);return
	world._load()
	if world.message.text != "Chargée":
		push_error("Load button did not restore");quit(1);return
	print("SCENE SMOKE: avatar, input, authoritative movement, closer following camera, NPC/manual dialogue/movement lock, solo battle UI, save/load exercised")
	quit(0)
