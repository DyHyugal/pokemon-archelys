extends RefCounted
## Manual saves and automatic recovery are separate files per solo slot.
const Store=preload("res://scripts/services/save_store.gd")
const Campaign=preload("res://scripts/domain/campaign.gd")
const Mon=preload("res://scripts/domain/pokemon.gd")
var base: String="user://laboratory_campaign"
var active: int=1
var autosave: bool=true
func _init(prefix: String="user://laboratory_campaign") -> void:
 base=prefix
 var path:=base+".slots.json"
 if FileAccess.file_exists(path):
  var data: Variant=JSON.parse_string(FileAccess.get_file_as_string(path))
  if data is Dictionary and Mon.integer(data.get("active"),1,3) and data.get("autosave") is bool:active=int(data.active);autosave=data.autosave
func path(slot: int, automatic: bool=false, backup: bool=false) -> String:
 if slot<1 or slot>3:return ""
 var result:=base+("" if slot==1 else ".slot%d" % slot)+(".auto" if automatic else "")+".json"
 return result+(".backup" if backup else "")
func select(slot: int) -> Error:
 if slot<1 or slot>3:return ERR_INVALID_PARAMETER
 var previous:=active;active=slot
 var error:=persist()
 if error!=OK:active=previous
 return error
func set_autosave(enabled: bool) -> Error:
 var previous:=autosave;autosave=enabled
 var error:=persist()
 if error!=OK:autosave=previous
 return error
func persist() -> Error:
 var file:=FileAccess.open(base+".slots.json.tmp",FileAccess.WRITE)
 if file==null:return FileAccess.get_open_error()
 file.store_string(JSON.stringify({"active":active,"autosave":autosave}));file.flush();file.close()
 return DirAccess.rename_absolute(base+".slots.json.tmp",base+".slots.json")
func write(data: Dictionary, automatic: bool=false) -> Error:
 if data.get("participants")!=1 or data.get("players",{}).size()!=1:return ERR_INVALID_DATA
 return Store.write_snapshot(path(active,automatic),data)
func read(slot: int, automatic: bool=false, backup: bool=false) -> Dictionary:
 var target:=path(slot,automatic,backup)
 if target.is_empty():return {}
 var data:=Store.read_snapshot(target)
 if not data.is_empty() and (data.participants!=1 or data.players.size()!=1):return {}
 return data
func describe(slot: int, automatic: bool=false) -> Dictionary:
 var target:=path(slot,automatic)
 var value:=read(slot,automatic)
 if value.is_empty():return {"status":"invalid" if FileAccess.file_exists(target) else "empty"}
 var adventure: Dictionary=value.get("adventure",{})
 var party: Array=adventure.get("team",[])
 return {"status":"valid","modified":FileAccess.get_modified_time(target),"location":adventure.get("exploration",{}).get("location","village"),"level":party[0].level if not party.is_empty() else 0,"species":party[0].species if not party.is_empty() else "","schema":value.schema}
