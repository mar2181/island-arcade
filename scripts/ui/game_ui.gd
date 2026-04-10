extends Control

## Island Arcade - In-Game UI
## Handles pause overlay and game over screen during gameplay

@onready var pause_overlay: Control = $PauseOverlay
@onready var game_over_overlay: Control = $GameOverOverlay
@onready var resume_button: Button = $PauseOverlay/VBox/ResumeButton
@onready var pause_quit_button: Button = $PauseOverlay/VBox/QuitButton
@onready var game_over_score: Label = $GameOverOverlay/VBox/ScoreLabel
@onready var game_over_wave: Label = $GameOverOverlay/VBox/WaveLabel
@onready var game_over_kills: Label = $GameOverOverlay/VBox/KillsLabel
@onready var game_over_accuracy: Label = $GameOverOverlay/VBox/AccuracyLabel
@onready var new_high_score_label: Label = $GameOverOverlay/VBox/NewHighScoreLabel
@onready var play_again_button: Button = $GameOverOverlay/VBox/PlayAgainButton
@onready var game_over_quit_button: Button = $GameOverOverlay/VBox/QuitButton

func _ready() -> void:
	pause_overlay.visible = false
	game_over_overlay.visible = false
	resume_button.pressed.connect(_on_resume)
	pause_quit_button.pressed.connect(_on_quit_to_menu)
	play_again_button.pressed.connect(_on_play_again)
	game_over_quit_button.pressed.connect(_on_quit_to_menu)
	GameManager.game_over.connect(_on_game_over)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if GameManager.current_state == GameManager.GameState.PLAYING:
			GameManager.pause_game()
			pause_overlay.visible = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif GameManager.current_state == GameManager.GameState.PAUSED:
			_on_resume()

func _on_resume() -> void:
	GameManager.resume_game()
	pause_overlay.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_game_over(final_score: int) -> void:
	await get_tree().create_timer(1.0).timeout
	game_over_overlay.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	game_over_score.text = "SCORE: %d" % final_score
	game_over_wave.text = "WAVE: %d" % GameManager.current_wave
	game_over_kills.text = "KILLS: %d" % GameManager.enemies_killed
	game_over_accuracy.text = "ACCURACY: %.1f%%" % GameManager.get_accuracy()
	if SaveManager.is_high_score(final_score):
		new_high_score_label.visible = true
	else:
		new_high_score_label.visible = false

func _on_play_again() -> void:
	GameManager.start_game()
	get_tree().reload_current_scene()

func _on_quit_to_menu() -> void:
	GameManager.quit_to_menu()
