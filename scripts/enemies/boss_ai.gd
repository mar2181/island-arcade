extends "res://scripts/enemies/base_enemy.gd"

# Island Arcade - Boss Glitch
# Large enemy that spawns minions. Appears on waves 5 and 10.
# HP: 300 (600 on wave 10) | Speed: 1.5 m/s | Contact Damage: 30
# Visual: Tall imposing figure with crimson glow, pulsing energy

@export var minion_spawn_interval: float = 8.0
@export var minions_per_spawn: int = 2

var minion_spawn_timer: float = 0.0
var is_final_boss: bool = false

func _ready() -> void:
	if GameManager.current_wave >= 10:
		max_hp = 600
		is_final_boss = true
	else:
		max_hp = 300
	
	move_speed = 1.5
	contact_damage = 30
	points_value = 1000
	minion_spawn_timer = minion_spawn_interval
	super._ready()

func _setup_mesh() -> void:
	# Main body - large torso
	var body = MeshInstance3D.new()
	var body_mesh = CapsuleMesh.new()
	body_mesh.radius = 0.5
	body_mesh.height = 1.8
	body.mesh = body_mesh
	body.position = Vector3(0, 1.0, 0)
	var body_mat = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.3, 0.0, 0.1)
	body_mat.roughness = 0.3
	body_mat.metallic = 0.5
	body_mat.emission_enabled = true
	body_mat.emission = Color(0.6, 0.0, 0.15)
	body_mat.emission_energy = 2.0
	body.material_override = body_mat
	mesh.add_child(body)
	
	# Head - large cube (glitch boss)
	var head = MeshInstance3D.new()
	var head_mesh = BoxMesh.new()
	head_mesh.size = Vector3(0.6, 0.5, 0.5)
	head.mesh = head_mesh
	head.position = Vector3(0, 2.1, 0)
	var head_mat = StandardMaterial3D.new()
	head_mat.albedo_color = Color(0.4, 0.0, 0.15)
	head_mat.roughness = 0.2
	head_mat.metallic = 0.6
	head_mat.emission_enabled = true
	head_mat.emission = Color(0.8, 0.0, 0.2)
	head_mat.emission_energy = 3.0
	head.material_override = head_mat
	mesh.add_child(head)
	
	# Eyes - three red eyes (center + sides)
	var eye_positions = [Vector3(-0.12, 2.15, -0.24), Vector3(0.12, 2.15, -0.24), Vector3(0.0, 2.22, -0.24)]
	for pos in eye_positions:
		var eye = MeshInstance3D.new()
		var eye_mesh = BoxMesh.new()
		eye_mesh.size = Vector3(0.08, 0.08, 0.08)
		eye.mesh = eye_mesh
		eye.position = pos
		var eye_mat = StandardMaterial3D.new()
		eye_mat.albedo_color = Color.RED
		eye_mat.emission_enabled = true
		eye_mat.emission = Color.RED
		eye_mat.emission_energy = 6.0
		eye.material_override = eye_mat
		mesh.add_child(eye)
	
	# Shoulders - two floating cubes
	for side in [-1, 1]:
		var shoulder = MeshInstance3D.new()
		var shoulder_mesh = BoxMesh.new()
		shoulder_mesh.size = Vector3(0.3, 0.3, 0.3)
		shoulder.mesh = shoulder_mesh
		shoulder.position = Vector3(side * 0.65, 1.7, 0)
		var shoulder_mat = StandardMaterial3D.new()
		shoulder_mat.albedo_color = Color(0.35, 0.0, 0.1)
		shoulder_mat.emission_enabled = true
		shoulder_mat.emission = Color(0.7, 0.0, 0.2)
		shoulder_mat.emission_energy = 2.5
		shoulder.material_override = shoulder_mat
		mesh.add_child(shoulder)
	
	# Crown spikes for final boss
	if is_final_boss:
		for i in range(3):
			var spike = MeshInstance3D.new()
			var spike_mesh = BoxMesh.new()
			spike_mesh.size = Vector3(0.05, 0.3, 0.05)
			spike.mesh = spike_mesh
			spike.position = Vector3(-0.15 + i * 0.15, 2.5, 0)
			var spike_mat = StandardMaterial3D.new()
			spike_mat.albedo_color = Color(1.0, 0.8, 0.0)
			spike_mat.emission_enabled = true
			spike_mat.emission = Color(1.0, 0.8, 0.0)
			spike_mat.emission_energy = 5.0
			spike.material_override = spike_mat
			mesh.add_child(spike)
	
	# Intense glow light
	var glow = OmniLight3D.new()
	glow.light_color = Color(0.8, 0.0, 0.2)
	glow.light_energy = 3.0
	glow.light_range = 8.0
	glow.position = Vector3(0, 1.5, 0)
	mesh.add_child(glow)

func _physics_process(delta: float) -> void:
	if is_dead or is_spawning:
		return
	
	super._physics_process(delta)
	
	# Pulse the glow intensity
	if mesh and mesh.get_child_count() > 0:
		for child in mesh.get_children():
			if child is OmniLight3D:
				child.light_energy = 3.0 + sin(Time.get_ticks_msec() / 300.0) * 1.0
	
	minion_spawn_timer -= delta
	if minion_spawn_timer <= 0.0:
		_spawn_minions()
		minion_spawn_timer = minion_spawn_interval

func _spawn_minions() -> void:
	for i in range(minions_per_spawn):
		var minion_scene = preload("res://scenes/enemies/glitch.tscn")
		var minion = minion_scene.instantiate()
		get_tree().current_scene.add_child(minion)
		var offset = Vector3(randf_range(-2.0, 2.0), 0.0, randf_range(-2.0, 2.0))
		minion.global_position = global_position + offset
		if get_tree().current_scene.has_node("WaveManager"):
			get_tree().current_scene.get_node("WaveManager").on_enemy_spawned(minion)

func die(is_headshot: bool = false) -> void:
	if is_dead:
		return
	is_dead = true
	
	_trigger_screen_shake()
	GameManager.add_score(points_value, is_headshot, spawn_time)
	_drop_ammo_crate()
	
	AudioManager.play_sfx("res://assets/audio/sfx/enemies/boss_death.ogg", 1.0, 5.0)
	enemy_died.emit(points_value, global_position)
	
	await get_tree().create_timer(0.5).timeout
	queue_free()

func _trigger_screen_shake() -> void:
	var camera = get_viewport().get_camera_3d()
	if camera:
		var tween = create_tween()
		var orig_h = camera.h_offset
		for i in range(6):
			var shake_x = randf_range(-0.3, 0.3)
			var shake_y = randf_range(-0.3, 0.3)
			tween.tween_property(camera, "h_offset", shake_x, 0.03)
			tween.tween_property(camera, "v_offset", shake_y, 0.03)
			tween.tween_property(camera, "h_offset", orig_h, 0.05)
			tween.tween_property(camera, "v_offset", 0.0, 0.05)

func _drop_ammo_crate() -> void:
	var ammo_pickup = preload("res://scenes/game/ammo_pickup.tscn").instantiate()
	get_tree().current_scene.add_child(ammo_pickup)
	ammo_pickup.global_position = global_position + Vector3(0.0, 0.5, 0.0)

func _get_death_particle_color() -> Color:
	return Color(0.8, 0.0, 0.2)

func _get_emission_color() -> Color:
	return Color(0.6, 0.0, 0.15)
