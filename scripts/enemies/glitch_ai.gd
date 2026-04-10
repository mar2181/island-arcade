extends "res://scripts/enemies/base_enemy.gd"

## Island Arcade - Glitch Enemy
## Slow-moving humanoid pixel creature. Walks straight toward player.
## HP: 30 | Speed: 2 m/s | Contact Damage: 10

func _ready() -> void:
	max_hp = 30
	move_speed = 2.0
	contact_damage = 10
	points_value = 100
	super._ready()
