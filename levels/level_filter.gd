extends SubViewportContainer

@export var killer: ShaderMaterial
@export var survivor: ShaderMaterial


func _on_world_game_start():
	set_filter.rpc()

@rpc("any_peer","call_local","reliable")
func set_filter():
	if GameInfo.role(multiplayer.get_unique_id()) == "Killer":
		material = killer
	else:
		material = survivor
