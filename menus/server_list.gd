extends Panel
signal joining_lobby()

func _ready():
	Steam.lobby_match_list.connect(on_lobby_match_list)

func _on_server_update():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()

func on_lobby_match_list(lobbies):
	#Clear old lobbies
	for child in %SteamLobbies.get_children():
		child.queue_free()
	
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby,"name")
		var player_count = Steam.getNumLobbyMembers(lobby)
		
		var button = Button.new()
		button.set_text(str(lobby_name,"| Player Count: ",player_count))
		button.set_size(Vector2(100,5))
		button.connect("pressed",Callable(self,"join_lobby").bind(lobby))
		%SteamLobbies.add_child(button)

func join_lobby(lobby):
	for child in %SteamLobbies.get_children():
		child.disabled = true
	set_player_name_steam()
	joining_lobby.emit()
	MultiplayerManager.join_steam_server(lobby)

func set_player_name_steam():
	var id = Steam.getSteamID()
	var player_name = Steam.getFriendPersonaName(id)
	MultiplayerManager.player_info["name"] = player_name
