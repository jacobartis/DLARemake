extends Control

func _ready():
	%SurvivorWin.hide()
	%KillerWin.hide()

@rpc("any_peer","call_local","reliable")
func show_win(winner):
	if winner == "Killer":
		killer_win()
	else:
		survivor_win()
	show()
	Settings.free_mouse()

func killer_win():
	%SurvivorWin.hide()
	%KillerWin.show()

func survivor_win():
	%SurvivorWin.show()
	%KillerWin.hide()


func _on_play_again_pressed():
	MultiplayerManager.load_scene("res://menus/lobby/lobby.tscn")

func _on_quit_pressed():
	MultiplayerManager.leave_server()
