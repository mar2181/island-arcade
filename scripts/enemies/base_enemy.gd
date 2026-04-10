     1|     1|extends CharacterBody3D
     2|     2|
     3|     3|## Island Arcade - Base Enemy
     4|     4|## Shared logic for all enemy types
     5|     5|
     6|     6|signal enemy_spawned(enemy: CharacterBody3D)
     7|     7|signal enemy_died(points: int, position: Vector3)
     8|     8|signal enemy_hit
     9|     9|
    10|    10|@export var max_hp: int = 30
    11|    11|@export var move_speed: float = 2.0
    12|    12|@export var contact_damage: int = 10
    13|    13|@export var points_value: int = 100
    14|    14|
    15|    15|var current_hp: int
    16|    16|var is_dead: bool = false
    17|    17|var is_spawning: bool = true
    18|    18|var spawn_time: float = 0.0
    19|    19|var player: Node3D
    20|    20|
    21|    21|# References
    22|    22|@onready var mesh: Node3D = $Mesh
    23|    23|@onready var spawn_anim: AnimationPlayer = $SpawnAnimation if has_node("SpawnAnimation") else null
    24|    24|@onready var death_particles: GPUParticles3D = $DeathParticles if has_node("DeathParticles") else null
    25|    25|@onready var hitbox: CollisionShape3D = $Hitbox if has_node("Hitbox") else null
    26|    26|
    27|    27|func _ready() -> void:
    28|    28|    current_hp = max_hp
    29|    29|    spawn_time = Time.get_ticks_msec() / 1000.0
    30|    30|    player = get_tree().get_first_node_in_group("player")
    31|    31|    
    32|    32|    # Start in spawning state
    33|    33|    if hitbox:
    34|    34|        hitbox.disabled = true
    35|    35|    
    36|    36|    # Play spawn animation
    37|    37|    if spawn_anim:
    38|    38|        spawn_anim.play("spawn")
    39|    39|        await spawn_anim.animation_finished
    40|    40|    else:
    41|    41|        await get_tree().create_timer(1.5).timeout
    42|    42|    
    43|    43|    is_spawning = false
    44|    44|    if hitbox:
    45|    45|        hitbox.disabled = false
    46|    46|    enemy_spawned.emit(self)
    47|    47|
    48|    48|func _physics_process(delta: float) -> void:
    49|    49|    if is_dead or is_spawning:
    50|    50|        return
    51|    51|    if not player or not is_instance_valid(player):
    52|    52|        return
    53|    53|    
    54|    54|    # Move toward player
    55|    55|    var direction = (player.global_position - global_position)
    56|    56|    direction.y = 0.0
    57|    57|    direction = direction.normalized()
    58|    58|    
    59|    59|    velocity.x = direction.x * move_speed
    60|    60|    velocity.z = direction.z * move_speed
    61|    61|    velocity.y -= 9.8 * delta  # gravity
    62|    62|    
    63|    63|    # Face the player
    64|    64|    if direction.length() > 0.1:
    65|    65|        var flat_target = player.global_position
    66|	flat_target.y = global_position.y
    67|	look_at(flat_target)
    68|    66|    
    69|    67|    move_and_slide()
    70|    68|    
    71|    69|    # Contact damage
    72|    70|    if is_on_floor():
    73|    71|        for i in get_slide_collision_count():
    74|    72|            var collision = get_slide_collision(i)
    75|    73|            if collision.get_collider() == player:
    76|    74|                if player.has_node("PlayerHealth"):
    77|    75|                    player.get_node("PlayerHealth").take_damage(contact_damage)
    78|    76|                break
    79|    77|
    80|    78|func look_at_flat(target_pos: Vector3) -> void:
    81|    79|    var flat_pos = target_pos
    82|    80|    flat_pos.y = global_position.y
    83|    81|    look_at(flat_pos)
    84|    82|
    85|    83|func take_damage(amount: int, is_headshot: bool = false) -> void:
    86|    84|    if is_dead or is_spawning:
    87|    85|        return
    88|    86|    
    89|    87|    current_hp -= amount
    90|    88|    enemy_hit.emit()
    91|    89|    
    92|    90|    # Flash red on hit
    93|    91|    if mesh:
    94|    92|        _flash_hit()
    95|    93|    
    96|    94|    if current_hp <= 0:
    97|    95|        die(is_headshot)
    98|    96|
    99|    97|func die(is_headshot: bool = false) -> void:
   100|    98|    if is_dead:
   101|    99|        return
   102|   100|    is_dead = true
   103|   101|    
   104|   102|    # Calculate score
   105|   103|    var base_points = points_value
   106|   104|    GameManager.add_score(base_points, is_headshot, spawn_time)
   107|   105|    
   108|   106|    # Death effect
   109|   107|    if death_particles:
   110|   108|        death_particles.emitting = true
   111|   109|        death_particles.global_position = global_position
   112|   110|        # Reparent particles so they persist after enemy is freed
   113|   111|        var particles_parent = get_tree().current_scene
   114|   112|        remove_child(death_particles)
   115|   113|        particles_parent.add_child(death_particles)
   116|   114|        await get_tree().create_timer(1.0).timeout
   117|   115|        death_particles.queue_free()
   118|   116|    
   119|   117|    # Sound
   120|   118|    AudioManager.play_sfx_at_position("res://assets/audio/sfx/enemies/enemy_death.ogg", global_position)
   121|   119|    
   122|   120|    enemy_died.emit(base_points, global_position)
   123|   121|    queue_free()
   124|   122|
   125|   123|func _flash_hit() -> void:
   126|   124|    # Brief white flash on the mesh material
   127|   125|    if mesh and mesh.has_method("set_instance_shader_parameter"):
   128|   126|        mesh.set_instance_shader_parameter("flash_intensity", 1.0)
   129|   127|        await get_tree().create_timer(0.1).timeout
   130|   128|        mesh.set_instance_shader_parameter("flash_intensity", 0.0)
   131|   129|