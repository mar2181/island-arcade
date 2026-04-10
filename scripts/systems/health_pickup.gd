extends Area3D

## Island Arcade - Health Pickup
## Green glowing health kits

@export var heal_amount: int = 25

var is_collected: bool = false

@onready var mesh_node: Node3D = $HealthMesh
@onready var glow_light: OmniLight3D = $GlowLight

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if is_collected:
		return
	if mesh_node:
		mesh_node.position.y = 0.3 + sin(Time.get_ticks_msec() / 600.0 + hash(global_position)) * 0.1
		mesh_node.rotate_y(delta * 1.5)

func _on_body_entered(body: Node3D) -> void:
	if is_collected:
		return
	if body.is_in_group("player"):
		is_collected = true
		var health = body.get_node_or_null("PlayerHealth")
		if health and health.has_method("heal"):
			health.heal(heal_amount)
		AudioManager.play_sfx("res://assets/audio/sfx/player/health_pickup.ogg", 1.0, -3.0)
		var tween = create_tween()
		tween.tween_property(mesh_node, "scale", Vector3.ZERO, 0.2)
		tween.tween_property(glow_light, "light_energy", 0.0, 0.2)
		await tween.finished
		queue_free()
