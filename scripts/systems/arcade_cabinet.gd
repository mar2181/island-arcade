extends StaticBody3D

# Island Arcade - Arcade Cabinet
# Interactive prop. Screens glow, enemies spawn from them.
# Located on South Padre Island, TX

@export var cabinet_name: String = "GAME"
@export var screen_color: Color = Color(0.0, 0.8, 1.0)  # Default cyan
@export var is_spawn_point: bool = false
@export var is_boss_spawn: bool = false

@onready var screen_mesh: MeshInstance3D = $ScreenMesh
@onready var screen_light: OmniLight3D = $ScreenLight
@onready var body_mesh: MeshInstance3D = $BodyMesh
@onready var interact_area: Area3D = $InteractArea

var is_flashing: bool = false
var flash_timer: float = 0.0

func _ready() -> void:
	# Set screen color
	if screen_mesh:
		var mat = screen_mesh.get_surface_override_material(0) as StandardMaterial3D
		if mat:
			mat.emission = screen_color
			mat.albedo_color = screen_color
	if screen_light:
		screen_light.light_color = screen_color

func _process(delta: float) -> void:
	if is_flashing:
		flash_timer -= delta
		if flash_timer <= 0.0:
			is_flashing = false
			_reset_screen()

func flash_screen() -> void:
	# Called by the wave manager when an enemy is about to spawn
	is_flashing = true
	flash_timer = 0.5
	if screen_mesh:
		var mat = screen_mesh.get_surface_override_material(0) as StandardMaterial3D
		if mat:
			mat.emission = Color.WHITE
			mat.emission_energy = 8.0
	if screen_light:
		screen_light.light_energy = 10.0
	AudioManager.play_sfx_at_position("res://assets/audio/sfx/enemies/enemy_spawn.ogg", global_position)

func _reset_screen() -> void:
	if screen_mesh:
		var mat = screen_mesh.get_surface_override_material(0) as StandardMaterial3D
		if mat:
			mat.emission = screen_color
			mat.emission_energy = 2.0
	if screen_light:
		screen_light.light_energy = 2.0