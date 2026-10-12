extends RefCounted
const State=preload("res://scripts/domain/demo_state.gd")
const COUNT=3
static func path(base: String,index: int) -> String:
 if index<1 or index>COUNT:return ""
 return base if index==1 else base.get_basename()+"-slot%d.json" % index
static func read(base: String,index: int,backup: bool=false) -> Dictionary:
 var file: String=path(base,index)
 if file.is_empty():return {}
 if backup:file+=".backup"
 if not FileAccess.file_exists(file):return {}
 var parser:=JSON.new()
 if parser.parse(FileAccess.get_file_as_string(file))!=OK:return {}
 return parser.data if State.validate(parser.data) else {}
