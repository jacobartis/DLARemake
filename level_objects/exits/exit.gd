extends Node3D

@onready var objective_node = $ObjectiveNode

var survs_in = []
var enabled: bool = false

func _ready():
	var manager = get_tree().get_first_node_in_group("objective_manager")
	manager.objective_complete.connect(check_remaining)
	hide()

func check_remaining():
	if get_tree().get_nodes_in_group("objective").filter(func (o): return o!=objective_node and not o.complete).is_empty():
		enable()

func enable():
	if GameInfo.role(multiplayer.get_unique_id())=="Survivor":
		show()
		enabled = true

func check_all():
	if not enabled: return
	var surv = get_tree().get_nodes_in_group("survivor").filter(func (s): return not s.dead)
	print("Survs in: ",survs_in," total: ",surv)
	if surv.size() == survs_in.size():
		objective_node.finish.rpc()

#TODO
#Bug where players arent correctly removed on exit.
func _on_player_detector_player_entered(player):
	if survs_in.has(player): return
	survs_in.append(player)
	check_all()

func _on_player_detector_player_exited(player):
	if not survs_in.has(player): return
	survs_in.erase(player)
	check_all()
