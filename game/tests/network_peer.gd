extends SceneTree
var session:Node
var role:String="host"
var port:int=24681
var elapsed:float=0.0
var passed:bool=false
var observed_players:int=0
func _initialize()->void:
	for arg:String in OS.get_cmdline_user_args():
		if arg.begins_with("--role="):role=arg.trim_prefix("--role=")
		if arg.begins_with("--port="):port=int(arg.trim_prefix("--port="))
	call_deferred("start")
func start()->void:
	session=root.get_node("Session")
	var error:Error=session.host(3,port) if role=="host" else session.join("127.0.0.1",port)
	if error!=OK:push_error(error_string(error));quit(1)
func _process(delta:float)->bool:
	elapsed+=delta
	if session==null:return false
	var state:Dictionary=session.latest
	observed_players=maxi(observed_players,state.get("players",{}).size())
	if int(state.get("progress",0))>0:
		passed=true
	if observed_players<3 and int(state.get("progress",0))>0:
		push_error("Gate opened before all three participants were observed");quit(1);return false
	var id:int=session.multiplayer.get_unique_id()
	var records:Dictionary=state.get("players",{})
	var record:Dictionary=records.get(id,records.get(str(id),{}))
	if not record.is_empty():
		var p:Array=record.position
		var direction:=Vector2(-float(p[0]),-8.0-float(p[2]))
		session.submit_axis(direction.normalized() if direction.length()>0.15 else Vector2.ZERO)
	if elapsed>8.0:
		print("NETWORK %s: players=%d, gate=%s" % [role,observed_players,passed])
		quit(0 if passed and observed_players==3 else 1)
	return false
