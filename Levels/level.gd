extends Node2D

@export var players_container: Node2D
@export var player_scene: PackedScene
@export var spawn_points: Array[Node2D]

var next_spawn_point: int = 0


func _ready() -> void:
	if not multiplayer.is_server():
		return

	# Enable for late game connections to work
	# multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)

	for player_id in multiplayer.get_peers():
		add_player(player_id)

	add_player(1)


func _exit_tree() -> void:
	if multiplayer.multiplayer_peer == null:
		return
	if not multiplayer.is_server():
		return

	# multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(remove_player)


func add_player(player_id: int) -> void:
	var player_instance: Player = player_scene.instantiate()
	player_instance.name = str(player_id)
	players_container.add_child(player_instance)
	player_instance.position = get_spawn_point()


func remove_player(player_id: int) -> void:
	if not players_container.has_node(str(player_id)):
		return

	players_container.get_node(str(player_id)).queue_free()


func get_spawn_point() -> Vector2:
	var spawn_point: Vector2 = spawn_points[next_spawn_point].position

	next_spawn_point += 1
	if next_spawn_point >= spawn_points.size():
		next_spawn_point = 0
	
	return spawn_point
