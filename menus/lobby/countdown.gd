extends Label

@export var timer: Timer

@export var step: float = 1

func _process(delta):
	var time = snappedf(timer.time_left,step)
	text = str(time)
