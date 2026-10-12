extends RefCounted
## Apply only changed display settings; sliders never repeatedly resize the window.
var signature: String=""
func apply(data: Dictionary,window: Window) -> void:
 var current: String=JSON.stringify([data.window_mode,data.resolution,data.fps_limit,data.vsync])
 if current==signature:return
 signature=current;Engine.max_fps=int(data.fps_limit)
 if DisplayServer.get_name()=="headless":return
 var pixels: PackedStringArray=String(data.resolution).split("x")
 window.mode=Window.MODE_WINDOWED
 window.borderless=data.window_mode=="borderless"
 window.size=Vector2i(int(pixels[0]),int(pixels[1]))
 if data.window_mode=="fullscreen":window.mode=Window.MODE_FULLSCREEN
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if data.vsync else DisplayServer.VSYNC_DISABLED)
