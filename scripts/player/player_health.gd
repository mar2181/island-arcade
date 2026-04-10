extends Node

## Island Arcade - Player Health Component

signal health_changed(current_hp: int, max_hp: int)
signal player_died

const MAX_HP: int = 100
var current_hp: int = MAX_HP
var is_dead: bool = false

func take_damage(amount: int) -> void:
	if is_dead:
		return
	current_hp = maxi(current_hp - amount, 0)
	health_changed.emit(current_hp, MAX_HP)
	GameManager.on_player_damaged()
	if current_hp <= 0:
		die()

func heal(amount: int) -> void:
	if is_dead:
		return
	current_hp = mini(current_hp + amount, MAX_HP)
	health_changed.emit(current_hp, MAX_HP)

func die() -> void:
	is_dead = true
	player_died.emit()
	GameManager.on_player_died()

func reset() -> void:
	current_hp = MAX_HP
	is_dead = false
	health_changed.emit(current_hp, MAX_HP)
