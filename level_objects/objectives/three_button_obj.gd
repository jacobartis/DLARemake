@tool
extends Node3D

@export var s_man:Node3D
@export var disable_timer:Timer
@export var minigame:Minigame
@export var objective_node:ObjectiveNode

@export var punish_dur:float

@export var func_godot_properties: Dictionary

func _func_godot_apply_properties(entity_properties: Dictionary):
	if entity_properties.has("punish_dur"):
		punish_dur = entity_properties["punish_dur"]

@rpc("any_peer","call_local","reliable")
func disable(durr):
	disable_timer.start(durr)
	s_man.show_screen(1)

func is_disabled():
	return not disable_timer.is_stopped()

func _on_left_is_pressed():
	if is_disabled() or objective_node.complete: return
	minigame.left()

func _on_right_is_pressed():
	if is_disabled() or objective_node.complete: return
	minigame.right()


func _on_middle_is_pressed():
	if is_disabled() or objective_node.complete: return
	minigame.middle.rpc()

func _on_disable_timer_timeout():
	s_man.show_screen.rpc(0)


func _on_mini_game_fail():
	fail_condition.rpc()

@rpc("any_peer","call_local","reliable")
func fail_condition():
	disable_timer.start(punish_dur)
	s_man.show_screen.rpc(2)


func _on_mini_game_success():
	s_man.show_screen.rpc(3)
	objective_node.finish.rpc()
