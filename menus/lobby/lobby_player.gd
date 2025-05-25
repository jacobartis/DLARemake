extends Control

var player_id:int = 0

func _ready():
	%Preference.disabled = not is_multiplayer_authority()

func get_pref():
	return %Preference.selected

func get_pref_button():
	return %Preference

func get_kick_button():
	return %Kick

func set_player(id,info):
	player_id = id
	set_multiplayer_authority(id)
	%Name.text = info["name"]
	%Preference.disabled = not is_multiplayer_authority()

func set_kickable(val:bool):
	%Kick.visible = val

@rpc("any_peer","call_remote","reliable")
func set_selected_pref(val):
	%Preference.selected = val
