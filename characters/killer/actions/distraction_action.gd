extends KillerAction

@onready var cam_arm = %CamArm
@export var dist_node:Node3D
@export var ray:RayCast3D

func _process(delta):
	if not killer.controlled:
		dist_node.hide()
		return
	if not ah.is_current(self) or not ah.mode:
		dist_node.hide()
		return
	if not ray.is_colliding(): 
		dist_node.hide()
		return
	var pos = ray.get_collision_point()
	dist_node.show()
	dist_node.global_position = pos

func perform_action():
	if not cooldown.is_stopped(): return
	if not dist_node.visible: return
	dist_node.play.rpc()
	dist_node.hide()
	cooldown.start()
	ah.exit_mode()
