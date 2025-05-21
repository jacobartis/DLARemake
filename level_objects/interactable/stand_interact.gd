@tool
extends PlayerDetector
class_name StandInteract

signal is_pressed()
signal is_held()
signal is_released()

func _func_godot_apply_properties(entity_properties: Dictionary):
	if entity_properties.has("type"):
		type = entity_properties["type"]
	if entity_properties.has("message"):
		interact_message = entity_properties["message"]
	if entity_properties.has("playertype"):
		player_type = entity_properties["playertype"]
	if entity_properties.has("targetname"):
		targetname = entity_properties["targetname"]
	if entity_properties.has("target"):
		target = entity_properties["target"]

@export_enum("Press","Hold") var type: String = "Press"
@export var interact_message: String = ""

@export var func_godot_properties: Dictionary
var target: String = ""
var targetname: String = ""

func _ready():
	super()
	player_entered.connect(on_player_entered)
	player_exited.connect(on_player_exited)
	_func_godot_apply_properties(func_godot_properties)
	if targetname != "":
		add_to_group(targetname)
	call_deferred("connect_targets")

func connect_targets():
	if !target: return
	for targ in get_tree().get_nodes_in_group(target):
		if targ.has_method("_on_is_pressed"):
			if not is_pressed.is_connected(targ._on_is_pressed):
				is_pressed.connect(targ._on_is_pressed)
		if targ.has_method("_on_is_held"):
			if not is_held.is_connected(targ._on_is_held):
				is_held.connect(targ._on_is_held)
		if targ.has_method("_on_is_released"):
			if not is_released.is_connected(targ._on_is_released):
				is_released.connect(targ._on_is_released)

func on_player_entered(player):
	player.interactor.add_interact(self)

func on_player_exited(player):
	player.interactor.remove_interact(self)

@rpc("any_peer","call_local","reliable")
func pressed():
	is_pressed.emit()

@rpc("any_peer","call_local","reliable")
func held():
	is_held.emit()

@rpc("any_peer","call_local","reliable")
func released():
	is_released.emit()
