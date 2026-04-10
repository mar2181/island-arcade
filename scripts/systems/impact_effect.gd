extends Node3D

# Island Arcade - Impact Effect
# Brief particle burst at bullet impact point

var lifetime: float = 0.5
var elapsed: float = 0.0
var flash: MeshInstance3D

func _ready() -> void:
	# Create a simple flash effect
	flash = MeshInstance3D.new()
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = Vector2(0.2, 0.2)
	flash.mesh = quad_mesh
	var flash_mat = _create_flash_material()
	flash.material_override = flash_mat
	add_child(flash)
	flash.look_at(global_position + Vector3.UP)
	
	# Add small particles
	var particles = GPUParticles3D.new()
	var particle_mat = ParticleProcessMaterial.new()
	particle_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	particle_mat.particle_flag_disable_z = false
	particle_mat.direction = Vector3(0, 1, 0)
	particle_mat.spread = 60.0
	particle_mat.gravity = Vector3(0, -5.0, 0)
	particle_mat.initial_velocity_min = 1.0
	particle_mat.initial_velocity_max = 3.0
	
	# Particle mesh
	var square_mesh = QuadMesh.new()
	square_mesh.size = Vector2(0.05, 0.05)
	particles.mesh = square_mesh
	
	# Emissive material for particles
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.0, 0.8, 1.0)  # Cyan
	mat.emission_enabled = true
	mat.emission = Color(0.0, 0.8, 1.0)
	mat.emission_energy = 2.0
	square_mesh.material = mat
	
	particles.process_material = particle_mat
	particles.amount = 8
	particles.lifetime = 0.3
	particles.one_shot = true
	particles.explosiveness = 0.9
	add_child(particles)
	particles.emitting = true

func _create_flash_material() -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1, 1, 1, 1)
	mat.emission_enabled = true
	mat.emission = Color(0.5, 0.9, 1.0)
	mat.emission_energy = 4.0
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	return mat

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= lifetime:
		queue_free()
	else:
		var alpha = 1.0 - (elapsed / lifetime)
		if flash and flash.material_override:
			var mat = flash.material_override as StandardMaterial3D
			if mat:
				mat.albedo_color.a = alpha
