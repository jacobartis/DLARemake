extends Node

signal survivors_win()

func connect_obj(obj):
	obj.completed.connect(on_objective_complete)


func on_objective_complete():
	if not get_tree().get_nodes_in_group("objective").all(func (o): return o.complete): return
	survivors_win.emit()
