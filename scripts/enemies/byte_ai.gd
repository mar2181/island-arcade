extends "res://scripts/enemies/base_enemy.gd"

## Island Arcade - Byte Enemy
## Small floating cube that circles the player then darts in.
## HP: 15 | Speed: 4 m/s | Contact Damage: 15

@export var orbit_radius: float = 5.0
@export var orbit_speed: float = 2.0
@export var dart_cooldown_time: float = 4.0
@export var dart_duration_time: float = 0.3

var is_darting: bool = false
var dart_timer: float = 0.0
var dart_direction: Vector3 = Vector3.ZERO
var orbit_angle: float = 0.0
var hover_height: float = 1.0

func _ready() -> void:
	max_hp = 15
	move_speed = 4.0
	contact_damage = 15
	points_value = 150
	super._ready()
	orbit_angle = randf() * TAU
	dart_timer = dart_cooldown_time

func _physics_process(delta: float) -> void:
	if is_dead or is_spawning or not player or not is_instance_valid(player):
		return
	
	dart_timer -= delta
	
	if is_darting:
		velocity = dart_direction * move_speed * 3.0
		velocity.y = 0.0
		dart_duration_time -= delta
		if dart_duration_time <= 0.0:
			is_darting = false
			dart_timer = dart_cooldown_time
	else:
		orbit_angle += orbit_speed * delta
		
		var target_pos = player.global_position
		target_pos.x += cos(orbit_angle) * orbit_radius
		target_pos.z += sin(orbit_angle) * orbit_radius
		target_pos.y = hover_height
		
		var direction = (target_pos - global_position).normalized()
		velocity = direction * move_speed
		
		if dart_timer <= 0.0:
			is_darting = true
			dart_direction = (player.global_position - global_position).normalized()
			dart_duration_time = 0.3
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() == player:
			if player.has_node("PlayerHealth"):
				player.get_node("PlayerHealth").take_damage(contact_damage)
			is_darting = false
			dart_timer = dart_cooldown_time
			break

func die(is_headshot: bool = false) -> void:
	if is_dead:
		return
	is_dead = true
	GameManager.add_score(points_value, is_headshot, spawn_time)
	AudioManager.play_sfx_at_position("res://assets/audio/sfx/enemies/byte_death.ogg", global_position)
	enemy_died.emit(points_value, global_position)
	queue_free()
