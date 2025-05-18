extends Node3D
class_name CharacterManager

const SURVIVOR = preload("res://characters/survivor.tscn")
const KILLER = preload("res://characters/killer.tscn")

@export var spawn_parent:Node

var characters:Dictionary[int,CharacterBody3D] = {}

func spawn_survivors(players:Array):
	for id in players:
		var surv = SURVIVOR.instantiate()
		spawn_parent.add_child(surv,true)
		surv.update_owner.rpc(id)
		surv.global_position = Vector3(randi()%20,1,randi()%20)
		characters[id] = surv

func spawn_killers(players:Array):
	for id in players:
		var kill = KILLER.instantiate()
		spawn_parent.add_child(kill,true)
		kill.update_owner.rpc(id)
		kill.global_position = Vector3(randi()%20,1,randi()%20)
		characters[id] = kill
