extends Area3D
class_name PointInteract

signal is_pressed()
signal is_held()
signal is_released()

func _ready():
	add_to_group("interact")

@rpc("any_peer","call_local","reliable")
func pressed():
	is_pressed.emit()

@rpc("any_peer","call_local","reliable")
func held():
	is_held.emit()

@rpc("any_peer","call_local","reliable")
func released():
	is_released.emit()
