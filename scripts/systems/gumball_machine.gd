extends RigidBody3D

# Island Arcade - Gumball Machine
# Cosmetic prop. When shot, gumballs spill out. South Padre Island vibes.

var is_broken: bool = false

func take_damage(_amount: int, _is_headshot: bool = false) -> void:
	if is_broken:
		return
	is_broken = true
	
	# Spawn gumballs
	for i in range(15):
		var gumball = RigidBody3D.new()
		var sphere = SphereShape3D.new()
		sphere.radius = 0.03
		var col = CollisionShape3D.new()
		col.shape = sphere
		gumball.add_child(col)
		
		# Visual
		var mesh_inst = MeshInstance3D.new()
		var sphere_mesh = SphereMesh.new()
		sphere_mesh.radius = 0.03
		sphere_mesh.height = 0.06
		mesh_inst.mesh = sphere_mesh
		
		# Random gumball color
		var colors = [Color.RED, Color.YELLOW, Color.GREEN, Color.BLUE, Color.ORANGE, Color.MAGENTA]
		var mat = StandardMaterial3D.new()
		mat.albedo_color = colors[i % colors.size()]
		mat.roughness = 0.3
		mesh_inst.material_override = mat
		gumball.add_child(mesh_inst)
		
		# Position and launch
		gumball.position = global_position + Vector3(randf_range(-0.2, 0.2), 0.5, randf_range(-0.2, 0.2))
		gumball.apply_impulse(Vector3(randf_range(-2, 2), randf_range(1, 4), randf_range(-2, 2)))
		
		get_parent().add_child(gumball)
		
		# Auto-cleanup after 10 seconds
		var timer = get_tree().create_timer(10.0)
		timer.timeout.connect(gumball.queue_free)
	
	AudioManager.play_sfx_at_position("res://assets/audio/sfx/ambient/glass_break.ogg", global_position)