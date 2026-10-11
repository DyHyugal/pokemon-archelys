extends Node
## Original synthesized calibration tones; no soundtrack or third-party asset.
var players: Dictionary={}
var buses: Dictionary={}
func _ready() -> void:
 for name: String in ["Music","Effects"]:
  var index:=AudioServer.get_bus_index(name)
  if index<0:
   AudioServer.add_bus();index=AudioServer.bus_count-1;AudioServer.set_bus_name(index,name);AudioServer.set_bus_send(index,"Master")
  buses[name.to_lower()]=index
  var player:=AudioStreamPlayer.new();player.bus=name;player.pitch_scale=1;add_child(player);players[name.to_lower()]=player
func apply(data: Dictionary) -> void:
 for key: String in ["master","music","effects"]:
  var index: int=0 if key=="master" else buses[key]
  var value: float=float(data[key])/100.0
  AudioServer.set_bus_mute(index,value==0)
  AudioServer.set_bus_volume_db(index,linear_to_db(maxf(value,0.0001)))
static func sample(music: bool) -> AudioStreamWAV:
 var rate:=22050;var seconds:=1.6 if music else 0.35;var count:=int(rate*seconds)
 var pcm:=PackedByteArray();pcm.resize(count*2)
 for i: int in range(count):
  var time: float=float(i)/rate;var note: int=int(time/0.4)%4
  var frequency: float=[261.63,329.63,392.0,523.25][note] if music else 660.0
  var local: float=fmod(time,0.4) if music else time
  var envelope: float=minf(1,local/0.012)*maxf(0,1-local/(0.4 if music else seconds))
  pcm.encode_s16(i*2,int(sin(TAU*frequency*time)*envelope*0.18*32767))
 var stream:=AudioStreamWAV.new();stream.format=AudioStreamWAV.FORMAT_16_BITS;stream.mix_rate=rate;stream.data=pcm;return stream
func preview(kind: String) -> void:
 if kind not in players:return
 players[kind].stream=sample(kind=="music");players[kind].play()
func stop_previews() -> void:
 for player: AudioStreamPlayer in players.values():player.stop()
