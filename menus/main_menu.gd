extends Control

func _on_host_ip_pressed():
	set_player_name()
	var error = MultiplayerManager.create_ip_server()
	if error:
		print("Error: ",error_string(error))
		return
	load_lobby()

func _on_join_ip_pressed():
	set_player_name()
	var error = MultiplayerManager.join_ip_server(%IPTextBox.text)
	if error:
		print("Error: ",error_string(error))
		return
	join_game()

func _on_join_local_host():
	set_player_name()
	var error = MultiplayerManager.join_ip_server("localhost")
	if error:
		print("Error: ",error_string(error))
		return
	join_game()

func _on_host_steam_pressed():
	set_player_name_steam()
	var error = MultiplayerManager.create_steam_server()
	if error:
		print("Error: ",error_string(error))
		return
	load_lobby()

func join_game():
	print("Join game")
	MultiplayerManager.server_update_map.rpc_id(1)
	print(MultiplayerManager.current_map)
	if MultiplayerManager.current_map=="Lobby":
		load_lobby()
	else:
		MultiplayerManager.load_scene(MultiplayerManager.current_map)

func load_lobby():
	var file = GGResourceFinder.find_file("res://menus/lobby/lobby.tscn")
	get_tree().change_scene_to_packed(file)

#Joining a steam game is handled in the server list script.
# Joining steam game doesnt set name correctly
# Disconnecting from steam game is broken

var nouns = ["Teacher", "Doctor", "Engineer", "Student", "Artist", "Parent", "Child", "Friend", "Leader", "Actor", "School", "City", "Country", "Park", "Office", "Home", "Hospital", "Library", "Restaurant", "Airport", "Book", "Phone", "Car", "Table", "Chair", "Computer", "Bag", "Pen", "Camera", "Key", "Freedom", "Love", "Knowledge", "Happiness", "Justice", "Honesty", "Fear", "Success", "Courage", "Time"]
var adjectives = ["Happy", "Sad", "Angry", "Brave", "Clever", "Honest", "Kind", "Lazy", "Friendly", "Nervous", "Bright", "Dark", "Soft", "Hard", "Noisy", "Quiet", "Fast", "Slow", "Hot", "Cold", "Beautiful", "Ugly", "Strong", "Weak", "Tall", "Short", "Young", "Old", "Rich", "Poor", "Clean", "Dirty"]

func set_player_name():
	MultiplayerManager.player_info["name"] = "{a} {n}".format({"n":nouns.pick_random(),"a":adjectives.pick_random()})

func set_player_name_steam():
	var id = Steam.getSteamID()
	var player_name = Steam.getFriendPersonaName(id)
	MultiplayerManager.player_info["name"] = player_name
