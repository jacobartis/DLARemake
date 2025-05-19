extends Node3D

@export var char_man: CharacterManager



func _ready():
	if multiplayer.is_server():
		MultiplayerManager.player_connected.connect(mid_round_connect)
		MultiplayerManager.player_disconnected.connect(mid_round_disconnect)
		MultiplayerManager.all_loaded.connect(start)
	MultiplayerManager.player_loaded.rpc_id(1,multiplayer.get_unique_id())

func start():
	print("start")
	GameInfo.killer_players = [MultiplayerManager.players.keys().pick_random()]
	GameInfo.surviver_players = MultiplayerManager.players.keys().duplicate()
	for id in GameInfo.killer_players:
		GameInfo.surviver_players.erase(id)
	char_man.spawn_survivors(GameInfo.surviver_players)
	char_man.spawn_killers(GameInfo.killer_players)
	GameInfo.server_update()

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Settings.free_mouse()
		else:
			Settings.clamp_mouse()

func end_round():
	#Show summary screen
	#Have play again button, returns to lobby
	#Have quit button allows the player to exit
	pass

func _on_character_manager_all_dead():
	if not multiplayer.is_server(): return
	end_round()

func mid_round_connect(id,info):
	GameInfo.spectator_players.append(id)
	char_man.spawn_spectator(id)

func mid_round_disconnect(id):
	var role = GameInfo.role(id)
	if role=="Killer":
		char_man.release_current_killer(id)
	elif role=="Surviver":
		char_man.kill_surviver(id)
	elif role=="Spectator":
		char_man.delete_spectator(id)
