extends CharacterBody3D

# Island Arcade - Player Controller
# First-person movement, camera, and input handling
# Set in South Padre Island, TX

const WALK_SPEED: float = 4.0
const SPRINT_SPEED: float = 7.0
const CROUCH_SPEED: float = 2.0
const JUMP_VELOCITY: float = 4.5
const VERTICAL_LOOK_LIMIT: float = 1.48
const DEFAULT_FOV: float = 90.0
const ADS_FOV: float = 70.0
const HEADBOB_FREQUENCY: float = 2.0
const HEADBOB_AMPLITUDE: float = 0.03

@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var camera_pivot: Node3D = $CameraPivot
@onready var weapon_holder: Node3D = $CameraPivot/WeaponHolder
@onready var raycast: RayCast3D = $CameraPivot/RayCast3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var health_component: Node = $PlayerHealth

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var is_sprinting: bool = false
var is_crouching: bool = false
var is_ads: bool = false
var headbob_time: float = 0.0
var mouse_sensitivity: float = 0.002
var current_fov: float = DEFAULT_FOV
var stand_height: float = 1.7
var crouch_height: float = 1.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_sensitivity = SaveManager.get_setting("mouse_sensitivity", 0.002) * 0.002
	current_fov = SaveManager.get_setting("fov", DEFAULT_FOV)
	camera.fov = current_fov
	stand_height = camera_pivot.position.y
	crouch_height = stand_height - 0.7
	raycast.enabled = true

func _unhandled_input(event: InputEvent) -> void:
	if GameManager.current_state == GameManager.GameState.MENU:
		return
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		camera_pivot.rotation.x = clampf(camera_pivot.rotation.x, -VERTICAL_LOOK_LIMIT, VERTICAL_LOOK_LIMIT)
	
	if event.is_action_pressed("aim_down_sights"):
		is_ads = true
	if event.is_action_released("aim_down_sights"):
		is_ads = false
	
	if event.is_action_pressed("pause"):
		if GameManager.current_state == GameManager.GameState.PLAYING:
			GameManager.pause_game()
		elif GameManager.current_state == GameManager.GameState.PAUSED:
			GameManager.resume_game()

func _physics_process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	is_sprinting = Input.is_action_pressed("sprint") and is_on_floor() and not is_crouching
	if Input.is_action_pressed("crouch"):
		is_crouching = true
	elif Input.is_action_just_released("crouch"):
		is_crouching = false
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	
	var speed: float = WALK_SPEED
	if is_sprinting:
		speed = SPRINT_SPEED
	elif is_crouching:
		speed = CROUCH_SPEED
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity.z = move_toward(velocity.z, 0.0, speed)
	
	# Headbob
	if is_on_floor() and direction:
		headbob_time += delta * HEADBOB_FREQUENCY * speed
		camera_pivot.position.y = lerp(camera_pivot.position.y, stand_height + sin(headbob_time) * HEADBOB_AMPLITUDE * speed * 0.5, delta * 10.0)
	else:
		headbob_time = 0.0
	
	# Crouch / stand camera height
	var target_height = crouch_height if is_crouching else stand_height
	camera_pivot.position.y = lerp(camera_pivot.position.y, target_height, delta * 10.0)
	
	# Collision shape height
	if is_crouching:
		collision_shape.shape.height = lerp(collision_shape.shape.height, 1.0, delta * 10.0)
	else:
		collision_shape.shape.height = lerp(collision_shape.shape.height, 1.8, delta * 10.0)
	
	# ADS FOV
	var target_fov: float = ADS_FOV if is_ads else DEFAULT_FOV
	current_fov = lerpf(current_fov, target_fov, delta * 10.0)
	camera.fov = current_fov
	
	move_and_slide()

func get_aim_direction() -> Vector3:
	return -camera.global_transform.basis.z

func get_aim_origin() -> Vector3:
	return camera.global_position
