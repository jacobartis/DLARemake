extends Node3D
class_name KillerActionHandler

@export var actions:Array[KillerAction]
@export var killer:CharacterBody3D

var current_action:KillerAction
var selected_pos: int = 0
var tween: Tween
var mode: bool

func is_current(val):
	return current_action == val

func start_action(val):
	if current_action: return
	current_action = val

func end_action():
	current_action = null

func enter_mode():
	if tween:
		tween.kill()
	mode = true
	tween = get_tree().create_tween()
	tween.tween_property(%CamArm,"spring_length",0,.2)

func exit_mode():
	if tween:
		tween.kill()
	mode = false
	tween = get_tree().create_tween()
	tween.tween_property(%CamArm,"spring_length",5,.2)
	if current_action:
		end_action()

func _process(delta):
	if not killer.controlled or not killer.is_authority(): return
	if Input.is_action_just_pressed("ActionMode"):
		enter_mode()
	elif Input.is_action_just_released("ActionMode"):
		exit_mode()
	
	#Swap between actions when not in mode
	if not mode:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP):
			selected_pos = wrap(selected_pos+1,0,actions.size())
			end_action()
			start_action(actions[selected_pos])
		else:
			selected_pos = wrap(selected_pos-1,0,actions.size())
			end_action()
			start_action(actions[selected_pos])
	
	if not current_action: return
	if not Input.is_action_just_pressed("PerformAction"): return
	current_action.perform_action()
