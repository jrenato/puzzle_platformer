extends Control

@export var ip_line_edit: LineEdit
@export var status_label: Label


func _ready() -> void:
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)


func _process(delta: float) -> void:
	pass


func _on_host_button_pressed() -> void:
	Lobby.create_game()


func _on_join_button_pressed() -> void:
	Lobby.join_game(ip_line_edit.text)

	status_label.text = "Connecting..."


func _on_start_button_pressed() -> void:
	pass


func _on_connection_failed() -> void:
	status_label.text = "Connection failed"


func _on_connected_to_server() -> void:
	status_label.text = "Connected"
