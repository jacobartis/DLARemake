extends Button

func _ready():
	if multiplayer.is_server(): return
	disabled = true

func _on_level_select_level_selected(level_id):
	update_display.rpc(level_id)

@rpc("any_peer","call_local","reliable")
func update_display(level_id):
	var info = GameInfo.level_infos[level_id]
	%MapIcon.texture = info.level_background
	%LevelName.text = info.level_name
