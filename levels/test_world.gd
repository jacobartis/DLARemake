extends Node3D

@export var char_man: CharacterManager

func _ready():
	if multiplayer.is_server():
		MultiplayerManager.all_loaded.connect(start)
	MultiplayerManager.player_loaded.rpc_id(1,multiplayer.get_unique_id())

func start():
	print("start")
	char_man.spawn_survivors([MultiplayerManager.players.keys()[0]])
	char_man.spawn_killers([MultiplayerManager.players.keys()[1]])

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Settings.free_mouse()
		else:
			Settings.clamp_mouse()
