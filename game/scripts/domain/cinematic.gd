extends RefCounted
## Data-driven manual timeline. Completion history is owned by the campaign.
var active: bool=false
var id: String=""
var index: int=0
var replay: bool=false
var records: RefCounted
static func library() -> Dictionary:return JSON.parse_string(FileAccess.get_file_as_string("res://data/cinematics/laboratory.json"))
func begin(scene_id: String, history: RefCounted, again: bool=false) -> bool:
 var entries:=library()
 if active or not entries.has(scene_id):return false
 var entry: Dictionary=entries[scene_id]
 if again and (not entry.replayable or not history.scenes.has(scene_id)):return false
 if not again and history.scenes.has(scene_id):return false
 id=scene_id;records=history;replay=again;index=0;active=true;return true
func current() -> Dictionary:return library()[id].steps[index] if active else {}
func advance() -> void:
 if not active:return
 index+=1
 if index>=library()[id].steps.size():finish()
func skip() -> bool:
 if not active or not library()[id].skippable:return false
 finish();return true
func finish() -> void:
 if not replay:records.scenes[id]=true
 active=false
