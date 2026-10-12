extends Node
## Local child process. Blocking pipe I/O happens on a worker, never in the render loop.
signal reply(payload: Dictionary)
signal failed(reason: String)
var child: Dictionary={}
var worker:=Thread.new()
var received: Dictionary={}
var pending: bool=false
var started_at: int=0
var request_id: int=0
var stopped: bool=false
var last_error: String=""
var runtime_base: String=""
static func resolve(base: String,windows: bool,node_override: String="") -> Dictionary:
 var script: String=base.path_join("showdown/bridge.cjs")
 var executable: String=base.path_join("runtime/node.exe") if windows else node_override
 if executable.is_empty():executable=base.path_join("runtime/node")
 if not FileAccess.file_exists(script):return {"error":"Bridge absent : "+script}
 if not FileAccess.file_exists(base.path_join("showdown/upstream/dist/sim/index.js")):return {"error":"Données Showdown absentes : "+base.path_join("showdown/upstream")}
 if not FileAccess.file_exists(executable):return {"error":"Node absent : "+executable}
 return {"script":script,"executable":executable,"error":""}
func start() -> bool:
 # Godot4 exports carry 'template', not the obsolete 'standalone' feature.
 runtime_base=OS.get_executable_path().get_base_dir() if OS.has_feature("template") else ProjectSettings.globalize_path("res://../builds")
 var paths: Dictionary=resolve(runtime_base,OS.get_name()=="Windows",OS.get_environment("ARCHELYS_NODE_BIN"))
 last_error=paths.error
 if last_error.is_empty():
  child=OS.execute_with_pipe(paths.executable,PackedStringArray([paths.script]),true)
  if child.is_empty():last_error="Windows/OS refuse le lancement de Node : "+paths.executable
 var file:=FileAccess.open("user://showdown-diagnostic.log",FileAccess.WRITE)
 if file:file.store_string("OS="+OS.get_name()+"\ntemplate="+str(OS.has_feature("template"))+"\nbase="+runtime_base+"\n"+last_error+"\n")
 return last_error.is_empty()

func send(payload: Dictionary) -> bool:
 if stopped or pending or child.is_empty():return false
 request_id+=1;payload=payload.duplicate(true);payload.id=request_id;payload.protocol=1
 var line:=JSON.stringify(payload)
 if line.length()>65536:return false
 pending=true;started_at=Time.get_ticks_msec()
 if worker.start(_exchange.bind(line))!=OK:pending=false;return false
 return true
func _exchange(line: String) -> void:
 var pipe: FileAccess=child.stdio
 pipe.store_line(line);pipe.flush()
 # Read a bounded response: no unbounded get_line allocation from the child.
 var bytes:=PackedByteArray()
 while bytes.size()<262144:
  var chunk:=pipe.get_buffer(1)
  if chunk.is_empty():break
  if chunk[0]==10:break
  bytes.append(chunk[0])
 var parsed: Variant=JSON.parse_string(bytes.get_string_from_utf8()) if not bytes.is_empty() else null
 var reason: String="Invalid or closed simulator response"
 received=parsed if parsed is Dictionary else {"id":request_id,"ok":false,"fatal":true,"error":reason}
func _process(_delta: float) -> void:
 if not pending:return
 if Time.get_ticks_msec()-started_at>10000:
  stop();failed.emit("Simulator timed out; battle cancelled");return
 if worker.is_alive():return
 worker.wait_to_finish();pending=false
 if received.get("id")!=request_id:
  stop();failed.emit("Simulator response identity mismatch");return
 if received.get("fatal",false):stop(false);failed.emit(str(received.error));return
 reply.emit(received)
func stop(kill_process: bool=true) -> void:
 if stopped:return
 stopped=true
 if not child.is_empty():
  if kill_process:OS.kill(int(child.pid))
  if worker.is_started():worker.wait_to_finish()
  child.stdio.close();child.stderr.close();child.clear()
 pending=false
func _exit_tree() -> void:stop()
