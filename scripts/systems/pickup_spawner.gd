extends Node3D

## Island Arcade - Pickup Spawner
## Periodically spawns ammo and health pickups at random locations

@export var ammo_scene: PackedScene
@export var health_scene: PackedScene
@export var spawn_points: Array[Marker3D] = []
@export var ammo_spawn_interval: float = 20.0
@export var health_spawn_interval: float = 30.0
@export var max_pickups_on_floor: int = 4

var ammo_timer: float = 10.0  # First ammo spawns faster
var health_timer: float = 20.0
var active_pickups: Array[Node3D] = []

func _process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	
	ammo_timer -= delta
	health_timer -= delta
	
	if ammo_timer <= 0.0:
		_spawn_pickup("ammo")
		ammo_timer = ammo_spawn_interval
	
	if health_timer <= 0.0:
		_spawn_pickup("health")
		health_timer = health_spawn_interval

func _spawn_pickup(type: String) -> void:
	# Don't exceed max pickups
	# Clean up collected pickups from array
	active_pickups = active_pickups.filter(func(p): return is_instance_valid(p))
	if active_pickups.size() >= max_pickups_on_floor:
		return
	
	var scene: PackedScene
	match type:
		"ammo":
			scene = ammo_scene if ammo_scene else preload("res://scenes/game/ammo_pickup.tscn")
		"health":
			scene = health_scene if health_scene else preload("res://scenes/game/health_pickup.tscn")
		_:
			return
	
	var pickup = scene.instantiate()
	get_tree().current_scene.add_child(pickup)
	
	# Random spawn point
	if spawn_points.size() > 0:
		var point = spawn_points.pick_random()
		pickup.global_position = point.global_position + Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0))
	else:
		pickup.global_position = Vector3(randf_range(-10.0, 10.0), 0.5, randf_range(-10.0, 10.0))
	
	active_pickups.append(pickup)
