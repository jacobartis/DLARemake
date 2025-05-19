extends Node3D


@onready var fill:MeshInstance3D = $Fill

@export var duration: float = 5
@export var obj_node: ObjectiveNode

var last_press: float = -1

func _on_object_interact_is_held():
	last_press = Time.get_ticks_msec()

func hold_time():
	if last_press == -1: return 0
	return Time.get_ticks_msec() - last_press

func _process(delta):
	if obj_node.complete: return
	var mesh = $Fill.mesh
	var perc = clamp(hold_time()/duration,0,1) #% of duration held
	mesh.height = (perc*2.0)
	$Fill.position.y = -1*(1-perc)
	if perc == 1:
		obj_node.finish()
