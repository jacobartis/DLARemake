extends Node3D

@export var killer: Environment
@export var survivor: Environment

var world_environment:WorldEnvironment

func _ready():
	world_environment = WorldEnvironment.new()
	add_child(world_environment)

@rpc("any_peer","call_local","reliable")
func set_filter():
	if GameInfo.role(multiplayer.get_unique_id()) == "Killer":
		world_environment.environment = killer
	else:
		world_environment.environment = survivor

func _on_world_game_start():
	set_filter.rpc()
