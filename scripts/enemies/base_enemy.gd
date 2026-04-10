extends CharacterBody3D

# Island Arcade - Base Enemy
# Shared logic for all enemy types

signal enemy_spawned(enemy: CharacterBody3D)
signal enemy_died(points: int, position: Vector3)
signal enemy_hit

@export var max_hp: int = 30
@export var move_speed: float = 2.0
@export var contact_damage: int = 10
@export var points_value: int = 100

var current_hp: int
var is_dead: bool = false
var is_spawning: bool = true
var spawn_time: float = 0.0
var player: Node3D

@onready var mesh: Node3D = $Mesh
@onready var death_particles: GPUParticles3D = $DeathParticles if has_node("DeathParticles") else null
@onready var hitbox: CollisionShape3D = $Hitbox if has_node("Hitbox") else null

func _ready() -> void:
	current_hp = max_hp
	spawn_time = Time.get_ticks_msec() / 1000.0
	player = get_tree().get_first_node_in_group("player")
	
	if hitbox:
		hitbox.disabled = true
	
	# Play spawn animation
	await get_tree().create_timer(1.5).timeout
	
	is_spawning = false
	if hitbox:
		hitbox.disabled = false
	enemy_spawned.emit(self)

func _physics_process(delta: float) -> void:
	if is_dead or is_spawning:
		return
	if not player or not is_instance_valid(player):
		return
	
	# Move toward player
	var direction = (player.global_position - global_position)
	direction.y = 0.0
	direction = direction.normalized()
	
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	velocity.y -= 9.8 * delta
	
	# Face the player
	var flat_target = player.global_position
	flat_target.y = global_position.y
	look_at(flat_target)
	
	move_and_slide()
	
	# Contact damage
	if is_on_floor():
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider() == player:
				if player.has_node("PlayerHealth"):
					player.get_node("PlayerHealth").take_damage(contact_damage)
				break

func take_damage(amount: int, is_headshot: bool = false) -> void:
	if is_dead or is_spawning:
		return
	
	current_hp -= amount
	enemy_hit.emit()
	
	# Flash on hit
	_flash_hit()
	
	if current_hp <= 0:
		die(is_headshot)

func die(is_headshot: bool = false) -> void:
	if is_dead:
		return
	is_dead = true
	
	# Calculate score
	GameManager.add_score(points_value, is_headshot, spawn_time)
	
	# Death effect
	if death_particles:
		death_particles.emitting = true
		death_particles.global_position = global_position
		var particles_parent = get_tree().current_scene
		remove_child(death_particles)
		particles_parent.add_child(death_particles)
		await get_tree().create_timer(1.0).timeout
		death_particles.queue_free()
	
	AudioManager.play_sfx_at_position("res://assets/audio/sfx/enemies/enemy_death.ogg", global_position)
	enemy_died.emit(points_value, global_position)
	queue_free()

func _flash_hit() -> void:
	if mesh and mesh.has_method("set_instance_shader_parameter"):
		mesh.set_instance_shader_parameter("flash_intensity", 1.0)
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(mesh):
			mesh.set_instance_shader_parameter("flash_intensity", 0.0)
