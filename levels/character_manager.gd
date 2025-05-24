extends Node3D
class_name CharacterManager

signal all_dead()

const SURVIVOR = preload("res://characters/survivor.tscn")
const KILLER = preload("res://characters/killer.tscn")
const SPECTATOR = preload("res://characters/spectator.tscn")

@export var spawn_parent:Node
@onready var spawner = $MultiplayerSpawner

var survivers:Dictionary[int,Node3D] = {}
var killers = []
var spectators:Dictionary[int,Node3D] = {}

#func _ready():
	#spawner.spawn_function = spawn_func

@rpc("call_local")
func _position_player(n,pos):
	var path = "/root/World/CanvasLayer/SubViewportContainer/SubViewport/PlayerHolder/%s" % n
	if not get_node(path): 
		return
	get_node(path).global_position = pos

func spawn_survivors(players:Array):
	if not multiplayer.is_server(): return 
	var spawn_points = get_tree().get_nodes_in_group("spawn").filter(func(s):return s.type == "survivor")
	spawn_points.shuffle()
	for id in players:
		var surv = SURVIVOR.instantiate()
		spawn_parent.add_child(surv,true)
		print(surv.get_path())
		surv.update_owner.rpc(id)
		_position_player.rpc(surv.name,spawn_points.pop_front().global_position)
		survivers[id] = surv
		surv.killed.connect(survivor_killed.bind(id))

func spawn_killers(players:Array):
	if not multiplayer.is_server(): return 
	var spawn_points = get_tree().get_nodes_in_group("spawn").filter(func(s):return s.type == "killer")
	spawn_points.shuffle()
	for i in (players.size()+1)*2:
		var killer = KILLER.instantiate()
		spawn_parent.add_child(killer,true)
		_position_player.rpc(killer.name,spawn_points.pop_front().global_position)
		killers.append(killer)
	var avalible = killers.duplicate()
	for id in players:
		var spawn_killer = avalible.pop_at(randi()%avalible.size())
		spawn_killer.gain_control.rpc(id)

#For player disconnects
@rpc("any_peer","call_local","reliable")
func release_current_killer(id):
	var controlled = killers.filter(func (k): return k.get_multiplayer_authority()==id)
	for k in controlled:
		k.drop_control()

#Server kills the surviver
func kill_surviver(id):
	survivers[id].kill.rpc()

func survivor_killed(id):
	#Spawns spectator is player is still connected.
	if MultiplayerManager.players.keys().has(id):
		spawn_spectator(id)
	check_dead.rpc()

func spawn_spectator(id):
	var spectator = SPECTATOR.instantiate()
	spawn_parent.add_child(spectator,true)
	spectators[id] = spectator
	spectator.update_owner.rpc(id)

func delete_spectator(id):
	spectators[id].queue_free()
	spectators.erase(id)

@rpc("any_peer","call_local","reliable")
func check_dead():
	if not survivers.values().all(func(surv): return surv.dead): return
	all_dead.emit()
