extends "res://scripts/enemies/base_enemy.gd"

## Island Arcade - Glitch Enemy
## Slow-moving humanoid pixel creature. Walks straight toward player.
## HP: 30 | Speed: 2 m/s | Contact Damage: 10
## Visual: Pixelated humanoid with neon magenta glow, glitch distortion

func _ready() -> void:
	max_hp = 30
	move_speed = 2.0
	contact_damage = 10
	points_value = 100
	super._ready()

func _setup_mesh() -> void:
	# Main body - tall capsule
	var body = MeshInstance3D.new()
	var body_mesh = CapsuleMesh.new()
	body_mesh.radius = 0.25
	body_mesh.height = 1.0
	body.mesh = body_mesh
	body.position = Vector3(0, 0.5, 0)
	var body_mat = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.4, 0.0, 0.3)
	body_mat.roughness = 0.4
	body_mat.metallic = 0.3
	body_mat.emission_enabled = true
	body_mat.emission = Color(1.0, 0.0, 0.8)
	body_mat.emission_energy = 1.5
	body.material_override = body_mat
	mesh.add_child(body)
	
	# Head - small cube (pixelated look)
	var head = MeshInstance3D.new()
	var head_mesh = BoxMesh.new()
	head_mesh.size = Vector3(0.3, 0.3, 0.3)
	head.mesh = head_mesh
	head.position = Vector3(0, 1.15, 0)
	var head_mat = StandardMaterial3D.new()
	head_mat.albedo_color = Color(0.5, 0.0, 0.4)
	head_mat.roughness = 0.3
	head_mat.metallic = 0.4
	head_mat.emission_enabled = true
	head_mat.emission = Color(1.0, 0.2, 0.9)
	head_mat.emission_energy = 2.0
	head.material_override = head_mat
	mesh.add_child(head)
	
	# Eyes - two small emissive cubes
	for eye_x in [-0.07, 0.07]:
		var eye = MeshInstance3D.new()
		var eye_mesh = BoxMesh.new()
		eye_mesh.size = Vector3(0.06, 0.06, 0.06)
		eye.mesh = eye_mesh
		eye.position = Vector3(eye_x, 1.18, -0.14)
		var eye_mat = StandardMaterial3D.new()
		eye_mat.albedo_color = Color.WHITE
		eye_mat.emission_enabled = true
		eye_mat.emission = Color.WHITE
		eye_mat.emission_energy = 4.0
		eye.material_override = eye_mat
		mesh.add_child(eye)
	
	# Point light for neon glow
	var glow = OmniLight3D.new()
	glow.light_color = Color(1.0, 0.0, 0.8)
	glow.light_energy = 1.0
	glow.light_range = 4.0
	glow.position = Vector3(0, 0.8, 0)
	mesh.add_child(glow)

func _get_death_particle_color() -> Color:
	return Color(1.0, 0.0, 0.8)

func _get_emission_color() -> Color:
	return Color(1.0, 0.0, 0.8)
