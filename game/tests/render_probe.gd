extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var world: Node=load("res://main.tscn").instantiate();root.add_child(world)
	await process_frame;await process_frame
	root.get_node("Session").campaign.adventure.exploration.enter("district");world._rebuild_location()
	root.size=Vector2i(1920,1080);world.camera.size=30
	for node: Node in world.get_children():
		if node is CanvasLayer:node.visible=false
	for i: int in range(10):await RenderingServer.frame_post_draw
	var begin: int=Time.get_ticks_usec()
	for i: int in range(30):await RenderingServer.frame_post_draw
	var elapsed: float=(Time.get_ticks_usec()-begin)/1000.0
	print("RENDER PROBE: 1920x1080, 30 rendered frames, %.1f ms/frame, %.1f fps, %s" % [elapsed/30,30000.0/elapsed,RenderingServer.get_video_adapter_name()])
	world.queue_free();await process_frame;quit()
