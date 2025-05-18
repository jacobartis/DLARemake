extends CharacterBody3D

@onready var cam = $Camera3D
@onready var vis = $VisibleDetector

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var can_move: bool = true: set=set_can_move

@rpc("any_peer","call_local")
func set_can_move(val):
	can_move = val

@rpc("any_peer","call_local")
func update_owner(id):
	set_multiplayer_authority(id)
	cam.current = is_authority()

func is_authority():
	return get_multiplayer_authority()==multiplayer.get_unique_id()

func _input(event):
	if not is_authority(): return
	look(event as InputEventMouseMotion)

func look(motion:InputEventMouseMotion):
	if not motion or Input.mouse_mode!=Input.MOUSE_MODE_CAPTURED: return
	if not can_move: return
	cam.rotation.x -= motion.relative.y*Settings.mouse_sense
	cam.rotation_degrees.x = clamp(cam.rotation_degrees.x,-70,80)
	rotation.y -= motion.relative.x*Settings.mouse_sense

func _process(delta):
	$OmniLight3D.visible = not can_move
	if not is_authority(): return

func _physics_process(delta):
	if not is_authority(): return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if not can_move: 
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		move_and_slide()
		return
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _on_visible_detector_screen_entered():
	set_can_move.rpc(false)


func _on_visible_detector_screen_exited():
	set_can_move.rpc(true)
