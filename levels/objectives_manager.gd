extends Node

signal survivors_win()
signal objective_complete()

func connect_obj(obj):
	obj.completed.connect(on_objective_complete)


func on_objective_complete():
	objective_complete.emit()
	if not get_tree().get_nodes_in_group("objective").all(func (o): return o.complete): return
	survivors_win.emit()
