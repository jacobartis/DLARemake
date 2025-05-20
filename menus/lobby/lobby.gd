extends Control

signal start_countdown()
signal stop_countdown()

var ready_players = {}
var selected_level:String

# Called when the node enters the scene tree for the first time.
func _ready():
	for player_id in MultiplayerManager.players.keys():
		%PlayerList.add_player(player_id,MultiplayerManager.players[player_id])
		ready_players[player_id] = false
	MultiplayerManager.connect("player_connected",add_player)
	MultiplayerManager.connect("player_disconnected",remove_player)

func _on_disconnect_pressed():
	MultiplayerManager.leave_server()

func _on_ready_pressed():
	#Tells the host you are ready
	player_ready.rpc_id(1,multiplayer.get_unique_id())

func _on_unready_pressed():
	player_unready.rpc_id(1,multiplayer.get_unique_id())

func add_player(player_id,info):
	ready_players[player_id] = false
	%PlayerList.add_player(player_id,info)

func remove_player(player_id):
	ready_players.erase(player_id)
	%PlayerList.remove_player(player_id)

@rpc("any_peer","call_local","reliable")
func player_ready(id):
	#Only the server updates the player list
	if not multiplayer.is_server(): return
	
	ready_players[id] = true
	update_ready_list.rpc(ready_players)
	check_ready.rpc()

@rpc("any_peer","call_local","reliable")
func player_unready(id):
	#Only the server updates the player list
	if not multiplayer.is_server(): return
	
	print("test {id} self {self}".format({"id":id,"self":multiplayer.get_unique_id()}))
	if not ready_players.has(id):
		print("no id {val}".format({"val":id}))
		print(ready_players)
		return
	
	ready_players[id] = false
	update_ready_list.rpc(ready_players)
	check_ready.rpc()

@rpc("any_peer","call_local","reliable")
func check_ready():
	if ready_players.values().all(func(val): return val):
		start_countdown.emit()
	else:
		stop_countdown.emit()

#Updates others with the hosts list 
@rpc("authority","call_local","reliable")
func update_ready_list(list):
	ready_players = list
	for id in ready_players:
		if ready_players[id]:
			%PlayerList.get_displayed_label(id).modulate = Color.WEB_GREEN
		else:
			%PlayerList.get_displayed_label(id).modulate = Color.WHITE

func start():
	#Server starts the game
	if not multiplayer.is_server(): return
	MultiplayerManager.load_scene.rpc(selected_level)

func _on_start_delay_timeout():
	start()


func _on_level_select_level_selected(level_id):
	selected_level = GameInfo.level_infos[level_id].level_path
