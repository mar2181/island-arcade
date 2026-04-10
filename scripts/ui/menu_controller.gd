     1|extends Control
     2|
     3|## Island Arcade - Menu Controller
     4|## Handles main menu, settings, pause, and game over screens
     5|
     6|@onready var main_menu: Control = $MainMenu
     7|@onready var settings_menu: Control = $SettingsMenu
     8|@onready var game_over_menu: Control = $GameOverMenu
     9|@onready var pause_menu: Control = $PauseMenu
    10|
    11|@onready var play_button: Button = $MainMenu/VBoxContainer/PlayButton
    12|@onready var high_scores_button: Button = $MainMenu/VBoxContainer/HighScoresButton
    13|@onready var settings_button: Button = $MainMenu/VBoxContainer/SettingsButton
    14|@onready var quit_button: Button = $MainMenu/VBoxContainer/QuitButton
    15|
    16|@onready var master_slider: HSlider = $SettingsMenu/VBoxContainer/MasterSlider
    17|@onready var music_slider: HSlider = $SettingsMenu/VBoxContainer/MusicSlider
    18|@onready var sfx_slider: HSlider = $SettingsMenu/VBoxContainer/SFXSlider
    19|@onready var sensitivity_slider: HSlider = $SettingsMenu/VBoxContainer/SensitivitySlider
    20|@onready var fov_slider: HSlider = $SettingsMenu/VBoxContainer/FOVSlider
    21|@onready var fullscreen_check: CheckBox = $SettingsMenu/VBoxContainer/FullscreenCheck
    22|@onready var vsync_check: CheckBox = $SettingsMenu/VBoxContainer/VSyncCheck
    23|@onready var settings_back: Button = $SettingsMenu/VBoxContainer/BackButton
    24|
    25|@onready var score_label: Label = $GameOverMenu/VBoxContainer/ScoreLabel
    26|@onready var wave_label: Label = $GameOverMenu/VBoxContainer/WaveLabel
    27|@onready var kills_label: Label = $GameOverMenu/VBoxContainer/KillsLabel
    28|@onready var accuracy_label: Label = $GameOverMenu/VBoxContainer/AccuracyLabel
    29|@onready var new_high_score: Label = $GameOverMenu/VBoxContainer/NewHighScoreLabel
    30|@onready var play_again_button: Button = $GameOverMenu/VBoxContainer/PlayAgainButton
    31|@onready var menu_button: Button = $GameOverMenu/VBoxContainer/MenuButton
    32|
    33|@onready var pause_resume: Button = $PauseMenu/VBoxContainer/ResumeButton
    34|@onready var pause_settings: Button = $PauseMenu/VBoxContainer/SettingsButton
    35|@onready var pause_quit: Button = $PauseMenu/VBoxContainer/QuitButton
    36|
    37|enum MenuState {
    38|    MAIN,
    39|    SETTINGS,
    40|    GAME_OVER,
    41|    PAUSED,
    42|    HIDDEN,
    43|}
    44|
    45|var current_state: MenuState = MenuState.MAIN
    46|
    47|func _ready() -> void:
    48|    # Connect buttons
    49|    play_button.pressed.connect(_on_play)
    50|    settings_button.pressed.connect(_on_settings)
    51|    quit_button.pressed.connect(_on_quit)
    52|    settings_back.pressed.connect(_on_settings_back)
    53|    play_again_button.pressed.connect(_on_play)
    54|    menu_button.pressed.connect(_on_quit_to_menu)
    55|    pause_resume.pressed.connect(_on_resume)
    56|    pause_settings.pressed.connect(_on_settings)
    57|    pause_quit.pressed.connect(_on_quit_to_menu)
    58|    
    59|    # Connect sliders
    60|    master_slider.value_changed.connect(_on_master_volume_changed)
    61|    music_slider.value_changed.connect(_on_music_volume_changed)
    62|    sfx_slider.value_changed.connect(_on_sfx_volume_changed)
    63|    sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
    64|    fov_slider.value_changed.connect(_on_fov_changed)
    65|    fullscreen_check.toggled.connect(_on_fullscreen_toggled)
    66|    vsync_check.toggled.connect(_on_vsync_toggled)
    67|    
    68|    # Connect game signals
    69|    GameManager.game_over.connect(_on_game_over)
    70|    GameManager.player_died.connect(func(): _on_game_over(GameManager.current_score))
    71|    
    72|    # Load settings into UI
    73|    _load_settings()
    74|    
    75|    show_main_menu()
    76|
    77|func _process(_delta: float) -> void:
    78|    if Input.is_action_just_pressed("pause") and GameManager.current_state == GameManager.GameState.PLAYING:
    79|        GameManager.pause_game()
    80|        show_pause_menu()
    81|    elif Input.is_action_just_pressed("pause") and GameManager.current_state == GameManager.GameState.PAUSED:
    82|        _on_resume()
    83|
    84|func show_main_menu() -> void:
    85|    current_state = MenuState.MAIN
    86|    main_menu.visible = true
    87|    settings_menu.visible = false
    88|    game_over_menu.visible = false
    89|    pause_menu.visible = false
    90|    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    91|
    92|func show_settings() -> void:
    93|    current_state = MenuState.SETTINGS
    94|    main_menu.visible = false
    95|    settings_menu.visible = true
    96|    game_over_menu.visible = false
    97|    pause_menu.visible = false
    98|    _load_settings()
    99|
   100|func show_game_over(score: int, wave: int, kills: int, accuracy: float) -> void:
   101|    current_state = MenuState.GAME_OVER
   102|    main_menu.visible = false
   103|    settings_menu.visible = false
   104|    game_over_menu.visible = true
   105|    pause_menu.visible = false
   106|    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
   107|    
   108|    score_label.text = "SCORE: %d" % score
   109|    wave_label.text = "WAVE: %d" % wave
   110|    kills_label.text = "KILLS: %d" % kills
   111|    accuracy_label.text = "ACCURACY: %.1f%%" % accuracy
   112|    
   113|    # Check for high score
   114|    if SaveManager.is_high_score(score):
   115|        new_high_score.visible = true
   116|        new_high_score.text = "NEW HIGH SCORE!"
   117|    else:
   118|        new_high_score.visible = false
   119|
   120|func show_pause_menu() -> void:
   121|    current_state = MenuState.PAUSED
   122|    main_menu.visible = false
   123|    settings_menu.visible = false
   124|    game_over_menu.visible = false
   125|    pause_menu.visible = true
   126|    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
   127|
   128|func hide_all() -> void:
   129|    current_state = MenuState.HIDDEN
   130|    main_menu.visible = false
   131|    settings_menu.visible = false
   132|    game_over_menu.visible = false
   133|    pause_menu.visible = false
   134|    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
   135|
   136|func _on_play() -> void:
   137|    hide_all()
   138|    GameManager.start_game()
   139|    get_tree().change_scene_to_file("res://scenes/game/game_scene.tscn")
   140|
   141|func _on_settings() -> void:
   142|    show_settings()
   143|
   144|func _on_settings_back() -> void:
   145|    if GameManager.current_state == GameManager.GameState.PAUSED:
   146|        show_pause_menu()
   147|    else:
   148|        show_main_menu()
   149|
   150|func _on_quit() -> void:
   151|    get_tree().quit()
   152|
   153|func _on_quit_to_menu() -> void:
   154|    GameManager.quit_to_menu()
   155|
   156|func _on_resume() -> void:
   157|    GameManager.resume_game()
   158|    hide_all()
   159|
   160|func _on_game_over(final_score: int) -> void:
   161|    SaveManager.add_high_score(final_score, GameManager.current_wave, GameManager.enemies_killed)
   162|    show_game_over(final_score, GameManager.current_wave, GameManager.enemies_killed, GameManager.get_accuracy())
   163|
   164|func _on_master_volume_changed(value: float) -> void:
   165|    SaveManager.set_setting("master_volume", value)
   166|    AudioManager.set_master_volume(value)
   167|
   168|func _on_music_volume_changed(value: float) -> void:
   169|    SaveManager.set_setting("music_volume", value)
   170|    AudioManager.set_music_volume(value)
   171|
   172|func _on_sfx_volume_changed(value: float) -> void:
   173|    SaveManager.set_setting("sfx_volume", value)
   174|    AudioManager.set_sfx_volume(value)
   175|
   176|func _on_sensitivity_changed(value: float) -> void:
   177|    SaveManager.set_setting("mouse_sensitivity", value)
   178|
   179|func _on_fov_changed(value: float) -> void:
   180|    SaveManager.set_setting("fov", value)
   181|
   182|func _on_fullscreen_toggled(is_on: bool) -> void:
   183|    SaveManager.set_setting("fullscreen", is_on)
   184|    SaveManager.apply_settings()
   185|
   186|func _on_vsync_toggled(is_on: bool) -> void:
   187|    SaveManager.set_setting("vsync", is_on)
   188|    SaveManager.apply_settings()
   189|
   190|func _load_settings() -> void:
   191|    master_slider.value = SaveManager.get_setting("master_volume", 1.0)
   192|    music_slider.value = SaveManager.get_setting("music_volume", 0.7)
   193|    sfx_slider.value = SaveManager.get_setting("sfx_volume", 1.0)
   194|    sensitivity_slider.value = SaveManager.get_setting("mouse_sensitivity", 1.0)
   195|    fov_slider.value = SaveManager.get_setting("fov", 90.0)
   196|    fullscreen_check.button_pressed = SaveManager.get_setting("fullscreen", false)
   197|    vsync_check.button_pressed = SaveManager.get_setting("vsync", true)
   198|