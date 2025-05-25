extends Control


func get_kick_button():
	return %Kick

func set_player(id,info):
	%Name.text = info["name"]

func set_kickable(val:bool):
	%Kick.visible = val
