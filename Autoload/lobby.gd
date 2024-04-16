extends Node

signal player_connected(peer_id: int, player_info: Dictionary)
signal player_disconnected(peer_id: int)
signal server_disconnected

const PORT: int = 7000
const MAX_CONNECTIONS: int = 2

var players: Dictionary = {}

var player_info: Dictionary = {
	"name": "Name",
}


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func create_game() -> int:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: int = peer.create_server(PORT, MAX_CONNECTIONS)

	if error != OK:
		print(error)
		return error

	multiplayer.multiplayer_peer = peer

	players[1] = player_info
	player_connected.emit(1, player_info)

	return OK


func join_game(address: String) -> int:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: int = peer.create_client(address, PORT)

	if error != OK:
		return error

	multiplayer.multiplayer_peer = peer

	return OK


func _on_player_connected(peer_id: int) -> void:
	_register_player.rpc_id(peer_id, player_info)


@rpc("any_peer", "reliable")
func _register_player(new_player_info: Dictionary) -> void:
	var new_peer_id: int = multiplayer.get_remote_sender_id()
	players[new_peer_id] = new_player_info
	player_connected.emit(new_peer_id, new_player_info)


func _on_player_disconnected(peer_id: int) -> void:
	players.erase(peer_id)
	player_disconnected.emit(peer_id)


func _on_connected_to_server() -> void:
	var peer_id: int = multiplayer.get_unique_id()

	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)


func _on_connection_failed() -> void:
	multiplayer.multiplayer_peer = null


func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
