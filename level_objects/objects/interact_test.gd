@tool
extends OmniLight3D

@export var func_godot_properties: Dictionary
@export var targetname: String

func _func_godot_apply_properties(entity_properties: Dictionary):
	if entity_properties.has("targetname"):
		targetname = entity_properties["targetname"]

func _ready():
	if targetname != "":
		add_to_group(targetname)
	print("Groups ",get_groups())
	hide()

func _on_is_pressed():
	visible = !visible
