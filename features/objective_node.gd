extends Node
class_name ObjectiveNode

signal completed()

var complete: bool = false

func _ready():
	add_to_group("objective")

func finish():
	complete = true
	completed.emit()
