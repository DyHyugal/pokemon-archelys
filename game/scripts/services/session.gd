extends Node

const World = preload("res://scripts/domain/world_rules.gd")
const Campaign = preload("res://scripts/domain/campaign.gd")
var campaign := Campaign.new()
var axes: Dictionary = {}
var received_at: Dictionary = {}
var latest: Dictionary = {}
var active_network: bool = false
var gate_latched: bool = false
var elapsed: float = 0.0
var bind_address: String = "127.0.0.1"
const PORT: int = 24680

func _ready() -> void:
	campaign.add_player(1, "Joueur 1")
	latest = campaign.snapshot()
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	multiplayer.server_disconnected.connect(_server_left)

func host(count: int, port: int = PORT) -> Error:
	var peer := ENetMultiplayerPeer.new()
	peer.set_bind_ip(bind_address)
	var error := peer.create_server(port, 2)
	if error != OK:
		return error
	multiplayer.multiplayer_peer = peer
	campaign = Campaign.new()
	campaign.configure(count)
	campaign.add_player(1, "Hôte")
	axes.clear()
	received_at.clear()
	gate_latched = false
	active_network = true
	return OK

func join(address: String, port: int = PORT) -> Error:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(address, port)
	if error == OK:
		multiplayer.multiplayer_peer = peer
		active_network = true
	return error

func _peer_connected(id: int) -> void:
	if multiplayer.is_server():
		if not campaign.add_player(id, "Invité %d" % id):
			(multiplayer.multiplayer_peer as ENetMultiplayerPeer).disconnect_peer(id)

func _peer_disconnected(id: int) -> void:
	if multiplayer.is_server():
		campaign.players.erase(id)
		axes.erase(id)
		received_at.erase(id)
		gate_latched = false

func _server_left() -> void:
	active_network = false
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	campaign = Campaign.new()
	campaign.add_player(1, "Solo")
	latest = campaign.snapshot()

func submit_axis(value: Vector2) -> void:
	if multiplayer.is_server():
		axes[1] = value.limit_length()
	elif multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		_move.rpc_id(1, value)

@rpc("any_peer", "call_remote", "unreliable")
func _move(value: Vector2) -> void:
	if not multiplayer.is_server() or not value.is_finite():
		return
	var id := multiplayer.get_remote_sender_id()
	if campaign.players.has(id):
		axes[id] = value.limit_length()
		received_at[id] = Time.get_ticks_msec()

@rpc("authority", "call_remote", "unreliable")
func _snapshot(value: Dictionary) -> void:
	if Campaign.validate(value):
		latest = value.duplicate(true)

func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	for id: Variant in campaign.players:
		var axis: Vector2 = axes.get(id, Vector2.ZERO)
		if int(id) != 1 and Time.get_ticks_msec() - int(received_at.get(id, 0)) > 500:
			axis = Vector2.ZERO
		var record: Dictionary = campaign.players[id]
		var pos: Array = record.position
		var next_x := clampf(float(pos[0]) + axis.x * 5.0 * delta, -14.0, 14.0)
		var next_z := clampf(float(pos[2]) + axis.y * 5.0 * delta, -10.0, 10.0)
		if _can_step(Vector2(float(pos[0]),float(pos[2])),Vector2(next_x,float(pos[2]))):
			pos[0] = next_x
		if _can_step(Vector2(float(pos[0]),float(pos[2])),Vector2(float(pos[0]),next_z)):
			pos[2] = next_z
	if campaign.adventure.exploration.location=="village" and campaign.all_at_gate():
		if not gate_latched and campaign.progress == 0:
			campaign.advance()
			gate_latched = true
	else:
		gate_latched = false
	latest = campaign.snapshot()
	elapsed += delta
	if active_network and elapsed >= 0.1:
		elapsed = 0.0
		_snapshot.rpc(latest)

func _can_step(origin: Vector2,destination: Vector2) -> bool:
	var location: String=campaign.adventure.exploration.location
	if location=="cove" and campaign.adventure.exploration.cleared.has("surf"):return absf(destination.x)<7 and destination.y>-8 and destination.y<9
	if location=="village":
		if float(campaign.players.get(1,{}).get("position",[0,0,0])[1])>0:return absf(destination.x+11)<1.45 and destination.y>8.05 and destination.y<9.95
		if absf(destination.x+11)<1.5 and destination.y>8:return false
		for id: String in ["cut","rock-smash","strength"]:
			var point: Vector3=World.local_points(location)[id]
			if not campaign.adventure.exploration.cleared.has(id) and destination.distance_to(Vector2(point.x,point.z))<0.7:return false
		for id: String in World.SERVICE_POINTS:
			var at: Vector3=World.SERVICE_POINTS[id]
			if destination.distance_to(Vector2(at.x,at.z))<0.4:return false
		return World.can_step(origin,destination)
	if campaign.adventure.island.blocked(destination,location):return false
	return World.local_walkable(destination,location)
