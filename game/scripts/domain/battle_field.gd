extends RefCounted
## Generation IX subset, independent weather and terrain timers.
var weather: String=""
var weather_turns: int=0
var terrain: String=""
var terrain_turns: int=0
func set_weather(value: String) -> void:weather=value;weather_turns=5
func set_terrain(value: String) -> void:terrain=value;terrain_turns=5
func tick() -> Array:
	var ended: Array=[]
	if weather_turns>0:
		weather_turns-=1
		if weather_turns==0:ended.append(weather);weather=""
	if terrain_turns>0:
		terrain_turns-=1
		if terrain_turns==0:ended.append(terrain);terrain=""
	return ended
func power(move_type: String, grounded_attacker: bool, grounded_target: bool) -> float:
	var factor: float=1.0
	if weather=="sun":
		if move_type=="fire":factor*=1.5
		if move_type=="water":factor*=0.5
	if weather=="rain":
		if move_type=="water":factor*=1.5
		if move_type=="fire":factor*=0.5
	if grounded_attacker and ((terrain=="electric" and move_type=="electric") or (terrain=="grass" and move_type=="grass") or (terrain=="psychic" and move_type=="psychic")):factor*=1.3
	if terrain=="misty" and grounded_target and move_type=="dragon":factor*=0.5
	return factor
