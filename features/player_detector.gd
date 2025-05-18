extends Area3D
class_name PlayerDetector

signal player_entered(player:CharacterBody3D)
signal player_exited(player:CharacterBody3D)

@export_enum("Survivor","Killer","Both") var player_type = 0

func _ready():
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)

func valid_body(body:Node3D):
	if not body.is_in_group("player"):return false
	var types = []
	if player_type == 0 or player_type == 2:
		types.append("survivor")
	if player_type == 1 or player_type == 2:
		types.append("killer")
	return types.all(func(type):return body.is_in_group(type))

func on_body_entered(body:Node3D):
	if not valid_body(body): return
	player_entered.emit(body)

func on_body_exited(body:Node3D):
	if not valid_body(body): return
	player_exited.emit(body)
