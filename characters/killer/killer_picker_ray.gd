extends RayCast3D

@export var killer: CharacterBody3D
@onready var cam_arm = %CamArm

var mode: bool = false
var hovered:CharacterBody3D = null:set=set_hovered
var tween

func set_hovered(val):
	if hovered == val: return
	if hovered!=null:
		hovered.highlight.up()
		hovered.highlight.highlight(Color.WHITE)
	hovered = val

func valid_area(area):
	return area.is_in_group("pick_area")

func _process(delta):
	if not killer.controlled:
		hovered = null
		return
	if not mode:
		hovered = null
		return
	if not is_colliding() or not valid_area(get_collider()): 
		hovered = null
		return
	var body = get_collider().killer
	if body.controlled:
		body.highlight.highlight(Color.DIM_GRAY)
		hovered = null
		return
	body.highlight.highlight(Color.CHOCOLATE)
	hovered = body
	hovered.highlight.down()

func _input(event):
	if not killer.is_authority(): return
	if event.is_action_pressed("Transfer"):
		enter_mode()
	elif event.is_action_released("Transfer"):
		if hovered:
			swap_control()
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


func swap_control():
	if not hovered: return
	killer.drop_control.rpc()
	hovered.gain_control.rpc(multiplayer.get_unique_id())
