extends Node3D

## Island Arcade - Pixel Blaster Weapon System
## Semi-auto hitscan pistol with arcade feel

signal ammo_changed(current_mag: int, reserve: int)
signal weapon_fired
signal weapon_reloaded
signal weapon_pickup_complete

@onready var player: CharacterBody3D = get_parent().get_parent()
@onready var raycast: RayCast3D = get_parent().get_node("RayCast3D")

const MAG_SIZE: int = 12
const RESERVE_MAX: int = 60
const FIRE_RATE: float = 0.15
const RELOAD_TIME: float = 1.5
const BODY_DAMAGE: int = 30
const HEAD_DAMAGE: int = 60

var current_mag: int = 0
var reserve_ammo: int = 0
var can_fire: bool = true
var is_reloading: bool = false
var is_weapon_picked_up: bool = true
var fire_cooldown: float = 0.0

@onready var muzzle_flash: OmniLight3D = $MuzzleFlash
@onready var weapon_model: Node3D = $WeaponModel
@onready var tracer: MeshInstance3D = $Tracer

var _muzzle_tween: Tween = null
var _tracer_tween: Tween = null

func _ready() -> void:
	current_mag = MAG_SIZE
	reserve_ammo = RESERVE_MAX
	ammo_changed.emit(current_mag, reserve_ammo)
	tracer.visible = false
	
	# Set up tracer mesh if it has none (procedural fallback)
	if tracer.mesh == null:
		var tracer_mesh = BoxMesh.new()
		tracer_mesh.size = Vector3(0.02, 0.02, 2.0)
		tracer.mesh = tracer_mesh
		var tracer_mat = StandardMaterial3D.new()
		tracer_mat.albedo_color = Color(0.0, 0.8, 1.0, 0.8)
		tracer_mat.emission_enabled = true
		tracer_mat.emission = Color(0.0, 0.8, 1.0)
		tracer_mat.emission_energy = 3.0
		tracer_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		tracer_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		tracer.material_override = tracer_mat

func _process(delta: float) -> void:
	if not is_weapon_picked_up:
		return
	
	if fire_cooldown > 0:
		fire_cooldown -= delta
	
	if Input.is_action_pressed("shoot") and can_fire and not is_reloading and fire_cooldown <= 0:
		fire()
	
	if Input.is_action_just_pressed("reload") and not is_reloading and current_mag < MAG_SIZE and reserve_ammo > 0:
		reload()

func fire() -> void:
	if current_mag <= 0:
		AudioManager.play_sfx("res://assets/audio/sfx/weapons/dry_fire.ogg", 1.0, -5.0)
		return
	
	current_mag -= 1
	fire_cooldown = FIRE_RATE
	weapon_fired.emit()
	
	raycast.force_raycast_update()
	GameManager.register_shot(raycast.is_colliding())
	
	if raycast.is_colliding():
		var hit_point = raycast.get_collision_point()
		var hit_normal = raycast.get_collision_normal()
		var collider = raycast.get_collider()
		
		if collider.has_method("take_damage"):
			var is_headshot = _check_headshot(collider, hit_point)
			var damage = HEAD_DAMAGE if is_headshot else BODY_DAMAGE
			collider.take_damage(damage, is_headshot)
		
		_spawn_impact(hit_point, hit_normal)
	
	_show_muzzle_flash()
	_show_tracer()
	AudioManager.play_sfx("res://assets/audio/sfx/weapons/pixel_blaster_fire.ogg", randf_range(0.9, 1.1), 0.0)
	_animate_recoil()
	
	ammo_changed.emit(current_mag, reserve_ammo)
	
	if current_mag <= 0 and reserve_ammo > 0:
		reload()

func reload() -> void:
	if is_reloading or current_mag == MAG_SIZE:
		return
	
	is_reloading = true
	can_fire = false
	AudioManager.play_sfx("res://assets/audio/sfx/weapons/reload_start.ogg")
	
	var tween = create_tween()
	tween.tween_property(weapon_model, "position:y", weapon_model.position.y - 0.15, 0.3)
	tween.tween_interval(RELOAD_TIME - 0.6)
	tween.tween_property(weapon_model, "position:y", weapon_model.position.y, 0.3)
	
	await tween.finished
	
	var ammo_needed = MAG_SIZE - current_mag
	var ammo_to_load = mini(ammo_needed, reserve_ammo)
	current_mag += ammo_to_load
	reserve_ammo -= ammo_to_load
	
	is_reloading = false
	can_fire = true
	weapon_reloaded.emit()
	ammo_changed.emit(current_mag, reserve_ammo)
	AudioManager.play_sfx("res://assets/audio/sfx/weapons/reload_end.ogg")

func add_ammo(amount: int) -> void:
	reserve_ammo = mini(reserve_ammo + amount, RESERVE_MAX)
	ammo_changed.emit(current_mag, reserve_ammo)

func pickup_weapon() -> void:
	is_weapon_picked_up = true
	weapon_model.visible = true
	var tween = create_tween()
	tween.tween_property(weapon_model, "position:z", weapon_model.position.z, 0.5).from(weapon_model.position.z - 0.5)
	weapon_pickup_complete.emit()

func _check_headshot(collider: Node, hit_point: Vector3) -> bool:
	var aabb = collider.get_aabb() if collider.has_method("get_aabb") else null
	if aabb:
		var head_zone_y = aabb.position.y + aabb.size.y * 0.7
		return hit_point.y > head_zone_y
	return hit_point.y > collider.global_position.y + 0.8

func _show_muzzle_flash() -> void:
	if _muzzle_tween and _muzzle_tween.is_valid():
		_muzzle_tween.kill()
	muzzle_flash.light_energy = 8.0
	_muzzle_tween = create_tween()
	_muzzle_tween.tween_property(muzzle_flash, "light_energy", 0.0, 0.05)

func _show_tracer() -> void:
	if _tracer_tween and _tracer_tween.is_valid():
		_tracer_tween.kill()
	tracer.visible = true
	_tracer_tween = create_tween()
	_tracer_tween.tween_interval(0.04)
	_tracer_tween.tween_callback(tracer.set_visible.bind(false))

func _spawn_impact(point: Vector3, normal: Vector3) -> void:
	var impact = preload("res://scenes/game/impact_effect.tscn").instantiate()
	get_tree().current_scene.add_child(impact)
	impact.global_position = point
	impact.look_at(point + normal, Vector3.UP)

func _animate_recoil() -> void:
	var tween = create_tween()
	var orig_rot = weapon_model.rotation_degrees
	tween.tween_property(weapon_model, "rotation_degrees:x", orig_rot.x - 3.0, 0.05)
	tween.tween_property(weapon_model, "rotation_degrees:x", orig_rot.x, 0.15)
