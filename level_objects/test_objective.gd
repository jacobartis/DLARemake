extends Node3D


@onready var fill:MeshInstance3D = $Fill

@export var duration: float = 5
@export var empty_rate: float = 2
@export var obj_node: ObjectiveNode

var hold_time: float = -1
var press_buffer: float = 0
var hold_buffer: float = 0

func _on_object_interact_is_held():
	press_buffer = 0.2


func _process(delta):
	if obj_node.complete: return
	if press_buffer:
		press_buffer = max(press_buffer-delta,0)
		hold_time = max(hold_time+delta,0)
		if press_buffer == 0:
			hold_buffer = .5
	elif hold_buffer > 0:
		hold_buffer = max(hold_buffer-delta,0)
	elif hold_buffer == 0:
		hold_time = max(hold_time-delta*empty_rate,0)
	var mesh = $Fill.mesh
	var perc = clamp(hold_time/duration,0,1) #% of duration held
	mesh.height = (perc*2.0)
	$Fill.position.y = -1*(1-perc)
	if perc == 1:
		obj_node.finish()


func _on_object_interact_player_entered(player):
	print(player)
