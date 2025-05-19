extends Node3D

@export var char_man: CharacterManager

func _ready():
	if multiplayer.is_server():
		MultiplayerManager.all_loaded.connect(start)
	MultiplayerManager.player_loaded.rpc_id(1,multiplayer.get_unique_id())

func start():
	print("start")
	var killer = MultiplayerManager.players.keys().pick_random()
	var surv = MultiplayerManager.players.keys().duplicate()
	surv.erase(killer)
	char_man.spawn_survivors(surv)
	char_man.spawn_killers([killer])

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Settings.free_mouse()
		else:
			Settings.clamp_mouse()
