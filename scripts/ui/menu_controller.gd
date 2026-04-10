extends Control

# Island Arcade - Menu Controller
# Handles main menu, settings, pause, and game over screens

@onready var main_menu: Control = $MainMenu
@onready var settings_menu: Control = $SettingsMenu
@onready var game_over_menu: Control = $GameOverMenu
@onready var pause_menu: Control = $PauseMenu

@onready var play_button: Button = $MainMenu/VBoxContainer/PlayButton
@onready var high_scores_button: Button = $MainMenu/VBoxContainer/HighScoresButton
@onready var settings_button: Button = $MainMenu/VBoxContainer/SettingsButton
@onready var quit_button: Button = $MainMenu/VBoxContainer/QuitButton

@onready var master_slider: HSlider = $SettingsMenu/VBoxContainer/MasterSlider
@onready var music_slider: HSlider = $SettingsMenu/VBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $SettingsMenu/VBoxContainer/SFXSlider
@onready var sensitivity_slider: HSlider = $SettingsMenu/VBoxContainer/SensitivitySlider
@onready var fov_slider: HSlider = $SettingsMenu/VBoxContainer/FOVSlider
@onready var fullscreen_check: CheckBox = $SettingsMenu/VBoxContainer/FullscreenCheck
@onready var vsync_check: CheckBox = $SettingsMenu/VBoxContainer/VSyncCheck
@onready var settings_back: Button = $SettingsMenu/VBoxContainer/BackButton

@onready var score_label: Label = $GameOverMenu/VBoxContainer/ScoreLabel
@onready var wave_label: Label = $GameOverMenu/VBoxContainer/WaveLabel
@onready var kills_label: Label = $GameOverMenu/VBoxContainer/KillsLabel
@onready var accuracy_label: Label = $GameOverMenu/VBoxContainer/AccuracyLabel
@onready var new_high_score: Label = $GameOverMenu/VBoxContainer/NewHighScoreLabel
@onready var play_again_button: Button = $GameOverMenu/VBoxContainer/PlayAgainButton
@onready var menu_button: Button = $GameOverMenu/VBoxContainer/MenuButton

@onready var pause_resume: Button = $PauseMenu/VBoxContainer/ResumeButton
@onready var pause_settings: Button = $PauseMenu/VBoxContainer/SettingsButton
@onready var pause_quit: Button = $PauseMenu/VBoxContainer/QuitButton

enum MenuState { MAIN, SETTINGS, GAME_OVER, PAUSED, HIDDEN }

var current_state: MenuState = MenuState.MAIN

func _ready() -> void:
	play_button.pressed.connect(_on_play)
	settings_button.pressed.connect(_on_settings)
	quit_button.pressed.connect(_on_quit)
	settings_back.pressed.connect(_on_settings_back)
	play_again_button.pressed.connect(_on_play)
	menu_button.pressed.connect(_on_quit_to_menu)
	pause_resume.pressed.connect(_on_resume)
	pause_settings.pressed.connect(_on_settings)
	pause_quit.pressed.connect(_on_quit_to_menu)
	
	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
	fov_slider.value_changed.connect(_on_fov_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	vsync_check.toggled.connect(_on_vsync_toggled)
	
	GameManager.game_over.connect(_on_game_over)
	GameManager.player_died.connect(func(): _on_game_over(GameManager.current_score))
	
	_load_settings()
	show_main_menu()

func _process(_delta: float) -> void:
	pass  # Pause handling moved to GameUI to avoid conflicts

func show_main_menu() -> void:
	current_state = MenuState.MAIN
	main_menu.visible = true
	settings_menu.visible = false
	game_over_menu.visible = false
	pause_menu.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func show_settings() -> void:
	current_state = MenuState.SETTINGS
	main_menu.visible = false
	settings_menu.visible = true
	game_over_menu.visible = false
	pause_menu.visible = false
	_load_settings()

func show_game_over(score: int, wave: int, kills: int, accuracy: float) -> void:
	current_state = MenuState.GAME_OVER
	main_menu.visible = false
	settings_menu.visible = false
	game_over_menu.visible = true
	pause_menu.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	score_label.text = "SCORE: %d" % score
	wave_label.text = "WAVE: %d" % wave
	kills_label.text = "KILLS: %d" % kills
	accuracy_label.text = "ACCURACY: %.1f%%" % accuracy
	
	if SaveManager.is_high_score(score):
		new_high_score.visible = true
		new_high_score.text = "NEW HIGH SCORE!"
	else:
		new_high_score.visible = false

func show_pause_menu() -> void:
	current_state = MenuState.PAUSED
	main_menu.visible = false
	settings_menu.visible = false
	game_over_menu.visible = false
	pause_menu.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hide_all() -> void:
	current_state = MenuState.HIDDEN
	main_menu.visible = false
	settings_menu.visible = false
	game_over_menu.visible = false
	pause_menu.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_play() -> void:
	hide_all()
	GameManager.start_game()
	get_tree().change_scene_to_file("res://scenes/game/game_scene.tscn")

func _on_settings() -> void:
	show_settings()

func _on_settings_back() -> void:
	if GameManager.current_state == GameManager.GameState.PAUSED:
		show_pause_menu()
	else:
		show_main_menu()

func _on_quit() -> void:
	get_tree().quit()

func _on_quit_to_menu() -> void:
	GameManager.quit_to_menu()

func _on_resume() -> void:
	GameManager.resume_game()
	hide_all()

func _on_game_over(final_score: int) -> void:
	SaveManager.add_high_score(final_score, GameManager.current_wave, GameManager.enemies_killed)
	show_game_over(final_score, GameManager.current_wave, GameManager.enemies_killed, GameManager.get_accuracy())

func _on_master_volume_changed(value: float) -> void:
	SaveManager.set_setting("master_volume", value)
	AudioManager.set_master_volume(value)

func _on_music_volume_changed(value: float) -> void:
	SaveManager.set_setting("music_volume", value)
	AudioManager.set_music_volume(value)

func _on_sfx_volume_changed(value: float) -> void:
	SaveManager.set_setting("sfx_volume", value)
	AudioManager.set_sfx_volume(value)

func _on_sensitivity_changed(value: float) -> void:
	SaveManager.set_setting("mouse_sensitivity", value)

func _on_fov_changed(value: float) -> void:
	SaveManager.set_setting("fov", value)

func _on_fullscreen_toggled(is_on: bool) -> void:
	SaveManager.set_setting("fullscreen", is_on)
	SaveManager.apply_settings()

func _on_vsync_toggled(is_on: bool) -> void:
	SaveManager.set_setting("vsync", is_on)
	SaveManager.apply_settings()

func _load_settings() -> void:
	master_slider.value = SaveManager.get_setting("master_volume", 1.0)
	music_slider.value = SaveManager.get_setting("music_volume", 0.7)
	sfx_slider.value = SaveManager.get_setting("sfx_volume", 1.0)
	sensitivity_slider.value = SaveManager.get_setting("mouse_sensitivity", 1.0)
	fov_slider.value = SaveManager.get_setting("fov", 90.0)
	fullscreen_check.button_pressed = SaveManager.get_setting("fullscreen", false)
	vsync_check.button_pressed = SaveManager.get_setting("vsync", true)
