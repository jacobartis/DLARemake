extends KillerAction

@export var ray:RayCast3D
@export var duration: float = 10
var hovered: set=set_hovered
var objs_h

func set_hovered(val):
	if hovered == val: return
	if hovered!=null:
		hovered.highlight.highlight(Color.WHITE)
		hovered.highlight.set_albedo(.2)
	hovered = val

func valid_area(area):
	return area.is_in_group("objective_pick") and not area.parent.objective_node.complete

func enter_action():
	objs_h = get_tree().get_nodes_in_group("h_obj").filter(func(x): return not x.get_parent().objective_node.complete)
	for o in objs_h:
		o.set_albedo(.2)
	print("enter")

func exit_action():
	for o in objs_h:
		o.default()

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
	var body = ray.get_collider().parent
	body.highlight.highlight(Color.WHITE)
	body.highlight.set_albedo(1)
	hovered = body

func perform_action():
	if not hovered: return
	hovered.disable.rpc(duration)
	ah.exit_mode()
