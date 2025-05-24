extends VisibleOnScreenNotifier3D

signal seen()
signal hidden()

@export var killer:CharacterBody3D
@export var marker_parent:Node3D
var killer_seen_display

var delay = .1

#Keeps list of current observers
var viewers = []

func update_display():
	if not killer_seen_display: return
	if not killer.is_authority() or not killer.controlled or not killer.is_killer(): return
	if not viewers.is_empty():
		killer_seen_display.fade_in()
	else:
		killer_seen_display.fade_out()


func _ready():
	killer_seen_display = get_tree().get_first_node_in_group("killer_seen_display")

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
	update_display()

@rpc("any_peer","call_local","reliable")
func remove_viewer(id):
	if not viewers.has(id): return
	viewers.erase(id)
	if viewers.is_empty():
		hidden.emit()
	update_display()

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


func _on_killer_new_controller():
	update_display()
