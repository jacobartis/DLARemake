extends Node

#Test lobby using the godot example implementation
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected()
signal server_stopped()
signal all_loaded()

var port = 7000
const DEFAULT_SERVER_IP = "127.0.0.1"

var steam_peer = SteamMultiplayerPeer.new()
var lobby_id = 0

var max_players = 4

#Contains player unique ids
var players:Dictionary[int,Dictionary] = {}

#Contains local info for players
var player_info = {"name": "Name"}

#Player recieves call to update
@rpc("any_peer", "call_local", "reliable")
func server_update_info():
	set_info.rpc(players)

#Server sends info to players
@rpc("any_peer", "call_local", "reliable")
func set_info(new:Dictionary[int,Dictionary]):
	players = new

@rpc("any_peer", "call_local", "reliable")
func add_player_info(id:int,new_info:Dictionary):
	players[id] = new_info
	server_update_info()

func remove_player_info(id):
	if not players.has(id): return
	players.erase(id)
	server_update_info()

var players_loaded = 0

func lobby_size():
	return players.size()

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	steam_peer.lobby_created.connect(_on_lobby_created)
	steam_peer.network_session_failed.connect(_on_server_disconnected)

func display_err_msg(msg:String):
	get_tree().get_first_node_in_group("err_label").text = msg

func join_ip_server(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

func create_ip_server():
	#Generates local server, aborts if errors
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port,max_players)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	#Assigns player id 1 to player making the server
	add_player_info(1,player_info)
	player_connected.emit(1,player_info)

func create_steam_server():
	var err = steam_peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	if err!=OK: return err
	multiplayer.multiplayer_peer = steam_peer
	add_player_info(1,player_info)
	player_connected.emit(1,player_info)

func join_steam_server(id):
	steam_peer.connect_lobby(id)
	multiplayer.multiplayer_peer = steam_peer

func _on_lobby_created(con,id):
	if con != Steam.Result.RESULT_OK: 
		return
	lobby_id = id
	Steam.setLobbyData(lobby_id,"name",str(Steam.getPersonaName()+"'s Lobby"))
	Steam.setLobbyJoinable(lobby_id,true)

func leave_server():
	if multiplayer.is_server():
		players.clear()
		emit_signal("server_stopped")
	remove_multiplayer_peer()
	load_scene("res://menus/main_menu.tscn")

func remove_multiplayer_peer():
	if steam_peer.get_lobby_id()!=0:
		steam_peer.close()
	multiplayer.multiplayer_peer = null
	players.clear()

@rpc("any_peer", "call_local", "reliable")
func player_loaded(id):
	if not multiplayer.is_server(): return
	print(multiplayer.get_unique_id()," loaded into the game.")
	players_loaded += 1
	print(players_loaded," ",MultiplayerManager.players.size())
	if players_loaded == MultiplayerManager.players.size():
		all_loaded.emit()
		players_loaded = 0

@rpc("authority","call_local","reliable")
func start_game(map_path):
	players_loaded = 0
	load_scene.rpc(map_path)

@rpc("call_local","reliable")
func load_scene(game_scene_path):
	var scene = GGResourceFinder.find_file(game_scene_path)
	var err = get_tree().change_scene_to_packed(scene)

@rpc("any_peer", "reliable")
func _kicked(reason):
	remove_multiplayer_peer()
	print("Kicked for: ",reason)
	load_scene("res://menus/main_menu.tscn")

#For clients who connect to register to the server
func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)

@rpc("any_peer","call_local","reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	#Send player info to server
	add_player_info.rpc_id(1,multiplayer.get_unique_id(),new_player_info)
	player_connected.emit(new_player_id, new_player_info)

func _on_player_disconnected(id):
	remove_player_info(id)
	player_disconnected.emit(id)
	DisplayServer.window_set_title("Test Game")

func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)
	DisplayServer.window_set_title("Test Game "+str(multiplayer.get_unique_id()))
	load_scene("res://menus/lobby/lobby.tscn")

func _on_connected_fail():
	remove_multiplayer_peer()
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	remove_multiplayer_peer()
	multiplayer.multiplayer_peer = null
	steam_peer.close()
	players.clear()
	server_disconnected.emit()
	#Returns to menu when the connection fails
	load_scene("res://menus/main_menu.tscn")
