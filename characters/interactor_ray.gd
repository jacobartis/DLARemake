extends RayCast3D
class_name InteractorRay

@export var body:Node3D

var hold_inter:PointInteract = null

func get_interactable():
	if not is_colliding(): return null
	if get_collider().is_in_group("interact"): return get_collider()
	return null

func _process(delta):
	if not is_colliding(): return
	if not get_interactable(): return
	if Input.is_action_just_pressed("Interact"):
		interact()
	elif Input.is_action_pressed("Interact"):
		hold_interact()
	elif Input.is_action_just_released("Interact"):
		release_interact()

func interact():
	get_interactable().pressed.rpc()

func hold_interact():
	if not hold_inter:
		hold_inter = get_interactable()
	hold_inter.held.rpc()

func release_interact():
	if not hold_inter: return
	hold_inter.released.rpc()
	hold_inter = null
