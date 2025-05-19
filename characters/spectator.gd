extends Node3D

@onready var cam = %Camera3D
@onready var spring = %Spring

var selected_pos: int = 0
var selected_char: CharacterBody3D = null

@rpc("any_peer","call_local")
func update_owner(id):
	set_multiplayer_authority(id)
	cam.current = is_authority()

func is_authority():
	return get_multiplayer_authority()==multiplayer.get_unique_id()

func _input(event):
	if not is_authority(): return
	look(event as InputEventMouseMotion)

func _process(delta):
	if Input.is_action_just_pressed("NextCharacter"):
		next_player()
	if Input.is_action_just_pressed("PrevCharacter"):
		prev_player()
	if selected_char:
		global_position = selected_char.global_position
	else:
		next_player()

func next_player():
	var players = get_tree().get_nodes_in_group("player")
	selected_pos = (selected_pos+1)%players.size()
	selected_char = players[selected_pos]

func prev_player():
	var players = get_tree().get_nodes_in_group("player")
	selected_pos = (selected_pos-1)%players.size()
	selected_char = players[selected_pos]

func look(motion:InputEventMouseMotion):
	if not motion or Input.mouse_mode!=Input.MOUSE_MODE_CAPTURED: return
	spring.rotation.x -= motion.relative.y*Settings.mouse_sense
	spring.rotation_degrees.x = clamp(spring.rotation_degrees.x,-70,80)
	rotation.y -= motion.relative.x*Settings.mouse_sense
