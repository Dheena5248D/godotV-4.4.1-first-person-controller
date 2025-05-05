extends CharacterBody3D

@onready var cam_mount: Node3D = $cam_mount
@onready var camera_3d: Camera3D = $cam_mount/Camera3D

var BASE_FOV = 75.0
var CHANGE_FOV = 1.5

var bob_freq = 2.0
var bob_amp = 0.08
var t_bob = 0.0

var hori_sens = 0.002
const SPRINT_SPEED = 10.0
const WALK_SPEED = 5.0
const JUMP_VELOCITY = 4.5
var SPEED = WALK_SPEED
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is  InputEventMouseMotion:
		cam_mount.rotate_y(-event.relative.x * hori_sens)
		camera_3d.rotate_x(-event.relative.y * hori_sens)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (cam_mount.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if Input.is_action_pressed("aprint"):
			SPEED = SPRINT_SPEED
		else:
			SPEED = WALK_SPEED
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x =  lerp(velocity.x, direction.x * SPEED, delta * 3)
			velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 3)

		t_bob += delta * velocity.length() * float(is_on_floor())
		camera_3d.transform.origin = _headbob(t_bob)
	else:
		velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 1)
		velocity.y = lerp(velocity.y, direction.y * SPEED, delta * 1)
	
	# FOV
	
	var TARGET_FOV = BASE_FOV + CHANGE_FOV * velocity.length()
	camera_3d.fov = lerp(camera_3d.fov, TARGET_FOV, delta * 10.0)
	move_and_slide()
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_freq) * bob_amp
	pos.x = cos(time * bob_freq /2) * bob_amp	
	return pos
