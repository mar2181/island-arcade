extends CharacterBody3D

## Island Arcade - Byte Enemy
## Small floating cube that circles the player then darts in.
## HP: 15 | Speed: 4 m/s | Contact Damage: 15

signal enemy_spawned(enemy: CharacterBody3D)
signal enemy_died(points: int, position: Vector3)

@export var max_hp: int = 15
@export var move_speed: float = 4.0
@export var contact_damage: int = 15
@export var points_value: int = 150

var current_hp: int
var is_dead: bool = false
var is_spawning: bool = true
var spawn_time: float = 0.0
var player: Node3D

# Orbit behavior
var orbit_angle: float = 0.0
var orbit_radius: float = 5.0
var orbit_speed: float = 2.0
var is_darting: bool = false
var dart_timer: float = 0.0
var dart_cooldown: float = 4.0
var dart_duration: float = 0.3
var dart_direction: Vector3 = Vector3.ZERO
var hover_height: float = 1.0

func _ready() -> void:
	current_hp = max_hp
	spawn_time = Time.get_ticks_msec() / 1000.0
	player = get_tree().get_first_node_in_group("player")
	orbit_angle = randf() * TAU
	dart_timer = dart_cooldown
	
	# Spawn in
	var mesh = $Mesh if has_node("Mesh") else null
	if mesh:
		mesh.visible = false
		await get_tree().create_timer(0.5).timeout
		mesh.visible = true
	is_spawning = false

func _physics_process(delta: float) -> void:
	if is_dead or is_spawning or not player or not is_instance_valid(player):
		return
	
	dart_timer -= delta
	
	if is_darting:
		# Dart toward player
		velocity = dart_direction * move_speed * 3.0
		velocity.y = 0.0
		dart_duration -= delta
		if dart_duration <= 0.0:
			is_darting = false
			dart_timer = dart_cooldown
	else:
		# Orbit around player
		orbit_angle += orbit_speed * delta
		
		var target_pos = player.global_position
		target_pos.x += cos(orbit_angle) * orbit_radius
		target_pos.z += sin(orbit_angle) * orbit_radius
		target_pos.y = hover_height
		
		var direction = (target_pos - global_position).normalized()
		velocity = direction * move_speed
		
		# Start dart when cooldown is done
		if dart_timer <= 0.0:
			is_darting = true
			dart_direction = (player.global_position - global_position).normalized()
			dart_duration = 0.3
	
	move_and_slide()
	
	# Contact damage
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() == player:
			if player.has_node("PlayerHealth"):
				player.get_node("PlayerHealth").take_damage(contact_damage)
			is_darting = false
			dart_timer = dart_cooldown
			break

func take_damage(amount: int, is_headshot: bool = false) -> void:
	if is_dead or is_spawning:
		return
	current_hp -= amount
	if current_hp <= 0:
		die(is_headshot)

func die(is_headshot: bool = false) -> void:
	if is_dead:
		return
	is_dead = true
	GameManager.add_score(points_value, is_headshot, spawn_time)
	AudioManager.play_sfx_at_position("res://assets/audio/sfx/enemies/byte_death.ogg", global_position)
	enemy_died.emit(points_value, global_position)
	queue_free()
