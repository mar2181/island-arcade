extends Node

## Island Arcade - Game Manager (Autoload)
## Manages overall game state, score, waves, and flow

signal game_started
signal game_over(final_score: int)
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal enemy_killed(points: int)
signal combo_updated(multiplier: float)
signal player_died

enum GameState {
    MENU,
    PLAYING,
    PAUSED,
    GAME_OVER,
}

var current_state: GameState = GameState.MENU
var current_wave: int = 0
var current_score: int = 0
var enemies_killed: int = 0
var shots_fired: int = 0
var shots_hit: int = 0
var combo_count: int = 0
var combo_multiplier: float = 1.0
var combo_timer: float = 0.0
var damage_taken_this_wave: bool = false

const COMBO_TIMEOUT: float = 2.0
const MAX_WAVES: int = 10
const BASE_SCORE_GLITCH: int = 100
const BASE_SCORE_BYTE: int = 150
const BASE_SCORE_BOSS: int = 1000
const HEADSHOT_MULTIPLIER: float = 2.0
const QUICK_KILL_BONUS: int = 50
const QUICK_KILL_WINDOW: float = 3.0

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
    if current_state == GameState.PLAYING:
        _update_combo(delta)

func start_game() -> void:
    current_state = GameState.PLAYING
    current_wave = 0
    current_score = 0
    enemies_killed = 0
    shots_fired = 0
    shots_hit = 0
    combo_count = 0
    combo_multiplier = 1.0
    combo_timer = 0.0
    damage_taken_this_wave = false
    game_started.emit()
    _start_next_wave()

func _start_next_wave() -> void:
    current_wave += 1
    damage_taken_this_wave = false
    wave_started.emit(current_wave)
    if current_wave > MAX_WAVES:
        _win_game()

func on_wave_completed() -> void:
    var wave_bonus: int = current_wave * 500
    var perfect_bonus: int = 0
    if not damage_taken_this_wave:
        perfect_bonus = current_wave * 200
    current_score += wave_bonus + perfect_bonus
    wave_completed.emit(current_wave)
    if current_wave < MAX_WAVES:
        # Brief pause then next wave
        await get_tree().create_timer(3.0).timeout
        if current_state == GameState.PLAYING:
            _start_next_wave()
    else:
        _win_game()

func add_score(base_points: int, is_headshot: bool, spawn_time: float) -> void:
    var points: int = base_points
    if is_headshot:
        points = int(points * HEADSHOT_MULTIPLIER)
    # Quick kill bonus
    var time_alive: float = Time.get_ticks_msec() / 1000.0 - spawn_time
    if time_alive < QUICK_KILL_WINDOW:
        points += QUICK_KILL_BONUS
    # Combo multiplier
    points = int(points * combo_multiplier)
    current_score += points
    enemies_killed += 1
    # Update combo
    combo_count += 1
    combo_timer = COMBO_TIMEOUT
    _update_combo_multiplier()
    enemy_killed.emit(points)

func register_shot(hit: bool) -> void:
    shots_fired += 1
    if hit:
        shots_hit += 1

func on_player_damaged() -> void:
    damage_taken_this_wave = true

func on_player_died() -> void:
    current_state = GameState.GAME_OVER
    player_died.emit()
    game_over.emit(current_score)

func _update_combo(delta: float) -> void:
    if combo_timer > 0:
        combo_timer -= delta
        if combo_timer <= 0:
            combo_count = 0
            combo_multiplier = 1.0
            combo_updated.emit(combo_multiplier)

func _update_combo_multiplier() -> void:
    if combo_count >= 5:
        combo_multiplier = 3.0
    elif combo_count >= 3:
        combo_multiplier = 2.0
    elif combo_count >= 2:
        combo_multiplier = 1.5
    else:
        combo_multiplier = 1.0
    combo_updated.emit(combo_multiplier)

func _win_game() -> void:
    current_state = GameState.GAME_OVER
    game_over.emit(current_score)

func get_accuracy() -> float:
    if shots_fired == 0:
        return 0.0
    return float(shots_hit) / float(shots_fired) * 100.0

func pause_game() -> void:
    if current_state == GameState.PLAYING:
        current_state = GameState.PAUSED
        get_tree().paused = true

func resume_game() -> void:
    if current_state == GameState.PAUSED:
        current_state = GameState.PLAYING
        get_tree().paused = false

func quit_to_menu() -> void:
    current_state = GameState.MENU
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/main.tscn")
