extends RefCounted
## Portable local saves only. Parsing is bounded; invalid imports never mutate state.
const State=preload("res://scripts/domain/demo_state.gd")
const LIMIT=4*1024*1024
static func read_file(path: String) -> Dictionary:
 var file:=FileAccess.open(path,FileAccess.READ)
 if not file or file.get_length()>LIMIT:return {}
 var parser:=JSON.new()
 if parser.parse(file.get_as_text())!=OK or not State.validate(parser.data):return {}
 return parser.data
static func export_file(state: RefCounted,path: String) -> Error:
 if state.campaign.adventure.in_battle or not State.validate(state.snapshot()):return ERR_BUSY
 var file:=FileAccess.open(path+".tmp",FileAccess.WRITE)
 if not file:return FileAccess.get_open_error()
 file.store_string(JSON.stringify(state.snapshot()));file.flush();file.close()
 if read_file(path+".tmp").is_empty():return ERR_INVALID_DATA
 return DirAccess.rename_absolute(path+".tmp",path)
static func inspect(path: String) -> Dictionary:
 if not FileAccess.file_exists(path):return {"status":"empty"}
 var data:=read_file(path)
 if data.is_empty():return {"status":"invalid"}
 return {"status":"valid","starter":data.starter,"location":data.location,"money":data.campaign.adventure.money,"team":data.campaign.adventure.team.size(),"modified":FileAccess.get_modified_time(path)}
