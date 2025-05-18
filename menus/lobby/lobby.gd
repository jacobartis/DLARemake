extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	if multiplayer.is_server(): name = "server_host"
	for player_id in MultiplayerManager.players.keys():
		%PlayerList.add_player(player_id,MultiplayerManager.players[player_id])
	MultiplayerManager.connect("player_connected",%PlayerList.add_player)
	MultiplayerManager.connect("player_disconnected",%PlayerList.remove_player)
	if not multiplayer.is_server():
		%Start.queue_free()

func _on_disconnect_pressed():
	MultiplayerManager.leave_server()

func _on_start_pressed():
	MultiplayerManager.load_scene.rpc("res://level/world.tscn")
