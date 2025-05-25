extends Node3D
class_name Level

signal game_start()

@export var char_man: CharacterManager

func _ready():
	if multiplayer.is_server():
		MultiplayerManager.player_connected.connect(mid_round_connect)
		MultiplayerManager.player_disconnected.connect(mid_round_disconnect)
		MultiplayerManager.all_loaded.connect(start)
	MultiplayerManager.player_loaded.rpc_id(1,multiplayer.get_unique_id())
	Settings.clamp_mouse()

func start():
	print("start")
	GameInfo.server_update()
	print(GameInfo.surviver_players)
	print(GameInfo.killer_players)
	for id in GameInfo.killer_players:
		GameInfo.surviver_players.erase(id)
	char_man.spawn_survivors(GameInfo.surviver_players)
	await get_tree().process_frame
	char_man.spawn_killers(GameInfo.killer_players)
	game_start.emit()

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Settings.free_mouse()
		else:
			Settings.clamp_mouse()

func end_round(winner):
	#Show summary screen
	#Have play again button, returns to lobby
	#Have quit button allows the player to exit
	%SummaryScreen.show_win.rpc(winner)

func _on_character_manager_all_dead():
	if not multiplayer.is_server(): return
	end_round("Killer")

func mid_round_connect(id,info):
	GameInfo.spectator_players.append(id)
	char_man.spawn_spectator(id)
	GameInfo.server_update()

func mid_round_disconnect(id):
	var role = GameInfo.role(id)
	if role=="Killer":
		char_man.release_current_killer.rpc(id)
		GameInfo.killer_players.erase(id)
	elif role=="Surviver":
		char_man.kill_surviver(id)
		GameInfo.surviver_players.erase(id)
	elif role=="Spectator":
		char_man.delete_spectator(id)
		GameInfo.spectator_players.erase(id)
	GameInfo.server_update()


func _on_objectives_manager_survivors_win():
	end_round("Survivor")


func _on_tree_exiting():
	Settings.free_mouse()
