extends SceneTree
const Comfort=preload("res://scripts/services/comfort_store.gd")
const Audio=preload("res://scripts/services/laboratory_audio.gd")
var failures:=0
var checks:=0
func check(ok: bool,label: String) -> void:
 checks+=1
 if not ok:failures+=1;push_error(label)
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var path: String="user://tests_comfort.json";DirAccess.remove_absolute(path)
 var prefs:=Comfort.new(path)
 check(Comfort.validate(prefs.data) and prefs.keys("left")==[KEY_A,KEY_Q,KEY_LEFT],"Defaults preserve original keyboard aliases")
 check(prefs.bind("interact",KEY_F)==OK and Comfort.new(path).keys("interact")==[KEY_F],"Rebinding persists effective key")
 var before:=FileAccess.get_file_as_string(path)
 check(prefs.bind("bag",KEY_F)==ERR_INVALID_DATA and FileAccess.get_file_as_string(path)==before,"Duplicate explicit key leaves valid file intact")
 check(prefs.bind("left",KEY_D)==ERR_INVALID_DATA,"Conflict with another action's default rejected")
 check(prefs.bind("menu",KEY_ESCAPE)==ERR_INVALID_PARAMETER and prefs.bind("interact",KEY_ENTER)==ERR_INVALID_PARAMETER and prefs.bind("interact",KEY_F3)==ERR_INVALID_PARAMETER,"Safety/confirm/debug keys reserved")
 check(prefs.bind("menu",KEY_M)==OK,"Menu can be rebound")
 var event:=InputEventKey.new();event.keycode=KEY_ESCAPE
 check(prefs.matches(event,"menu"),"Escape remains permanent safe fallback")
 event.physical_keycode=KEY_F;event.keycode=KEY_G
 check(prefs.matches(event,"interact"),"Binding follows physical key independently of logical layout")
 event.physical_keycode=0;event.keycode=KEY_E
 check(not prefs.matches(event,"interact") and not prefs.confirming(event),"Replaced old interaction key no longer confirms")
 event.keycode=KEY_ENTER;check(prefs.confirming(event),"Enter stays available for confirmation")
 check(prefs.set_value("music",0)==OK and prefs.set_value("text_size",24)==OK,"Audio and readability settings persisted")
 check(prefs.reset_keys()==OK and prefs.data.music==0 and prefs.data.text_size==24 and prefs.keys("menu")==[KEY_ESCAPE],"Key reset preserves audio and readability")
 before=FileAccess.get_file_as_string(path)
 check(prefs.set_value("master",101)==ERR_INVALID_DATA and prefs.set_value("text_size",999)==ERR_INVALID_DATA and FileAccess.get_file_as_string(path)==before,"Invalid volumes/text size cannot replace preferences")
 var file:=FileAccess.open(path,FileAccess.WRITE);file.store_string("broken");file.close()
 check(Comfort.new(path).data==Comfort.new("user://missing_comfort_defaults.json").data,"Corrupt preference file recovers to safe defaults")
 var audio:=Audio.new();root.add_child(audio);await process_frame
 var settings:=Comfort.new("user://missing_comfort_defaults.json").data
 audio.apply(settings)
 check(is_equal_approx(AudioServer.get_bus_volume_linear(0),0.8) and is_equal_approx(AudioServer.get_bus_volume_linear(audio.buses.music),0.7),"Real audio bus gain follows percentages")
 settings.effects=0;audio.apply(settings)
 check(AudioServer.is_bus_mute(audio.buses.effects) and not AudioServer.is_bus_mute(audio.buses.music),"Zero effects mutes only effects bus")
 settings.master=0;audio.apply(settings);check(AudioServer.is_bus_mute(0),"Zero master mutes entire audio output")
 settings.master=80;settings.effects=80;audio.apply(settings)
 check(not AudioServer.is_bus_mute(0) and not AudioServer.is_bus_mute(audio.buses.effects),"Raising volume restores previously muted buses")
 var music:=Audio.sample(true);var fx:=Audio.sample(false)
 check(music.mix_rate==22050 and music.data.size()>fx.data.size() and Array(fx.data).any(func(value: int):return value!=0),"Original PCM samples have actual non-silent data and distinct durations")
 Engine.time_scale=4;audio.preview("music")
 check(audio.players.music.playing and audio.players.music.pitch_scale==1 and AudioServer.playback_speed_scale==1,"Speed4 does not alter audio pitch or audio server playback rate")
 await create_timer(0.2).timeout
 audio.preview("effects");await create_timer(0.2).timeout;audio.stop_previews();check(not audio.players.music.playing and not audio.players.effects.playing,"Stop control stops both calibration players")
 Engine.time_scale=1;music=null;fx=null;audio.free()
 await create_timer(0.1).timeout # Allow the audio thread to release stopped playback buffers.
 print("COMFORT SYSTEMS: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
