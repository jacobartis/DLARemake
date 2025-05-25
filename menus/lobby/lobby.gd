extends Control

signal start_countdown()
signal stop_countdown()

var ready_players = {}
var selected_level:String

# Called when the node enters the scene tree for the first time.
func _ready():
	if multiplayer.is_server():
		MultiplayerManager.set_map("Lobby")
	else:
		%KillerCountBox.editable = false
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

@rpc("any_peer","call_local","reliable")
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
	print(selected_level)
	sort_players()
	MultiplayerManager.server_update_map(selected_level)
	MultiplayerManager.load_scene.rpc(selected_level)

func sort_players():
	var killer_number: int = %KillerCountBox.value
	var players = %PlayerList.get_children()
	
	var selected_killer = players.filter(func(p):return p.get_pref()==2)
	var selected_any = players.filter(func(p):return p.get_pref()==0)
	var selected_survivor = players.filter(func(p):return p.get_pref()==1)
	
	var killer_players = []
	var survivor_players = []
	if players.size()<=killer_number:
		killer_number = players.size()-1
	if selected_killer.size()>=killer_number:
		selected_killer.shuffle()
		for i in killer_number:
			killer_players.append(selected_killer.pop_front().player_id)
	elif (selected_killer.size()+selected_any.size())>=killer_number:
		for p in selected_killer:
			killer_players.append(p.player_id)
		for i in killer_number-killer_players.size():
			killer_players.append(selected_any.pop_front().player_id)
	else:
		for p in selected_killer:
			killer_players.append(p.player_id)
		for p in selected_any:
			killer_players.append(p.player_id)
		for i in killer_number-killer_players.size():
			killer_players.append(selected_survivor.pop_front())
	
	for p in players.filter(func(x):return not killer_players.has(x.player_id)):
		survivor_players.append(p.player_id)
	
	GameInfo.killer_players = killer_players
	GameInfo.surviver_players = survivor_players
	GameInfo.server_update()

func _on_start_delay_timeout():
	start()

func _on_level_select_level_selected(level_id):
	selected_level = GameInfo.level_infos[level_id].level_path


func _on_player_list_kicking_player(id):
	remove_player.rpc(id)
	MultiplayerManager.kick(id,"lul")
