extends Node3D
class_name KillerActionHandler

signal action_selected(action)
signal entering_mode()
signal exiting_mode()

@export var actions:Array[KillerAction]
@export var killer_picker:KillerAction
@export var killer:CharacterBody3D

var current_action:KillerAction
var selected_pos: int = 0
var tween: Tween
var mode: bool

func is_current(val):
	return current_action == val

func _ready():
	start_action(actions[selected_pos])

func start_action(val):
	if current_action: return
	current_action = val
	action_selected.emit(current_action.name)
	current_action.enter_action()

func end_action():
	if current_action:
		current_action.exit_action()
	current_action = null

func enter_mode():
	if tween:
		tween.kill()
	mode = true
	tween = get_tree().create_tween()
	tween.tween_property(%CamArm,"spring_length",0,.2)
	entering_mode.emit()

func exit_mode():
	if tween:
		tween.kill()
	mode = false
	tween = get_tree().create_tween()
	tween.tween_property(%CamArm,"spring_length",5,.2)
	if current_action:
		end_action()
	exiting_mode.emit()

func _process(delta):
	if not killer.controlled or not killer.is_authority(): return
	if Input.is_action_just_pressed("ActionMode"):
		enter_mode()
		start_action(actions[selected_pos])
	elif Input.is_action_just_released("ActionMode"):
		exit_mode()
	if not mode: return
	#Swap between actions when not in mode
	if not is_current(killer_picker):
		if Input.is_action_just_released("NextAction"):
			selected_pos = wrap(selected_pos+1,0,actions.size())
			end_action()
			start_action(actions[selected_pos])
		elif Input.is_action_just_released("PrevAction"):
			selected_pos = wrap(selected_pos-1,0,actions.size())
			end_action()
			start_action(actions[selected_pos])
	
	if not current_action: return
	if not Input.is_action_just_pressed("PerformAction"): return
	current_action.perform_action()
