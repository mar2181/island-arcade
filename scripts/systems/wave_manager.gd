     1|     1|extends Node3D
     2|     2|
     3|     3|## Island Arcade - Wave Manager
     4|     4|## Controls wave progression, enemy spawning, and game flow
     5|     5|
     6|     6|signal wave_countdown(seconds: int)
     7|     7|signal all_enemies_cleared
     8|     8|
     9|     9|@export var spawn_points: Array[Marker3D] = []
    10|    10|@export var countdown_duration: int = 3
    11|    11|
    12|    12|var current_wave: int = 0
    13|    13|var enemies_alive: int = 0
    14|    14|var enemies_to_spawn: int = 0
    15|    15|var spawn_interval: float = 1.5
    16|    16|var spawn_timer: float = 0.0
    17|    17|var wave_active: bool = false
    18|    18|var total_enemies_in_wave: int = 0
    19|    19|
    20|    20|# Wave definitions: [glitches, bytes, bosses]
    21|    21|var wave_definitions: Dictionary = {
    22|    22|    1: [5, 0, 0],
    23|    23|    2: [8, 0, 0],
    24|    24|    3: [6, 3, 0],
    25|    25|    4: [10, 4, 0],
    26|    26|    5: [6, 4, 1],
    27|    27|    6: [12, 5, 0],
    28|    28|    7: [10, 6, 0],
    29|    29|    8: [14, 6, 0],
    30|    30|    9: [12, 8, 0],
    31|    31|    10: [15, 10, 1],
    32|    32|}
    33|    33|
    34|    34|func _ready() -> void:
    35|    35|    GameManager.wave_started.connect(_on_wave_started)
    36|    36|
    37|    37|func _process(delta: float) -> void:
    38|    38|    if not wave_active or GameManager.current_state != GameManager.GameState.PLAYING:
    39|    39|        return
    40|    40|    
    41|    41|    # Spawn enemies on interval
    42|    42|    if enemies_to_spawn > 0:
    43|    43|        spawn_timer -= delta
    44|    44|        if spawn_timer <= 0.0:
    45|    45|            _spawn_next_enemy()
    46|    46|            spawn_timer = spawn_interval
    47|    47|
    48|    48|func _on_wave_started(wave_number: int) -> void:
    49|    49|    current_wave = wave_number
    50|    50|    _start_wave(wave_number)
    51|    51|
    52|    52|func _start_wave(wave_number: int) -> void:
    53|    53|    var definition = wave_definitions.get(wave_number, [5 + wave_number * 2, wave_number, 0])
    54|    54|    var glitch_count: int = definition[0]
    55|    55|    var byte_count: int = definition[1]
    56|    56|    var boss_count: int = definition[2]
    57|    57|    
    58|    58|    total_enemies_in_wave = glitch_count + byte_count + boss_count
    59|    59|    enemies_to_spawn = total_enemies_in_wave
    60|    60|    enemies_alive = 0
    61|    61|    spawn_timer = 0.0
    62|    62|    wave_active = true
    63|    63|    
    64|    64|    # Build spawn queue
    65|    65|    _spawn_queue = []
    66|    66|    for i in range(glitch_count):
    67|    67|        _spawn_queue.append("glitch")
    68|    68|    for i in range(byte_count):
    69|    69|        _spawn_queue.append("byte")
    70|    70|    for i in range(boss_count):
    71|    71|        _spawn_queue.append("boss")
    72|    72|    
    73|    73|    # Shuffle the queue (but always spawn boss last)
    74|    74|    var bosses = _spawn_queue.filter(func(t): return t == "boss")
    75|    75|    var others = _spawn_queue.filter(func(t): return t != "boss")
    76|    76|    others.shuffle()
    77|    77|    _spawn_queue = others + bosses
    78|    78|
    79|    79|var _spawn_queue: Array = []
    80|    80|
    81|    81|func _spawn_next_enemy() -> void:
    82|    82|    if _spawn_queue.is_empty():
    83|    83|        return
    84|    84|    
    85|    85|    var enemy_type: String = _spawn_queue.pop_front()
    86|    86|    enemies_to_spawn -= 1
    87|    87|    
    88|    88|    # Pick random spawn point
    89|    89|    var spawn_point = spawn_points.pick_random() if spawn_points.size() > 0 else global_position
    90|    90|    var spawn_pos = spawn_point.global_position
    91|    91|    
    92|    92|    # Flash the cabinet screen before spawning
    93|    93|    _flash_cabinet(spawn_point)
    94|    94|    
    95|    95|    var enemy_scene: PackedScene
    96|    96|    match enemy_type:
    97|    97|        "glitch":
    98|    98|            enemy_scene = preload("res://scenes/enemies/glitch.tscn")
    99|    99|        "byte":
   100|   100|            enemy_scene = preload("res://scenes/enemies/byte.tscn")
   101|   101|        "boss":
   102|   102|            enemy_scene = preload("res://scenes/enemies/boss_glitch.tscn")
   103|   103|            # Boss always spawns from center cabinet
   104|   104|            if spawn_points.size() > 0:
   105|   105|                spawn_pos = spawn_points[0].global_position
   106|   106|    
   107|   107|    var enemy = enemy_scene.instantiate()
   108|   108|    get_tree().current_scene.add_child(enemy)
   109|   109|    enemy.global_position = spawn_pos + Vector3(0.0, 0.5, 0.0)
   110|   110|    
   111|   111|    # Connect death signal
   112|   112|    if enemy.has_signal("enemy_died"):
   113|   113|        enemy.enemy_died.connect(_on_enemy_died)
   114|   114|    elif enemy.has_signal("died"):
   115|   115|        enemy.died.connect(_on_enemy_died.bind(enemy))
   116|   116|    
   117|   117|    enemies_alive += 1
   118|   118|    on_enemy_spawned()
   119|   119|
   120|   120|func on_enemy_spawned() -> void:
   121|   121|    # Called when a new enemy enters the game (including boss minions)
   122|   122|    pass
   123|   123|
   124|   124|func _on_enemy_died(points: int, position: Vector3) -> void:
   125|   125|    enemies_alive -= 1
   126|   126|    if enemies_alive <= 0 and enemies_to_spawn <= 0:
   127|   127|        _wave_complete()
   128|   128|
   129|   129|func _wave_complete() -> void:
   130|   130|    wave_active = false
   131|   131|    all_enemies_cleared.emit()
   132|   132|    GameManager.on_wave_completed()
   133|   133|
   134|   134|func _flash_cabinet(spawn_point: Marker3D) -> void:
   135|   135|    # Find the cabinet mesh near this spawn point and flash it
   136|   136|    # This will be connected in the scene
   137|   137|    AudioManager.play_sfx_at_position("res://assets/audio/sfx/enemies/enemy_spawn.ogg", spawn_point.global_position)
   138|   138|