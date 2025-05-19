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

func _ready():
	spawner.spawn_function = spawn_func

func spawn_func(data):
	var packed = null
	if data["type"]=="surv":
		packed = SURVIVOR
	else:
		packed = KILLER
	var player = packed.instantiate()
	if not multiplayer.is_server(): return player
	
	#Sets pos server side
	var id = data["id"]
	var pos = data["pos"]
	player.global_position = pos
	if id:
		player.update_owner.rpc(id)
	return player

func spawn_survivors(players:Array):
	for id in players:
		var spawn_data = {
			"type":"surv",
			"id":id,
			"pos":%SurvSpawns.get_children().pick_random().global_position
		} 
		var surv = spawner.spawn(spawn_data)
		surv.global_position = spawn_data["pos"]
		surv.update_owner.rpc(id)
		survivers[id] = surv
		if not multiplayer.is_server(): return 
		surv.killed.connect(survivor_killed.bind(id))

func spawn_killers(players:Array):
	for i in (players.size()+1)*2:
		var spawn_data = {
			"type":"killer",
			"id":null,
			"pos":%KillerSpawns.get_children().pick_random().global_position
		} 
		var killer = spawner.spawn(spawn_data)
		killer.global_position = spawn_data["pos"]
		killers.append(killer)
	var avalible = killers.duplicate()
	for id in players:
		var spawn_killer = avalible.pop_at(randi()%avalible.size())
		spawn_killer.gain_control.rpc(id)

#For player disconnects
func release_current_killer(id):
	var controlled = killers.filter(func (k): return k.multiplayer_authority==id)
	for k in controlled:
		k.drop_control()

#Server kills the surviver
func kill_surviver(id):
	survivers[id].kill()

func survivor_killed(id):
	#Spawns spectator is player is still connected.
	if MultiplayerManager.players[id]:
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
