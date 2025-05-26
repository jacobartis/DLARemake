extends RayCast3D

@export var killer: CharacterBody3D
@onready var cam_arm = %CamArm
@export var dist_node:Node3D
@export var cooldown:Timer
var mode: bool = false
var tween

func _process(delta):
	if not killer.controlled:
		dist_node.hide()
		return
	if not mode:
		dist_node.hide()
		return
	if not is_colliding(): 
		dist_node.hide()
		return
	var pos = get_collision_point()
	print(pos)
	dist_node.show()
	dist_node.global_position = pos

func _input(event):
	if not killer.is_authority(): return
	if not cooldown.is_stopped(): return
	if event.is_action_pressed("Distract"):
		enter_mode()
	elif event.is_action_released("Distract"):
		if dist_node.visible:
			emit_distraction()
		exit_mode()

func enter_mode():
	if tween:
		tween.kill()
	mode = true
	tween = get_tree().create_tween()
	tween.tween_property(cam_arm,"spring_length",0,.2)

func exit_mode():
	if tween:
		tween.kill()
	mode = false
	tween = get_tree().create_tween()
	tween.tween_property(cam_arm,"spring_length",5,.2)

func emit_distraction():
	if not dist_node.visible: return
	dist_node.play.rpc()
	dist_node.hide()
	cooldown.start()
