extends RefCounted
## Local preferences, never part of campaign saves or network state.
const Mon=preload("res://scripts/domain/pokemon.gd")
const KEYS={"left":[KEY_A,KEY_Q,KEY_LEFT],"right":[KEY_D,KEY_RIGHT],"up":[KEY_W,KEY_Z,KEY_UP],"down":[KEY_S,KEY_DOWN],"interact":[KEY_E],"menu":[KEY_ESCAPE],"bag":[KEY_I],"journal":[KEY_J]}
const ACTIONS=["left","right","up","down","interact","menu","bag","journal"]
const PATH="user://comfort.json"
var path: String
var data: Dictionary={"keys":{},"master":80,"music":70,"effects":80,"text_size":16}
func _init(file_path: String=PATH) -> void:
 path=file_path
 if FileAccess.file_exists(path):
  var parser:=JSON.new()
  if parser.parse(FileAccess.get_file_as_string(path))==OK and validate(parser.data):
   data=parser.data.duplicate(true)
   for field: String in ["master","music","effects","text_size"]:data[field]=int(data[field])
   for action: String in data.keys:data.keys[action]=int(data.keys[action])
static func allowed_key(code: int) -> bool:
 return (code>=KEY_A and code<=KEY_Z) or (code>=KEY_0 and code<=KEY_9) or code in [KEY_TAB,KEY_UP,KEY_DOWN,KEY_LEFT,KEY_RIGHT,KEY_SHIFT,KEY_CTRL]
static func validate(value: Variant) -> bool:
 if not value is Dictionary or not value.get("keys") is Dictionary:return false
 for field: String in ["master","music","effects"]:
  if not Mon.integer(value.get(field),0,100):return false
 if not Mon.integer(value.get("text_size"),16,24) or int(value.text_size) not in [16,20,24]:return false
 var used: Array=[]
 for action: Variant in value.keys:
  if action not in ACTIONS or not Mon.integer(value.keys[action],1,1<<24) or not allowed_key(int(value.keys[action])) or value.keys[action] in used:return false
  used.append(value.keys[action])
 # Reject conflicts with the effective defaults too, not only explicit edits.
 var effective: Dictionary={}
 for action: String in ACTIONS:
  for key: int in effective_keys(value,action):
   if effective.has(key) and effective[key]!=action:return false
   effective[key]=action
 return true
static func effective_keys(value: Dictionary,action: String) -> Array:
 return [int(value.keys[action])] if value.keys.has(action) else KEYS.get(action,[])
func keys(action: String) -> Array:return effective_keys(data,action)
func matches(event: InputEventKey,action: String) -> bool:
 var code: int=event.physical_keycode if event.physical_keycode!=0 else event.keycode
 return code in keys(action) or (action=="menu" and event.keycode==KEY_ESCAPE)
func confirming(event: InputEventKey) -> bool:
 return matches(event,"interact") or event.keycode in [KEY_ENTER,KEY_SPACE,KEY_A]
func caption(action: String) -> String:
 return " / ".join(keys(action).map(func(code: int):return OS.get_keycode_string(code)))
func bind(action: String,code: int) -> Error:
 if action not in ACTIONS or not allowed_key(code):return ERR_INVALID_PARAMETER
 var value:=data.duplicate(true);value.keys[action]=code
 return update(value)
func reset_keys() -> Error:
 var value:=data.duplicate(true);value.keys={};return update(value)
func set_value(field: String,value: int) -> Error:
 if field not in ["master","music","effects","text_size"]:return ERR_INVALID_PARAMETER
 var next:=data.duplicate(true);next[field]=value;return update(next)
func update(value: Dictionary) -> Error:
 if not validate(value):return ERR_INVALID_DATA
 var file:=FileAccess.open(path+".tmp",FileAccess.WRITE)
 if file==null:return FileAccess.get_open_error()
 file.store_string(JSON.stringify(value));file.flush();file.close()
 var error:=DirAccess.rename_absolute(path+".tmp",path)
 if error==OK:data=value.duplicate(true)
 return error
func axis() -> Vector2:
 var result:=Vector2.ZERO
 for action: String in ["left","right","up","down"]:
  if keys(action).any(func(key: int):return Input.is_physical_key_pressed(key)):
   if action=="left":result.x-=1
   if action=="right":result.x+=1
   if action=="up":result.y-=1
   if action=="down":result.y+=1
 return result.limit_length()
