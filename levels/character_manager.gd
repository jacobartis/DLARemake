extends Node3D
class_name CharacterManager

const SURVIVOR = preload("res://characters/survivor.tscn")
const KILLER = preload("res://characters/killer.tscn")

@export var spawn_parent:Node
@onready var spawner = $MultiplayerSpawner

var characters:Dictionary[int,CharacterBody3D] = {}

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
		characters[id] = surv

func spawn_killers(players:Array):
	for id in players:
		var spawn_data = {
			"type":"killer",
			"id":id,
			"pos":%KillerSpawns.get_children().pick_random().global_position
		} 
		var killer = spawner.spawn(spawn_data)
		killer.global_position = spawn_data["pos"]
		killer.update_owner.rpc(id)
		characters[id] = killer
