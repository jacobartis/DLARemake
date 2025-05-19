extends CharacterBody3D

@onready var cam_arm = %CamArm
@onready var cam = %Camera3D
@onready var vis = $VisibleDetector
@export var highlight: HighlightManager
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var can_move: bool = true: set=set_can_move
@export var controled:bool = false

var last_move_dir: Vector3 = Vector3.BACK
var rot_speed: float = 10

@rpc("any_peer","call_local")
func set_can_move(val):
	can_move = val

@rpc("any_peer","call_local","reliable")
func update_owner(id):
	set_multiplayer_authority(id)
	cam.current = is_authority()
	print(get_multiplayer_authority()," ",id)
	print(is_authority())

@rpc("any_peer","call_local","reliable")
func gain_control(id):
	if controled: return
	controled = true
	set_collision_layer_value(4,false)
	update_owner(id)

@rpc("any_peer","call_local","reliable")
func drop_control():
	set_multiplayer_authority(1)
	set_collision_layer_value(4,true)
	cam.current = false
	controled = false

func is_authority():
	return get_multiplayer_authority()==multiplayer.get_unique_id() and controled

func _input(event):
	if not is_authority(): return
	look(event as InputEventMouseMotion)

func look(motion:InputEventMouseMotion):
	if not motion or Input.mouse_mode!=Input.MOUSE_MODE_CAPTURED: return
	if not can_move: return
	cam_arm.rotation.x -= motion.relative.y*Settings.mouse_sense
	cam_arm.rotation_degrees.x = clamp(cam_arm.rotation_degrees.x,-70,80)
	cam_arm.rotation.y -= motion.relative.x*Settings.mouse_sense

func _process(delta):
	$OmniLight3D.visible = not can_move
	if not is_authority(): return
	%CamHolder.global_position = global_position

func _physics_process(delta):
	if not get_multiplayer_authority()==multiplayer.get_unique_id(): return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if not can_move or not controled: 
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		move_and_slide()
		return
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var raw_input = Input.get_vector("Left", "Right", "Forward", "Backward")
	var view = get_viewport().get_camera_3d()
	var forward = cam.global_basis.z
	var right = cam.global_basis.x
	var direction = forward*raw_input.y + right*raw_input.x
	direction.y = 0
	direction = direction.normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
	if direction.length()>.5:
		last_move_dir = direction
	var target_angle = Vector3.BACK.signed_angle_to(last_move_dir,Vector3.UP)
	global_rotation.y = lerp_angle(global_rotation.y,target_angle,rot_speed*delta)


func _on_visible_detector_screen_entered():
	set_can_move.rpc(false)


func _on_visible_detector_screen_exited():
	set_can_move.rpc(true)


func _on_kill_area_player_entered(player):
	if player.dead == true: return
	player.kill()
