extends KillerAction

@export var ray:RayCast3D
@onready var cam_arm = %CamArm

var hovered:CharacterBody3D = null:set=set_hovered

func set_hovered(val):
	if hovered == val: return
	if hovered!=null:
		hovered.highlight.highlight(Color.WHITE)
		hovered.highlight.default()
		hovered.extra_highlight.hide()
	hovered = val

func valid_area(area):
	return area.is_in_group("pick_area")

func _process(delta):
	if not killer.controlled:
		hovered = null
		return
	if not ah.is_current(self):
		hovered = null
		return
	if not ray.is_colliding() or not valid_area(ray.get_collider()): 
		hovered = null
		return
	var body = ray.get_collider().killer
	if body.controlled:
		body.highlight.highlight(Color.DIM_GRAY)
		hovered = null
		return
	body.highlight.highlight(Color.CHOCOLATE)
	body.highlight.set_albedo(1)
	body.extra_highlight.show()
	hovered = body

func _input(event):
	if not killer.is_authority(): return
	if event.is_action_pressed("Transfer"):
		ah.enter_mode()
		ah.end_action()
		ah.start_action(self)
	elif event.is_action_released("Transfer"):
		ah.exit_mode()
	if event.is_action_pressed("PerformAction"):
		if swap_control():
			ah.exit_mode()

func swap_control():
	if not hovered: return false
	killer.drop_control.rpc()
	hovered.gain_control.rpc(multiplayer.get_unique_id())
	return true
