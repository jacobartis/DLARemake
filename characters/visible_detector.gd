extends VisibleOnScreenNotifier3D

signal seen()
signal hidden()

@export var killer:CharacterBody3D
@export var marker_parent:Node3D

var delay = .1

#Keeps list of current observers
var viewers = []

func _process(delta):
	delay = max(delay-delta,0)
	if delay: return
	if is_on_screen():
		if check_los():
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

func check_los():
	if GameInfo.role(multiplayer.get_unique_id()) != "Survivor": return
	for ray in get_tree().get_nodes_in_group("killer_checker").filter(func (r):return r.get_multiplayer_authority()==multiplayer.get_unique_id()):
		if check_player(ray):
			return true
	return false

func check_player(ray):
	for mark in marker_parent.get_children():
		ray.look_at(mark.global_position)
		ray.force_raycast_update()
		if not ray.is_colliding(): continue
		if ray.get_collider() == killer:
			return true
	return false
