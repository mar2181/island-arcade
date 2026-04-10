     1|extends CharacterBody3D
     2|
     3|## Island Arcade - Player Controller
     4|## First-person movement, camera, and input handling
     5|## Set in South Padre Island, TX
     6|
     7|# Movement speeds (m/s)
     8|const WALK_SPEED: float = 4.0
     9|const SPRINT_SPEED: float = 7.0
    10|const CROUCH_SPEED: float = 2.0
    11|const JUMP_VELOCITY: float = 4.5
    12|const MOUSE_SENS_MIN: float = 0.05
    13|const MOUSE_SENS_MAX: float = 5.0
    14|const VERTICAL_LOOK_LIMIT: float = 1.48  # ~85 degrees in radians
    15|const DEFAULT_FOV: float = 90.0
    16|const ADS_FOV: float = 70.0
    17|const HEADBOB_FREQUENCY: float = 2.0
    18|const HEADBOB_AMPLITUDE: float = 0.03
    19|
    20|@onready var camera: Camera3D = $CameraPivot/Camera3D
    21|@onready var camera_pivot: Node3D = $CameraPivot
    22|@onready var weapon_holder: Node3D = $CameraPivot/WeaponHolder
    23|@onready var raycast: RayCast3D = $CameraPivot/RayCast3D
    24|@onready var collision_shape: CollisionShape3D = $CollisionShape3D
    25|@onready var health_component: Node = $PlayerHealth
    26|
    27|var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
    28|
    29|# State
    30|var is_sprinting: bool = false
    31|var is_crouching: bool = false
    32|var is_ads: bool = false
    33|var headbob_time: float = 0.0
    34|var mouse_sensitivity: float = 0.002
    35|var current_fov: float = DEFAULT_FOV
    36|var stand_height: float = 1.7
    37|var crouch_height: float = 1.0
    38|
    39|func _ready() -> void:
    40|    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    41|    mouse_sensitivity = SaveManager.get_setting("mouse_sensitivity", 0.002) * 0.002
    42|    current_fov = SaveManager.get_setting("fov", DEFAULT_FOV)
    43|    camera.fov = current_fov
    44|    stand_height = camera_pivot.position.y
    45|    raycast.enabled = true
    46|
    47|func _unhandled_input(event: InputEvent) -> void:
    48|    if GameManager.current_state == GameManager.GameState.MENU:
    49|        return
    50|    
    51|    # Mouse look
    52|    if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
    53|        rotate_y(-event.relative.x * mouse_sensitivity)
    54|        camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
    55|        camera_pivot.rotation.x = clampf(camera_pivot.rotation.x, -VERTICAL_LOOK_LIMIT, VERTICAL_LOOK_LIMIT)
    56|    
    57|    # ADS toggle
    58|    if event.is_action_pressed("aim_down_sights"):
    59|        is_ads = true
    60|    if event.is_action_released("aim_down_sights"):
    61|        is_ads = false
    62|    
    63|    # Pause
    64|    if event.is_action_pressed("pause"):
    65|        if GameManager.current_state == GameManager.GameState.PLAYING:
    66|            GameManager.pause_game()
    67|        elif GameManager.current_state == GameManager.GameState.PAUSED:
    68|            GameManager.resume_game()
    69|
    70|func _physics_process(delta: float) -> void:
    71|    if GameManager.current_state != GameManager.GameState.PLAYING:
    72|        return
    73|    
    74|    # Gravity
    75|    if not is_on_floor():
    76|        velocity.y -= gravity * delta
    77|    
    78|    # Jump
    79|    if Input.is_action_just_pressed("jump") and is_on_floor():
    80|        velocity.y = JUMP_VELOCITY
    81|    
    82|    # Sprint & Crouch
    83|    is_sprinting = Input.is_action_pressed("sprint") and is_on_floor() and not is_crouching
    84|    if Input.is_action_pressed("crouch"):
    85|        is_crouching = true
    86|    elif Input.is_action_just_released("crouch"):
    87|        is_crouching = false
    88|    
    89|    # Movement direction
    90|    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
    91|    var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
    92|    
    93|    var speed: float = WALK_SPEED
    94|    if is_sprinting:
    95|        speed = SPRINT_SPEED
    96|    elif is_crouching:
    97|        speed = CROUCH_SPEED
    98|    
    99|    if direction:
   100|        velocity.x = direction.x * speed
   101|        velocity.z = direction.z * speed
   102|    else:
   103|        velocity.x = move_toward(velocity.x, 0.0, speed)
   104|        velocity.z = move_toward(velocity.z, 0.0, speed)
   105|    
   106|    # Headbob
   107|    if is_on_floor() and direction:
   108|        headbob_time += delta * HEADBOB_FREQUENCY * speed
   109|        camera_pivot.position.y = lerp(camera_pivot.position.y, stand_height + sin(headbob_time) * HEADBOB_AMPLITUDE * speed * 0.5, delta * 10.0)
   110|    else:
   111|        headbob_time = 0.0
   112|        camera_pivot.position.y = lerp(camera_pivot.position.y, stand_height if not is_crouching else crouch_height, delta * 10.0)
   113|    
   114|    # Crouch height
   115|    if is_crouching:
   116|        camera_pivot.position.y = lerp(camera_pivot.position.y, crouch_height, delta * 10.0)
   117|        collision_shape.shape.height = lerp(collision_shape.shape.height, 1.0, delta * 10.0)
   118|    else:
   119|        collision_shape.shape.height = lerp(collision_shape.shape.height, 1.8, delta * 10.0)
   120|    
   121|    # ADS FOV
   122|    var target_fov: float = ADS_FOV if is_ads else DEFAULT_FOV
   123|    current_fov = lerpf(current_fov, target_fov, delta * 10.0)
   124|    camera.fov = current_fov
   125|    
   126|    move_and_slide()
   127|
   128|func get_aim_direction() -> Vector3:
   129|    return -camera.global_transform.basis.z
   130|
   131|func get_aim_origin() -> Vector3:
   132|    return camera.global_position
   133|