extends RefCounted
## Local preferences, never part of campaign saves or network state.
const Mon=preload("res://scripts/domain/pokemon.gd")
const KEYS={"left":[KEY_A,KEY_Q,KEY_LEFT],"right":[KEY_D,KEY_RIGHT],"up":[KEY_W,KEY_Z,KEY_UP],"down":[KEY_S,KEY_DOWN],"interact":[KEY_E],"menu":[KEY_ESCAPE],"bag":[KEY_I],"journal":[KEY_J],"run":[KEY_SHIFT]}
const ACTIONS=["left","right","up","down","interact","menu","bag","journal","run"]
const PATH="user://comfort.json"
const EXTRA={"game_speed":1,"window_mode":"windowed","resolution":"1280x720","fps_limit":0,"vsync":true,"combat_animations":true,"reduced_motion":false,"world_labels":true}
var path: String
var data: Dictionary={"keys":{},"master":80,"music":70,"effects":80,"text_size":16,"theme":"dark"}
func _init(file_path: String=PATH) -> void:
 path=file_path
 var has_saved_speed:=false
 data.merge(EXTRA,true)
 if FileAccess.file_exists(path):
  var parser:=JSON.new()
  if parser.parse(FileAccess.get_file_as_string(path))==OK and validate(parser.data):
   has_saved_speed=parser.data.has("game_speed")
   data=parser.data.duplicate(true)
   data.theme=parser.data.get("theme","dark")
   for field: String in EXTRA:data[field]=parser.data.get(field,EXTRA[field])
   for field: String in ["master","music","effects","text_size"]:data[field]=int(data[field])
   data.fps_limit=int(data.fps_limit)
   data.game_speed=int(data.game_speed)
   for action: String in data.keys:data.keys[action]=int(data.keys[action])
 # Migrate the old global speed file only for the real default preferences.
 # Custom test/profile paths remain independent; existing volume/key data is kept.
 if path==PATH and not has_saved_speed and FileAccess.file_exists("user://laboratory_speed.json"):
  var parser:=JSON.new()
  if parser.parse(FileAccess.get_file_as_string("user://laboratory_speed.json"))==OK and Mon.integer(parser.data,1,4):data.game_speed=int(parser.data)
static func allowed_key(code: int) -> bool:
 return (code>=KEY_A and code<=KEY_Z) or (code>=KEY_0 and code<=KEY_9) or code in [KEY_TAB,KEY_UP,KEY_DOWN,KEY_LEFT,KEY_RIGHT,KEY_SHIFT,KEY_CTRL]
static func validate(value: Variant) -> bool:
 if not value is Dictionary or not value.get("keys") is Dictionary:return false
 if not Mon.integer(value.get("game_speed",1),1,4):return false
 if value.get("theme","dark") not in ["dark","light","contrast"]:return false
 for field: String in ["master","music","effects"]:
  if not Mon.integer(value.get(field),0,100):return false
 if not Mon.integer(value.get("text_size"),16,24) or int(value.text_size) not in [16,20,24]:return false
 if value.get("window_mode","windowed") not in ["windowed","borderless","fullscreen"] or value.get("resolution","1280x720") not in ["1280x720","1600x900","1920x1080"]:return false
 if not Mon.integer(value.get("fps_limit",0),0,120) or int(value.get("fps_limit",0)) not in [0,30,60,120]:return false
 for field: String in ["vsync","combat_animations","reduced_motion","world_labels"]:
  if not value.get(field,EXTRA[field]) is bool:return false
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
 # Preserve a legacy custom Shift binding: sprint stays unassigned until remapped.
 if action=="run" and not value.keys.has("run"):
  for other: String in value.keys:
   if other!="run" and int(value.keys[other])==KEY_SHIFT:return []
 return [int(value.keys[action])] if value.keys.has(action) else KEYS.get(action,[])
func keys(action: String) -> Array:return effective_keys(data,action)
func matches(event: InputEventKey,action: String) -> bool:
 var code: int=event.physical_keycode if event.physical_keycode!=0 else event.keycode
 return code in keys(action) or (action=="menu" and event.keycode==KEY_ESCAPE)
func confirming(event: InputEventKey) -> bool:
 return matches(event,"interact") or event.keycode in [KEY_ENTER,KEY_SPACE,KEY_A]
func caption(action: String) -> String:
 return "—" if keys(action).is_empty() else " / ".join(keys(action).map(func(code: int):return OS.get_keycode_string(code)))
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
 var pads: Array=Input.get_connected_joypads()
 if not pads.is_empty():
  var pad: int=pads[0]
  var stick:=Vector2(Input.get_joy_axis(pad,JOY_AXIS_LEFT_X),Input.get_joy_axis(pad,JOY_AXIS_LEFT_Y))
  result+=preload("res://scripts/services/controller_input.gd").stick(stick)
  result+=Vector2(int(Input.is_joy_button_pressed(pad,JOY_BUTTON_DPAD_RIGHT))-int(Input.is_joy_button_pressed(pad,JOY_BUTTON_DPAD_LEFT)),int(Input.is_joy_button_pressed(pad,JOY_BUTTON_DPAD_DOWN))-int(Input.is_joy_button_pressed(pad,JOY_BUTTON_DPAD_UP)))
 return result.limit_length()

func set_theme(value: String) -> Error:
 var next:=data.duplicate(true);next.theme=value;return update(next)

func set_option(field: String,value: Variant) -> Error:
 if field not in EXTRA:return ERR_INVALID_PARAMETER
 var next:=data.duplicate(true);next[field]=value;return update(next)

func wants_run(pad: int=-1) -> bool:
 if keys("run").any(func(code: int):return Input.is_physical_key_pressed(code)):return true
 if pad<0:
  var pads: Array=Input.get_connected_joypads()
  if pads.is_empty():return false
  pad=int(pads[0])
 return Input.is_joy_button_pressed(pad,JOY_BUTTON_RIGHT_SHOULDER)
