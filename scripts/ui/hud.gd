extends Control

## Island Arcade - HUD
## Displays health, ammo, score, wave, and combo during gameplay

@onready var hp_bar: ProgressBar = $HPBar
@onready var hp_label: Label = $HPBar/HPLabel
@onready var ammo_label: Label = $AmmoDisplay/AmmoLabel
@onready var reserve_label: Label = $AmmoDisplay/ReserveLabel
@onready var score_label: Label = $ScoreDisplay/ScoreLabel
@onready var wave_label: Label = $WaveDisplay/WaveLabel
@onready var combo_label: Label = $ComboDisplay/ComboLabel
@onready var wave_announce: Label = $WaveAnnounce
@onready var crosshair: Control = $Crosshair

var player: CharacterBody3D
var weapon: Node3D

func _ready() -> void:
    # Connect to game manager signals
    GameManager.wave_started.connect(_on_wave_started)
    GameManager.enemy_killed.connect(_on_enemy_killed)
    GameManager.combo_updated.connect(_on_combo_updated)
    GameManager.game_over.connect(_on_game_over)
    
    wave_announce.visible = false
    combo_label.visible = false
    crosshair.visible = true

func _process(_delta: float) -> void:
    if not player or not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player")
        if player:
            _connect_player_signals()
        return
    
    # Update HP
    if player.has_node("PlayerHealth"):
        var health = player.get_node("PlayerHealth")
        var hp_ratio = float(health.current_hp) / float(health.MAX_HP)
        hp_bar.value = hp_ratio * 100.0
        hp_label.text = "%d / %d" % [health.current_hp, health.MAX_HP]
        
        # Color: green -> yellow -> red
        if hp_ratio > 0.5:
            hp_bar.modulate = Color.GREEN
        elif hp_ratio > 0.25:
            hp_bar.modulate = Color.YELLOW
        else:
            hp_bar.modulate = Color.RED
    
    # Update ammo
    if weapon and is_instance_valid(weapon):
        ammo_label.text = "%d" % weapon.current_mag
        reserve_label.text = "%d" % weapon.reserve_ammo
    
    # Update score
    score_label.text = "%s" % _format_number(GameManager.current_score)
    
    # Update wave
    wave_label.text = "WAVE %d" % GameManager.current_wave

func _connect_player_signals() -> void:
    if player.has_node("CameraPivot/WeaponHolder/Weapon"):
        weapon = player.get_node("CameraPivot/WeaponHolder/Weapon")
        weapon.ammo_changed.connect(_on_ammo_changed)
    
    # ADS crosshair toggle
    if player.has_signal("is_ads_changed"):
        pass  # Will handle in process based on ADS state

func _on_ammo_changed(current_mag: int, reserve: int) -> void:
    ammo_label.text = "%d" % current_mag
    reserve_label.text = "%d" % reserve

func _on_wave_started(wave_number: int) -> void:
    wave_announce.text = "WAVE %d" % wave_number
    wave_announce.visible = true
    wave_announce.modulate.a = 1.0
    
    # Animate wave announcement
    var tween = create_tween()
    tween.tween_property(wave_announce, "modulate:a", 1.0, 0.3)
    tween.tween_interval(2.0)
    tween.tween_property(wave_announce, "modulate:a", 0.0, 1.0)
    tween.tween_callback(wave_announce.set_visible.bind(false))

func _on_enemy_killed(points: int) -> void:
    # Brief score pop
    score_label.modulate = Color.YELLOW
    var tween = create_tween()
    tween.tween_property(score_label, "modulate", Color.WHITE, 0.3)

func _on_combo_updated(multiplier: float) -> void:
    if multiplier > 1.0:
        combo_label.visible = true
        var combo_count = GameManager.combo_count
        var text = "COMBO x%d" % combo_count
        if multiplier >= 3.0:
            text += " (3x!)"
        elif multiplier >= 2.0:
            text += " (2x!)"
        else:
            text += " (1.5x!)"
        combo_label.text = text
        
        # Pulse animation
        combo_label.scale = Vector2(1.5, 1.5)
        var tween = create_tween()
        tween.tween_property(combo_label, "scale", Vector2.ONE, 0.2)
    else:
        combo_label.visible = false

func _on_game_over(final_score: int) -> void:
    visible = false

func _format_number(n: int) -> String:
    var s = str(n)
    var result = ""
    var count = 0
    for i in range(s.length() - 1, -1, -1):
        if count > 0 and count % 3 == 0:
            result = "," + result
        result = s[i] + result
        count += 1
    return result
