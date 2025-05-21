@tool
extends Node3D
class_name PlayerSpawn

@export var type: String = "survivor"

func _func_godot_apply_properties(entity_properties: Dictionary):
	print(entity_properties)
	if entity_properties.has("type"):
		type = entity_properties["type"]

func _ready():
	add_to_group("spawn")
