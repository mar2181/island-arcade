extends CharacterBody3D

## Island Arcade - Base Enemy
## Shared logic for all enemy types
## All enemies get procedural neon meshes

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
	
	_setup_mesh()
	_setup_death_particles()
	
	# Play spawn animation
	var spawn_tween = create_tween()
	spawn_tween.tween_property(self, "scale", Vector3.ONE, 0.3).from(Vector3(0.01, 0.01, 0.01))
	spawn_tween.tween_property(mesh, "scale", Vector3(1.1, 1.1, 1.1), 0.1)
	spawn_tween.tween_property(mesh, "scale", Vector3.ONE, 0.1)
	
	await get_tree().create_timer(1.5).timeout
	
	is_spawning = false
	if hitbox:
		hitbox.disabled = false
	enemy_spawned.emit(self)

func _setup_mesh() -> void:
	# Override in subclasses to set up unique visual
	pass

func _setup_death_particles() -> void:
	if not death_particles:
		return
	# Create particle material dynamically
	var process_mat = ParticleProcessMaterial.new()
	process_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process_mat.emission_box_extents = Vector3(0.3, 0.8, 0.3)
	process_mat.particle_flag_disable_z = false
	process_mat.direction = Vector3(0, 1, 0)
	process_mat.spread = 60.0
	process_mat.gravity = Vector3(0, -9.8, 0)
	process_mat.initial_velocity_min = 2.0
	process_mat.initial_velocity_max = 5.0
	process_mat.scale_min = 0.05
	process_mat.scale_max = 0.15
	death_particles.process_material = process_mat
	
	# Particle mesh - small glowing cubes
	var particle_mesh = BoxMesh.new()
	particle_mesh.size = Vector3(0.1, 0.1, 0.1)
	death_particles.mesh = particle_mesh
	
	# Emissive material for particles
	var particle_mat = StandardMaterial3D.new()
	particle_mat.albedo_color = _get_death_particle_color()
	particle_mat.emission_enabled = true
	particle_mat.emission = _get_death_particle_color()
	particle_mat.emission_energy = 3.0
	particle_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	particle_mesh.material = particle_mat

func _get_death_particle_color() -> Color:
	return Color(1.0, 0.0, 0.8)  # Default pink, override in subclass

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
	# Flash all MeshInstance3D children
	for child in mesh.get_children():
		if child is MeshInstance3D:
			for surf_idx in range(child.get_surface_count()):
				var mat = child.get_surface_override_material(surf_idx)
				if mat and mat is StandardMaterial3D:
					var orig_energy = mat.emission_energy
					mat.emission = Color.WHITE
					mat.emission_energy = 10.0
					await get_tree().create_timer(0.08).timeout
					if is_instance_valid(mat):
						mat.emission = _get_emission_color()
						mat.emission_energy = orig_energy

func _get_emission_color() -> Color:
	return Color(1.0, 0.0, 0.8)  # Default, override in subclass
