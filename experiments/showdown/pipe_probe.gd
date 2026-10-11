extends SceneTree
## Headless feasibility test, deliberately blocking; never called from game UI.
var checks: int=0
var failures: int=0
var child: Dictionary={}
func check(ok: bool,label: String) -> void:
 checks+=1
 if not ok:failures+=1;push_error(label)
func request(payload: Dictionary) -> Dictionary:
 var pipe: FileAccess=child.stdio
 pipe.store_line(JSON.stringify(payload));pipe.flush()
 var response: Variant=JSON.parse_string(pipe.get_line())
 if not response is Dictionary:return {"ok":false,"error":"invalid JSON response"}
 return response
func _initialize() -> void:
 var args: PackedStringArray=OS.get_cmdline_user_args()
 if args.size()!=2:push_error("Pass absolute Node path and probe.cjs path after --");quit(1);return
 if not FileAccess.file_exists(args[0]) or not FileAccess.file_exists(args[1]):push_error("Node or probe path missing");quit(1);return
 child=OS.execute_with_pipe(args[0],PackedStringArray([args[1],"--bridge"]),true)
 if child.is_empty():push_error("Unable to launch Node subprocess");quit(1);return
 var begin:=Time.get_ticks_msec()
 var started:=request({"op":"start"})
 check(started.get("ok",false) and started.get("actors")==4 and started.get("turn")==1,"Godot starts real Showdown doubles over local stdin/stdout")
 var played:=request({"op":"choose","p1":"move surf, move protect","p2":"move splash, move splash"})
 check(played.get("ok",false) and played.get("turn")==2,"Godot sends a complete turn and receives resolved simulator state")
 check(played.get("pp")==14 and played.hp[1]==played.maxhp[1],"Godot receives one-PP Surf consumption and protected ally HP")
 var invalid:=request({"op":"choose","p1":"move 99, move protect","p2":"move splash, move splash"})
 check(not invalid.get("ok",true) and invalid.error.contains("Invalid choice"),"Rejected engine command returns structured error instead of crashing host")
 var restart:=request({"op":"start"})
 check(restart.get("turn")==1 and restart.get("pp")==15,"Same local process can restart a fresh independent battle")
 var ended:=request({"op":"quit"})
 check(ended.get("closed",false),"Clean child shutdown acknowledged")
 var elapsed: int=Time.get_ticks_msec()-begin
 child.stdio.close();child.stderr.close()
 print("SHOWDOWN PIPE: %d checks, %d failures; startup+turn+error+restart+shutdown %d ms" % [checks,failures,elapsed])
 quit(1 if failures else 0)
