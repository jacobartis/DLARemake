extends VBoxContainer

signal kicking_player(id)

@onready var player_packed:PackedScene = GGResourceFinder.find_file("res://menus/lobby/lobby_player.tscn")

var displayed_players = {}

func add_player(id,info):
	var disp = player_packed.instantiate()
	add_child(disp)
	disp.set_player(id,info)
	if id != 1:
		disp.set_kickable(multiplayer.get_unique_id()==1)
	disp.get_kick_button().pressed.connect(kick_pressed.bind(id))
	displayed_players[id] = disp

func kick_pressed(id):
	kicking_player.emit(id)

func remove_player(id):
	if not id in displayed_players: return
	displayed_players[id].queue_free()
	displayed_players.erase(id)

func get_displayed_label(id):
	if not displayed_players.has(id): return
	return displayed_players[id]
