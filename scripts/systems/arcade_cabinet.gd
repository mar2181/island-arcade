extends StaticBody3D

## Island Arcade - Arcade Cabinet
## Interactive prop. Screens glow, enemies spawn from them.
## Uses procedural neon screen if no model screen exists.

@export var cabinet_name: String = "GAME"
@export var screen_color: Color = Color(0.0, 0.8, 1.0)  # Default cyan
@export var is_spawn_point: bool = false
@export var is_boss_spawn: bool = false

var screen_mesh: MeshInstance3D
var screen_light: OmniLight3D
var body_mesh: Node3D
var interact_area: Area3D

var is_flashing: bool = false
var flash_timer: float = 0.0

func _ready() -> void:
	# Find or create child nodes
	body_mesh = get_node_or_null("BodyMesh")
	if not body_mesh:
		body_mesh = get_child(0) as Node3D  # Fallback to first child
	
	interact_area = get_node_or_null("InteractArea")
	
	# Set up screen mesh
	screen_mesh = get_node_or_null("ScreenMesh")
	if screen_mesh:
		_setup_screen()
	
	# Set up screen light
	screen_light = get_node_or_null("ScreenLight")
	if screen_light:
		screen_light.light_color = screen_color
		screen_light.light_energy = 2.0

func _setup_screen() -> void:
	# Create a screen quad mesh dynamically
	var quad = QuadMesh.new()
	quad.size = Vector2(0.5, 0.4)
	screen_mesh.mesh = quad
	var mat = StandardMaterial3D.new()
	mat.albedo_color = screen_color
	mat.emission_enabled = true
	mat.emission = screen_color
	mat.emission_energy = 2.0
	mat.roughness = 0.2
	mat.metallic = 0.0
	screen_mesh.material_override = mat
	screen_mesh.position = Vector3(0, 1.1, -0.35)

func _process(delta: float) -> void:
	if is_flashing:
		flash_timer -= delta
		if flash_timer <= 0.0:
			is_flashing = false
			_reset_screen()

func flash_screen() -> void:
	is_flashing = true
	flash_timer = 0.5
	if screen_mesh and screen_mesh.material_override:
		var mat = screen_mesh.material_override as StandardMaterial3D
		if mat:
			mat.emission = Color.WHITE
			mat.emission_energy = 8.0
	if screen_light:
		screen_light.light_energy = 10.0
	AudioManager.play_sfx_at_position("res://assets/audio/sfx/enemies/enemy_spawn.ogg", global_position)

func _reset_screen() -> void:
	if screen_mesh and screen_mesh.material_override:
		var mat = screen_mesh.material_override as StandardMaterial3D
		if mat:
			mat.emission = screen_color
			mat.emission_energy = 2.0
	if screen_light:
		screen_light.light_energy = 2.0
