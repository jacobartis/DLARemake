extends Node
class_name Interactor

@export var body:Node3D

var interacts: Array = []
var hold_inter:StandInteract = null

func add_interact(int_obj:StandInteract):
	if interacts.has(int_obj): return
	interacts.append(int_obj)

func remove_interact(int_obj:StandInteract):
	interacts.erase(int_obj)

func get_closest() -> StandInteract:
	if interacts.is_empty(): return null
	interacts.sort_custom(closest)
	return interacts[0]

func _process(delta):
	if not body.is_authority(): return
	var interact_prompt = get_tree().get_first_node_in_group("interact_prompt")
	if interacts.is_empty():
		interact_prompt.area_interact = null
		return
	interact_prompt.area_interact = get_closest()
	if Input.is_action_just_pressed("Interact"):
		interact()
	elif Input.is_action_pressed("Interact"):
		hold_interact()
	elif Input.is_action_just_released("Interact"):
		release_interact()

func interact():
	get_closest().pressed.rpc()

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
