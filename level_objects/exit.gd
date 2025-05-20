extends Node3D

@onready var objective_node = $ObjectiveNode

var survs_in = []

func _ready():
	var manager = get_tree().get_first_node_in_group("objective_manager")
	manager.objective_complete.connect(check_remaining)

func check_remaining():
	if get_tree().get_nodes_in_group("objective").filter(func (o): return o!=objective_node).all(func(o):return o.completed):
		enable()

func enable():
	if GameInfo.role(multiplayer.get_unique_id())=="Survivor":
		$Highlight.show()

func check_all():
	var surv = get_tree().get_nodes_in_group("survivor").filter(func (s): return not s.dead)
	if surv.size() == survs_in:
		objective_node.finish.rpc()

func _on_player_detector_player_entered(player):
	if survs_in.has(player): return
	survs_in.append(survs_in)
	check_all()


func _on_player_detector_player_exited(player):
	if not survs_in.has(player): return
	survs_in.erase(survs_in)
