@tool
extends "res://level_objects/lights/tb_omnilight.gd"

var time:float = 0
var on_duration: float = 1
var off_duration: float = 1
var randomness: float = 0

func _func_godot_apply_properties(entity_properties: Dictionary):
	super(entity_properties)
	if entity_properties.has("on_duration"):
		on_duration = entity_properties["on_duration"]
	if entity_properties.has("off_duration"):
		off_duration = entity_properties["off_duration"]
	if entity_properties.has("randomness"):
		randomness = entity_properties["randomness"]

func _process(delta):
	time = max(time-delta,0)
	if time != 0: return
	if visible:
		visible = false
		var rand_time = (off_duration*randomness)
		time = randf_range(off_duration-rand_time,off_duration+rand_time)
	else:
		visible = true
		var rand_time = (on_duration*randomness)
		time = randf_range(on_duration-rand_time,on_duration+rand_time)
