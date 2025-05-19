extends Node
class_name Interactor

@export var body:Node3D

var interacts: Array = []
var hold_inter:ObjectInteract = null

func add_interact(interact:ObjectInteract):
	if interacts.has(interact): return
	interacts.append(interact)

func remove_interact(interact:ObjectInteract):
	interacts.erase(interact)

func get_closest() -> ObjectInteract:
	if interacts.is_empty(): return null
	interacts.sort_custom(closest)
	return interacts[0]

func _process(delta):
	if interacts.is_empty(): return
	if Input.is_action_just_pressed("Interact"):
		interact()
	elif Input.is_action_pressed("Interact"):
		hold_interact()
	elif Input.is_action_just_released("Interact"):
		release_interact()

func interact():
	get_closest().pressed.rpc(body)

func hold_interact():
	if not hold_inter:
		hold_inter = get_closest()
	hold_inter.held.rpc()

func release_interact():
	if not hold_inter: return
	hold_inter.released.rpc()
	hold_inter = null

func closest(a,b):
	var b_pos = body.global_position
	return b.global_position.distance_to(b_pos)<a.global_position.distance_to(b_pos)
