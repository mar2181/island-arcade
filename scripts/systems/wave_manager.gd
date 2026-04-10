extends Node3D

# Island Arcade - Wave Manager
# Controls wave progression, enemy spawning, and game flow

signal wave_countdown(seconds: int)
signal all_enemies_cleared

@export var spawn_points: Array[Marker3D] = []
@export var countdown_duration: int = 3

var current_wave: int = 0
var enemies_alive: int = 0
var enemies_to_spawn: int = 0
var spawn_interval: float = 1.5
var spawn_timer: float = 0.0
var wave_active: bool = false
var total_enemies_in_wave: int = 0

var wave_definitions: Dictionary = {
	1: [5, 0, 0],
	2: [8, 0, 0],
	3: [6, 3, 0],
	4: [10, 4, 0],
	5: [6, 4, 1],
	6: [12, 5, 0],
	7: [10, 6, 0],
	8: [14, 6, 0],
	9: [12, 8, 0],
	10: [15, 10, 1],
}

var _spawn_queue: Array = []

func _ready() -> void:
	GameManager.wave_started.connect(_on_wave_started)
	# If game already started before this scene loaded (e.g. scene change/reload),
	# kick off the current wave immediately since we missed the signal
	if GameManager.current_state == GameManager.GameState.PLAYING:
		if GameManager.current_wave > 0:
			_on_wave_started(GameManager.current_wave)
		else:
			_on_wave_started(1)

func _process(delta: float) -> void:
	if not wave_active or GameManager.current_state != GameManager.GameState.PLAYING:
		return
	
	if enemies_to_spawn > 0:
		spawn_timer -= delta
		if spawn_timer <= 0.0:
			_spawn_next_enemy()
			spawn_timer = spawn_interval

func _on_wave_started(wave_number: int) -> void:
	current_wave = wave_number
	wave_active = false  # Reset before starting
	_start_wave(wave_number)

func _start_wave(wave_number: int) -> void:
	var definition = wave_definitions.get(wave_number, [5 + wave_number * 2, wave_number, 0])
	var glitch_count: int = definition[0]
	var byte_count: int = definition[1]
	var boss_count: int = definition[2]
	
	total_enemies_in_wave = glitch_count + byte_count + boss_count
	enemies_to_spawn = total_enemies_in_wave
	enemies_alive = 0
	spawn_timer = 0.0
	wave_active = true
	
	_spawn_queue = []
	for i in range(glitch_count):
		_spawn_queue.append("glitch")
	for i in range(byte_count):
		_spawn_queue.append("byte")
	for i in range(boss_count):
		_spawn_queue.append("boss")
	
	var bosses = _spawn_queue.filter(func(t): return t == "boss")
	var others = _spawn_queue.filter(func(t): return t != "boss")
	others.shuffle()
	_spawn_queue = others + bosses

func _spawn_next_enemy() -> void:
	if _spawn_queue.is_empty():
		return
	
	var enemy_type: String = _spawn_queue.pop_front()
	enemies_to_spawn -= 1
	
	var spawn_point = spawn_points.pick_random() if spawn_points.size() > 0 else global_position
	var spawn_pos = spawn_point.global_position
	
	_flash_cabinet(spawn_point)
	
	var enemy_scene: PackedScene
	match enemy_type:
		"glitch":
			enemy_scene = preload("res://scenes/enemies/glitch.tscn")
		"byte":
			enemy_scene = preload("res://scenes/enemies/byte.tscn")
		"boss":
			enemy_scene = preload("res://scenes/enemies/boss_glitch.tscn")
			if spawn_points.size() > 0:
				spawn_pos = spawn_points[0].global_position
	
	var enemy = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = spawn_pos + Vector3(0.0, 0.5, 0.0)

	if enemy.has_signal("enemy_died"):
		enemy.enemy_died.connect(_on_enemy_died)

	enemies_alive += 1

func on_enemy_spawned(enemy: CharacterBody3D = null) -> void:
	enemies_alive += 1
	if enemy and enemy.has_signal("enemy_died"):
		enemy.enemy_died.connect(_on_enemy_died)

func _on_enemy_died(points: int, position: Vector3) -> void:
	enemies_alive -= 1
	if enemies_alive <= 0 and enemies_to_spawn <= 0:
		_wave_complete()

func _wave_complete() -> void:
	wave_active = false
	all_enemies_cleared.emit()
	GameManager.on_wave_completed()

func _flash_cabinet(spawn_point: Marker3D) -> void:
	AudioManager.play_sfx_at_position("res://assets/audio/sfx/enemies/enemy_spawn.ogg", spawn_point.global_position)
