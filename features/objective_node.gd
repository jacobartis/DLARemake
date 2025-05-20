extends Node
class_name ObjectiveNode

signal completed()

var complete: bool = false

func _ready():
	add_to_group("objective")
	var manager = get_tree().get_first_node_in_group("objective_manager")
	if manager:
		manager.connect_obj(self)

@rpc("any_peer","call_local","reliable")
func finish():
	complete = true
	completed.emit()
