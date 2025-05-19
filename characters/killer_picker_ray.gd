extends RayCast3D

@export var killer: CharacterBody3D

var hovered:CharacterBody3D = null:set=set_hovered

func set_hovered(val):
	if hovered == val: return
	if hovered!=null:
		hovered.highlight.highlight(Color.WHITE)
	hovered = val

func valid_body(body):
	return true

func _process(delta):
	if not killer.controled:
		hovered = null
		return
	if not is_colliding() or not valid_body(get_collider()): 
		hovered = null
		return
	var body = get_collider()
	if body.controled:
		body.highlight.highlight(Color.GRAY)
		hovered = null
		return
	body.highlight.highlight(Color.RED)
	hovered = body

func _input(event):
	if not killer.is_authority(): return
	if event.is_action_pressed("Transfer"):
		swap_control()

func swap_control():
	if not hovered: return
	killer.drop_control.rpc()
	hovered.gain_control.rpc(multiplayer.get_unique_id())
