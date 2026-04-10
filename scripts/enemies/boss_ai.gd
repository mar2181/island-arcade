extends "res://scripts/enemies/base_enemy.gd"

# Island Arcade - Boss Glitch
# Large enemy that spawns minions. Appears on waves 5 and 10.
# HP: 300 (600 on wave 10) | Speed: 1.5 m/s | Contact Damage: 30

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

func _physics_process(delta: float) -> void:
	if is_dead or is_spawning:
		return
	
	super._physics_process(delta)
	
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
			get_tree().current_scene.get_node("WaveManager").on_enemy_spawned()

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
