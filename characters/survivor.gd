extends CharacterBody3D

signal killed()
signal owner_updated()

@onready var cam = %Camera3D
@onready var aud = %AudioListener3D
@export var interactor:Interactor

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var dead:bool = false

@rpc("any_peer","call_local")
func update_owner(id):
	set_multiplayer_authority(id)
	cam.current = is_authority()
	aud.current = is_authority()
	$TorchLight.visible = is_authority()
	update_player_info()
	owner_updated.emit()

@rpc("any_peer","call_local","reliable")
func spawn_pos(pos):
	global_position = pos

func update_player_info():
	if GameInfo.role(multiplayer.get_unique_id())!="Survivor" or is_authority(): 
		%NamePlate.hide()
		return
	var info = MultiplayerManager.players[get_multiplayer_authority()]
	%NamePlate.text = info["name"]

func is_authority():
	return get_multiplayer_authority()==multiplayer.get_unique_id()

@rpc("any_peer","call_local","reliable")
func kill():
	dead = true
	cam.current = false
	killed.emit()
	%NamePlate.hide()

func _input(event):
	if not is_authority(): return
	look(event as InputEventMouseMotion)

func look(motion:InputEventMouseMotion):
	if not motion or Input.mouse_mode!=Input.MOUSE_MODE_CAPTURED: return
	if dead: return
	cam.rotation.x -= motion.relative.y*Settings.mouse_sense
	cam.rotation_degrees.x = clamp(cam.rotation_degrees.x,-70,80)
	rotation.y -= motion.relative.x*Settings.mouse_sense

func _process(delta):
	if not is_authority(): return

func _physics_process(delta):
	if not is_authority(): return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if dead:
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
