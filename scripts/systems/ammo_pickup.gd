extends Area3D

## Island Arcade - Ammo Pickup
## Glowing blue ammo boxes scattered around the arcade

@export var ammo_amount: int = 6  # Loose ammo = +6, Crate = +12

var is_collected: bool = false

@onready var mesh_node: Node3D = $AmmoMesh
@onready var glow_light: OmniLight3D = $GlowLight
@onready var collect_area: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
    if is_collected:
        return
    # Gentle float animation
    if mesh_node:
        mesh_node.position.y = 0.3 + sin(Time.get_ticks_msec() / 500.0 + hash(global_position)) * 0.1
    # Rotate slowly
    if mesh_node:
        mesh_node.rotate_y(delta * 2.0)

func _on_body_entered(body: Node3D) -> void:
    if is_collected:
        return
    if body.is_in_group("player"):
        is_collected = true
        # Add ammo to player weapon
        var weapon = body.get_node_or_null("CameraPivot/WeaponHolder/Weapon")
        if weapon and weapon.has_method("add_ammo"):
            weapon.add_ammo(ammo_amount)
        # Play pickup sound
        AudioManager.play_sfx("res://assets/audio/sfx/weapons/ammo_pickup.ogg", 1.0, -3.0)
        # Quick collect animation then disappear
        var tween = create_tween()
        tween.tween_property(mesh_node, "scale", Vector3.ZERO, 0.2)
        tween.tween_property(glow_light, "light_energy", 0.0, 0.2)
        await tween.finished
        queue_free()
