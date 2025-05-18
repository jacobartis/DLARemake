extends VBoxContainer

var displayed_players = {}

func add_player(id,info):
	var label = Label.new()
	label.set_text(info["name"])
	add_child(label)
	displayed_players[id] = label

func remove_player(id):
	if not id in displayed_players: return
	displayed_players[id].queue_free()
	displayed_players.erase(id)
