extends CharacterBody3D

signal new_controller()
signal control_dropped()

@onready var cam_arm = %CamArm
@onready var cam = %Camera3D
@onready var vis = $VisibleDetector
@export var highlight: HighlightManager
@export var interactor:Interactor

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var can_move: bool = true: set=set_can_move
@export var controlled:bool = false

var last_move_dir: Vector3 = Vector3.BACK
var rot_speed: float = 10

@rpc("any_peer","call_local")
func set_can_move(val):
	can_move = val

@rpc("any_peer","call_local","reliable")
func update_owner(id):
	set_multiplayer_authority(id)
	cam.current = is_authority()

@rpc("any_peer","call_local","reliable")
func gain_control(id):
	if controlled: return
	update_owner(id)
	controlled = true
	new_controller.emit()
	if is_killer():
		if is_authority():
			highlight.hide()
		else:
			highlight.highlight(Color.BLACK)

@rpc("any_peer","call_local","reliable")
func drop_control():
	if is_killer():
		if is_authority():
			highlight.show()
		highlight.highlight(Color.WHITE)
	set_multiplayer_authority(1)
	control_dropped.emit()
	cam.current = false
	controlled = false

func _ready():
	if not is_killer():
		highlight.hide()

func is_killer():
	return GameInfo.role(multiplayer.get_unique_id()) == "Killer"

func is_authority():
	return get_multiplayer_authority()==multiplayer.get_unique_id()

func _input(event):
	if not is_authority(): return
	look(event as InputEventMouseMotion)

func look(motion:InputEventMouseMotion):
	if not motion or Input.mouse_mode!=Input.MOUSE_MODE_CAPTURED: return
	%CamHolder.rotation.x -= motion.relative.y*Settings.mouse_sense
	%CamHolder.rotation_degrees.x = clamp(%CamHolder.rotation_degrees.x,-70,80)
	%CamHolder.rotation.y -= motion.relative.x*Settings.mouse_sense

func _process(delta):
	if not is_authority(): return
	%CamHolder.global_position = global_position+Vector3(0,1,0)

func _physics_process(delta):
	if not get_multiplayer_authority()==multiplayer.get_unique_id(): return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if not can_move or not controlled: 
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
