extends "res://scripts/enemies/base_enemy.gd"

## Island Arcade - Byte Enemy
## Small floating cube that circles the player then darts in.
## HP: 15 | Speed: 4 m/s | Contact Damage: 15
## Visual: Small rotating neon green cube with data stream trail

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

func _setup_mesh() -> void:
	# Main body - small floating cube
	var body = MeshInstance3D.new()
	var body_mesh = BoxMesh.new()
	body_mesh.size = Vector3(0.35, 0.35, 0.35)
	body.mesh = body_mesh
	body.position = Vector3(0, 0.8, 0)
	var body_mat = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.0, 0.4, 0.15)
	body_mat.roughness = 0.1
	body_mat.metallic = 0.6
	body_mat.emission_enabled = true
	body_mat.emission = Color(0.0, 1.0, 0.4)
	body_mat.emission_energy = 2.0
	body.material_override = body_mat
	mesh.add_child(body)
	
	# Inner core - smaller bright cube
	var core = MeshInstance3D.new()
	var core_mesh = BoxMesh.new()
	core_mesh.size = Vector3(0.15, 0.15, 0.15)
	core.mesh = core_mesh
	core.position = Vector3(0, 0.8, 0)
	var core_mat = StandardMaterial3D.new()
	core_mat.albedo_color = Color.WHITE
	core_mat.emission_enabled = true
	core_mat.emission = Color(0.5, 1.0, 0.7)
	core_mat.emission_energy = 5.0
	core.material_override = core_mat
	mesh.add_child(core)
	
	# Neon glow light
	var glow = OmniLight3D.new()
	glow.light_color = Color(0.0, 1.0, 0.4)
	glow.light_energy = 1.5
	glow.light_range = 3.0
	glow.position = Vector3(0, 0.8, 0)
	mesh.add_child(glow)

func _physics_process(delta: float) -> void:
	if is_dead or is_spawning or not player or not is_instance_valid(player):
		return
	
	# Rotate the mesh cube continuously
	if mesh and mesh.get_child_count() > 0:
		var body = mesh.get_child(0)
		if body:
			body.rotate_y(delta * 3.0)
			body.rotate_x(delta * 2.0)
	
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

func _get_death_particle_color() -> Color:
	return Color(0.0, 1.0, 0.4)

func _get_emission_color() -> Color:
	return Color(0.0, 1.0, 0.4)
