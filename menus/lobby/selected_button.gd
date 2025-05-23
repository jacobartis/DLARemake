extends Button

var level_id:String = "NOT YET SELECTED"

func _ready():
	if multiplayer.is_server(): return
	disabled = true
	update_clients.rpc_id(1)

@rpc("any_peer","call_local","reliable")
func update_label(id):
	level_id = id
	update_display()

@rpc("any_peer","call_local","reliable")
func update_clients():
	update_label.rpc(level_id)

func _on_level_select_level_selected(id):
	update_label.rpc(id)

func update_display():
	var info = GameInfo.level_infos[level_id]
	%MapIcon.texture = info.level_background
	%LevelName.text = info.level_name
