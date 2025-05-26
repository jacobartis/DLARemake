extends Node

signal survivors_win()
signal objective_complete()

@export var obj_display: Label = null

func _ready():
	update_display()

func connect_obj(obj):
	obj.completed.connect(on_objective_complete)
	update_display()

func get_objectives():
	return get_tree().get_nodes_in_group("objective")

func get_remaning():
	return get_objectives().filter(func (o): return not o.complete)

func update_display():
	if not obj_display: return
	if get_remaning().size()==1:
		obj_display.text = "Exit active"
	elif get_remaning().size()>1:
		obj_display.text = "Remaining objectives: %s"%(get_remaning().size()-1)
	else:
		obj_display.text = ""

func on_objective_complete():
	update_display()
	objective_complete.emit()
	if not get_remaning().is_empty(): return
	survivors_win.emit()
