     1|extends "res://scripts/enemies/base_enemy.gd"
     2|
     3|## Island Arcade - Boss Glitch
     4|## Large enemy that spawns minions. Appears on waves 5 and 10.
     5|## HP: 300 (600 on wave 10) | Speed: 1.5 m/s | Contact Damage: 30
     6|
     7|@export var minion_spawn_interval: float = 8.0
     8|@export var minions_per_spawn: int = 2
     9|
    10|var minion_spawn_timer: float = 0.0
    11|var is_final_boss: bool = false
    12|
    13|func _ready() -> void:
    14|    # Wave 10 boss is double HP
    15|    if GameManager.current_wave >= 10:
    16|        max_hp = 600
    17|        is_final_boss = true
    18|    else:
    19|        max_hp = 300
    20|    
    21|    move_speed = 1.5
    22|    contact_damage = 30
    23|    points_value = 1000
    24|    minion_spawn_timer = minion_spawn_interval
    25|    super._ready()
    26|
    27|func _physics_process(delta: float) -> void:
    28|    if is_dead or is_spawning:
    29|        return
    30|    
    31|    super._physics_process(delta)
    32|    
    33|    # Spawn minions periodically
    34|    minion_spawn_timer -= delta
    35|    if minion_spawn_timer <= 0.0:
    36|        _spawn_minions()
    37|        minion_spawn_timer = minion_spawn_interval
    38|
    39|func _spawn_minions() -> void:
    40|    for i in range(minions_per_spawn):
    41|        var minion_scene = preload("res://scenes/enemies/glitch.tscn")
    42|        var minion = minion_scene.instantiate()
    43|        get_tree().current_scene.add_child(minion)
    44|        # Spawn near the boss
    45|        var offset = Vector3(randf_range(-2.0, 2.0), 0.0, randf_range(-2.0, 2.0))
    46|        minion.global_position = global_position + offset
    47|        # Notify wave manager
    48|        if get_tree().current_scene.has_node("WaveManager"):
    49|            get_tree().current_scene.get_node("WaveManager").on_enemy_spawned()
    50|
    51|func die(is_headshot: bool = false) -> void:
    52|    if is_dead:
    53|        return
    54|    is_dead = true
    55|    
    56|    # Screen shake effect
    57|    _trigger_screen_shake()
    58|    
    59|    # Big death explosion
    60|    var points = GameManager.add_score(points_value, is_headshot, spawn_time)
    61|    
    62|    # Drop ammo crate
    63|    _drop_ammo_crate()
    64|    
    65|    AudioManager.play_sfx("res://assets/audio/sfx/enemies/boss_death.ogg", 1.0, 5.0)
    66|    enemy_died.emit(points_value, global_position)  # base points, not combo-adjusted
    67|    
    68|    # Extended death animation
    69|    await get_tree().create_timer(0.5).timeout
    70|    queue_free()
    71|
    72|func _trigger_screen_shake() -> void:
    73|    var camera = get_viewport().get_camera_3d()
    74|    if camera:
    75|        var tween = create_tween()
    76|        var orig_pos = camera.h_offset
    77|        for i in range(6):
    78|            var shake_offset = Vector2(randf_range(-0.3, 0.3), randf_range(-0.3, 0.3))
    79|            tween.tween_property(camera, "h_offset", shake_offset.x, 0.03)
    80|            tween.tween_property(camera, "v_offset", shake_offset.y, 0.03)
    81|        tween.tween_property(camera, "h_offset", orig_pos, 0.05)
    82|        tween.tween_property(camera, "v_offset", 0.0, 0.05)
    83|
    84|func _drop_ammo_crate() -> void:
    85|    var ammo_pickup = preload("res://scenes/game/ammo_pickup.tscn").instantiate()
    86|    get_tree().current_scene.add_child(ammo_pickup)
    87|    ammo_pickup.global_position = global_position + Vector3(0.0, 0.5, 0.0)
    88|