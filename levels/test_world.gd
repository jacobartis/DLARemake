extends Node3D

const SURVIVOR = preload("res://characters/survivor.tscn")
@onready var spawner = $MultiplayerSpawner

func _ready():
	if multiplayer.is_server():
		MultiplayerManager.all_loaded.connect(start)
	MultiplayerManager.player_loaded.rpc_id(1,multiplayer.get_unique_id())

func start():
	print("start")
	for id in MultiplayerManager.players:
		var surv = SURVIVOR.instantiate()
		add_child(surv,true)
		surv.update_owner.rpc(id)
		surv.global_position = Vector3(randi()%20,1,randi()%20)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Settings.free_mouse()
		else:
			Settings.clamp_mouse()
