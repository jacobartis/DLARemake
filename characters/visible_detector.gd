extends VisibleOnScreenNotifier3D

signal seen()
signal hidden()

@export var killer:CharacterBody3D
@export var marker_parent:Node3D

var delay = .2

#Keeps list of current observers
var viewers = []

func _process(delta):
	#Need to fix
	#On_screen() is unique to whoever is looking
	#Meaning other people have false, just emitting hidden
	delay = max(delay-delta,0)
	if delay: return
	if is_on_screen():
		print("Shown ",multiplayer.get_unique_id()," ",killer.is_authority())
		if check_all():
			add_viewer.rpc(multiplayer.get_unique_id())
		else:
			remove_viewer.rpc(multiplayer.get_unique_id())
	else:
		remove_viewer.rpc(multiplayer.get_unique_id())
	delay = .2

@rpc("any_peer","call_local","reliable")
func add_viewer(id):
	if viewers.has(id): return
	if viewers.is_empty():
		seen.emit()
	viewers.append(id)

@rpc("any_peer","call_local","reliable")
func remove_viewer(id):
	if not viewers.has(id): return
	viewers.erase(id)
	if viewers.is_empty():
		hidden.emit()

func check_all():
	for surv in get_tree().get_nodes_in_group("survivor").filter(func(s):return s.global_position.distance_to(global_position)<100 and not s.dead):
		if check_player(surv):
			return true
	return false

func check_player(body):
	for ray in marker_parent.get_children():
		ray.look_at(body.cam.global_position)
		ray.force_raycast_update()
		if not ray.is_colliding(): continue
		if ray.get_collider().is_in_group("look_box"):
			return true
	return false
