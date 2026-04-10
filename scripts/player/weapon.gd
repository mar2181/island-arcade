     1|     1|     1|     1|extends Node3D
     2|     2|     2|     2|
     3|     3|     3|     3|## Island Arcade - Pixel Blaster Weapon System
     4|     4|     4|     4|## Semi-auto hitscan pistol with arcade feel
     5|     5|     5|     5|
     6|     6|     6|     6|signal ammo_changed(current_mag: int, reserve: int)
     7|     7|     7|     7|signal weapon_fired
     8|     8|     8|     8|signal weapon_reloaded
     9|     9|     9|     9|signal weapon_pickup_complete
    10|    10|    10|    10|
    11|    11|    11|    11|@onready var player: CharacterBody3D = get_parent().get_parent()
    12|    12|    12|    12|@onready var raycast: RayCast3D = get_parent().get_node("RayCast3D")
    13|    13|    13|    13|
    14|    14|    14|    14|# Weapon stats
    15|    15|    15|    15|const MAG_SIZE: int = 12
    16|    16|    16|    16|const RESERVE_MAX: int = 60
    17|    17|    17|    17|const FIRE_RATE: float = 0.15  # seconds between shots
    18|    18|    18|    18|const RELOAD_TIME: float = 1.5
    19|    19|    19|    19|const BODY_DAMAGE: int = 30
    20|    20|    20|    20|const HEAD_DAMAGE: int = 60
    21|    21|    21|    21|const MAX_RANGE: float = 50.0
    22|    22|    22|    22|
    23|    23|    23|    23|# State
    24|    24|    24|    24|var current_mag: int = 0
    25|    25|    25|    25|var reserve_ammo: int = 0
    26|    26|    26|    26|var can_fire: bool = true
    27|    27|    27|    27|var is_reloading: bool = false
    28|    28|    28|    28|var is_weapon_picked_up: bool = true
    29|    29|    29|    29|var fire_cooldown: float = 0.0
    30|    30|    30|    30|
    31|    31|    31|    31|# Visual references (assigned in scene)
    32|    32|    32|    32|@onready var muzzle_flash: Node3D = $MuzzleFlash
    33|    33|    33|    33|@onready var weapon_model: Node3D = $WeaponModel
    34|    34|    34|    34|@onready var tracer: Node3D = $Tracer
    35|    35|    35|    35|
    36|    36|    36|    36|func _ready() -> void:
    37|    37|    37|    37|    current_mag = MAG_SIZE
    38|    38|    38|    38|    reserve_ammo = RESERVE_MAX
    39|    39|    39|    39|    ammo_changed.emit(current_mag, reserve_ammo)
    40|    40|    40|    40|    muzzle_flash.visible = false
    41|    41|    41|    41|    tracer.visible = false
    42|    42|    42|    42|
    43|    43|    43|    43|func _process(delta: float) -> void:
    44|    44|    44|    44|    if not is_weapon_picked_up:
    45|    45|    45|    45|        return
    46|    46|    46|    46|    
    47|    47|    47|    47|    if fire_cooldown > 0:
    48|    48|    48|    48|        fire_cooldown -= delta
    49|    49|    49|    49|    
    50|    50|    50|    50|    # Shoot
    51|    51|    51|    51|    if Input.is_action_pressed("shoot") and can_fire and not is_reloading and fire_cooldown <= 0:
    52|    52|    52|    52|        fire()
    53|    53|    53|    53|    
    54|    54|    54|    54|    # Reload
    55|    55|    55|    55|    if Input.is_action_just_pressed("reload") and not is_reloading and current_mag < MAG_SIZE and reserve_ammo > 0:
    56|    56|    56|    56|        reload()
    57|    57|    57|    57|
    58|    58|    58|    58|func fire() -> void:
    59|    59|    59|    59|    if current_mag <= 0:
    60|    60|    60|    60|        # Dry fire sound
    61|    61|    61|    61|        AudioManager.play_sfx("res://assets/audio/sfx/weapons/dry_fire.ogg", 1.0, -5.0)
    62|    62|    62|    62|        return
    63|    63|    63|    63|    
    64|    64|    64|    64|    current_mag -= 1
    65|    65|    65|    65|    fire_cooldown = FIRE_RATE
    66|    66|    66|    66|    weapon_fired.emit()
    67|    67|    67|    67|    
    68|    68|    68|    68|    # Raycast hit detection
    69|    69|    69|    69|    raycast.force_raycast_update()
    70|    70|    70|    70|    GameManager.register_shot(raycast.is_colliding())
    71|    71|    71|    71|    
    72|    72|    72|    72|    if raycast.is_colliding():
    73|    73|    73|    73|        var hit_point = raycast.get_collision_point()
    74|    74|    74|    74|        var hit_normal = raycast.get_collision_normal()
    75|    75|    75|    75|        var collider = raycast.get_collider()
    76|    76|    76|    76|        
    77|    77|    77|    77|        # Check if enemy
    78|    78|    78|    78|        if collider.has_node("EnemyHealth"):
    79|    79|    79|    79|            var health = collider.get_node("EnemyHealth")
    80|    80|    80|    80|            var is_headshot = _check_headshot(collider, hit_point)
    81|    81|    81|    81|            var damage = HEAD_DAMAGE if is_headshot else BODY_DAMAGE
    82|    82|    82|    82|            health.take_damage(damage, is_headshot)
    83|    83|    83|    83|        elif collider.has_method("take_damage"):
    84|    84|    84|    84|            collider.take_damage(BODY_DAMAGE)
    85|    85|    85|    85|        
    86|    86|    86|    86|        # Spawn impact effect
    87|    87|    87|    87|        _spawn_impact(hit_point, hit_normal)
    88|    88|    88|    88|    else:
    89|    89|    89|    89|        # Missed - just muzzle flash
    90|    90|    90|    90|        pass
    91|    91|    91|    91|    
    92|    92|    92|    92|    # Visual feedback
    93|    93|    93|    93|    _show_muzzle_flash()
    94|    94|    94|    94|    _show_tracer()
    95|    95|    95|    95|    AudioManager.play_sfx("res://assets/audio/sfx/weapons/pixel_blaster_fire.ogg", randf_range(0.9, 1.1), 0.0)
    96|    96|    96|    96|    
    97|    97|    97|    97|    # Weapon recoil animation
    98|    98|    98|    98|    _animate_recoil()
    99|    99|    99|    99|    
   100|   100|   100|   100|    ammo_changed.emit(current_mag, reserve_ammo)
   101|   101|   101|   101|    
   102|   102|   102|   102|    # Auto-reload if empty
   103|   103|   103|   103|    if current_mag <= 0 and reserve_ammo > 0:
   104|   104|   104|   104|        reload()
   105|   105|   105|   105|
   106|   106|   106|   106|func reload() -> void:
   107|   107|   107|   107|    if is_reloading or current_mag == MAG_SIZE:
   108|   108|   108|   108|        return
   109|   109|   109|   109|    
   110|   110|   110|   110|    is_reloading = true
   111|   111|   111|   111|    can_fire = false
   112|   112|   112|   112|    AudioManager.play_sfx("res://assets/audio/sfx/weapons/reload_start.ogg")
   113|   113|   113|   113|    
   114|   114|   114|   114|    # Reload animation
   115|   115|   115|   115|    var tween = create_tween()
   116|   116|   116|   116|    tween.tween_property(weapon_model, "position:y", weapon_model.position.y - 0.15, 0.3)
   117|   117|   117|   117|    tween.tween_interval(RELOAD_TIME - 0.6)
   118|   118|   118|   118|    tween.tween_property(weapon_model, "position:y", weapon_model.position.y, 0.3)
   119|   119|   119|   119|    
   120|   120|   120|   120|    await tween.finished
   121|   121|   121|   121|    
   122|   122|   122|   122|    var ammo_needed = MAG_SIZE - current_mag
   123|   123|   123|   123|    var ammo_to_load = mini(ammo_needed, reserve_ammo)
   124|   124|   124|   124|    current_mag += ammo_to_load
   125|   125|   125|   125|    reserve_ammo -= ammo_to_load
   126|   126|   126|   126|    
   127|   127|   127|   127|    is_reloading = false
   128|   128|   128|   128|    can_fire = true
   129|   129|   129|   129|    weapon_reloaded.emit()
   130|   130|   130|   130|    ammo_changed.emit(current_mag, reserve_ammo)
   131|   131|   131|   131|    AudioManager.play_sfx("res://assets/audio/sfx/weapons/reload_end.ogg")
   132|   132|   132|   132|
   133|   133|   133|   133|func add_ammo(amount: int) -> void:
   134|   134|   134|   134|    reserve_ammo = mini(reserve_ammo + amount, RESERVE_MAX)
   135|   135|   135|   135|    ammo_changed.emit(current_mag, reserve_ammo)
   136|   136|   136|   136|
   137|   137|   137|   137|func pickup_weapon() -> void:
   138|   138|   138|   138|    is_weapon_picked_up = true
   139|   139|   139|   139|    # Animate weapon coming into view
   140|   140|   140|   140|    weapon_model.visible = true
   141|   141|   141|   141|    var tween = create_tween()
   142|   142|   142|   142|    tween.tween_property(weapon_model, "position:z", weapon_model.position.z, 0.5).from(weapon_model.position.z - 0.5)
   143|   143|   143|   143|    weapon_pickup_complete.emit()
   144|   144|   144|   144|
   145|   145|   145|   145|func _check_headshot(collider: Node, hit_point: Vector3) -> bool:
   146|   146|   146|   146|    # Headshot zone: upper 30% of the collider's AABB
   147|   147|   147|   147|    var aabb = collider.get_aabb() if collider has_method("get_aabb") else null
   148|   148|   148|   148|    if aabb:
   149|   149|   149|   149|        var head_zone_y = aabb.position.y + aabb.size.y * 0.7
   150|   150|   150|   150|        return hit_point.y > head_zone_y
   151|   151|   151|   151|    # Fallback: check if hit is in upper portion relative to collider origin
   152|   152|   152|   152|    return hit_point.y > collider.global_position.y + 0.8
   153|   153|   153|   153|
   154|   154|   154|   154|func _show_muzzle_flash() -> void:
   155|   155|   155|   155|    muzzle_flash.visible = true
   156|   156|   156|   156|    muzzle_flash.rotation.z = randf() * TAU
   157|   157|   157|   157|    await get_tree().create_timer(0.05).timeout
   158|   158|   158|   158|    muzzle_flash.visible = false
   159|   159|   159|   159|
   160|   160|   160|   160|func _show_tracer() -> void:
   161|   161|   161|   161|    tracer.visible = true
   162|   162|   162|   162|    await get_tree().create_timer(0.03).timeout
   163|   163|   163|   163|    tracer.visible = false
   164|   164|   164|   164|
   165|   165|   165|   165|func _spawn_impact(point: Vector3, normal: Vector3) -> void:
   166|   166|   166|   166|    # Spawn a simple impact particle at the hit location
   167|   167|   167|   167|    var impact = preload("res://scenes/game/impact_effect.tscn").instantiate()
   168|   168|   168|   168|    get_tree().current_scene.add_child(impact)
   169|   169|   169|   169|    impact.global_position = point
   170|   170|   170|   170|    impact.look_at(point + normal, Vector3.UP)
   171|   171|   171|   171|    # Auto-destroy after 0.5 seconds
   172|   172|   172|   172|    await get_tree().create_timer(0.5).timeout
   173|   173|   173|   173|    if impact and is_instance_valid(impact):
   174|   174|   174|   174|        impact.queue_free()
   175|   175|   175|   175|
   176|   176|   176|   176|func _animate_recoil() -> void:
   177|   177|   177|   177|    var tween = create_tween()
   178|   178|   178|   178|    var orig_rot = weapon_model.rotation_degrees
   179|   179|   179|   179|    tween.tween_property(weapon_model, "rotation_degrees:x", orig_rot.x - 2.0, 0.05)
   180|   180|   180|   180|    tween.tween_property(weapon_model, "rotation_degrees:x", orig_rot.x, 0.1)
   181|   181|   181|   181|