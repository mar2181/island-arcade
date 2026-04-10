extends Node

## Island Arcade - Save Manager (Autoload)
## Handles persistent storage for high scores and settings

const SAVE_PATH: String = "user://save_data.json"
const HIGH_SCORES_KEY: String = "high_scores"
const SETTINGS_KEY: String = "settings"

var high_scores: Array[Dictionary] = []
var settings: Dictionary = {
    "mouse_sensitivity": 1.0,
    "fov": 90.0,
    "master_volume": 1.0,
    "music_volume": 0.7,
    "sfx_volume": 1.0,
    "fullscreen": false,
    "vsync": true,
}

func _ready() -> void:
    _load_data()

func _load_data() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
        if file:
            var json = JSON.new()
            var error = json.parse(file.get_as_text())
            file.close()
            if error == OK:
                var data = json.data
                if data.has(HIGH_SCORES_KEY):
                    high_scores = data[HIGH_SCORES_KEY]
                if data.has(SETTINGS_KEY):
                    # Merge saved settings with defaults (for new settings added later)
                    for key in data[SETTINGS_KEY]:
                        settings[key] = data[SETTINGS_KEY][key]

func _save_data() -> void:
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        var data = {
            HIGH_SCORES_KEY: high_scores,
            SETTINGS_KEY: settings,
        }
        file.store_string(JSON.stringify(data, "  "))
        file.close()

func add_high_score(score: int, wave: int, kills: int) -> void:
    var entry = {
        "score": score,
        "wave": wave,
        "kills": kills,
        "date": Time.get_datetime_string_from_system().split(" ")[0],
    }
    high_scores.append(entry)
    # Sort by score descending
    high_scores.sort_custom(func(a, b): return a["score"] > b["score"])
    # Keep only top 10
    if high_scores.size() > 10:
        high_scores = high_scores.slice(0, 10)
    _save_data()

func is_high_score(score: int) -> bool:
    if high_scores.size() < 10:
        return score > 0
    return score > high_scores[-1]["score"]

func apply_settings() -> void:
    # Mouse sensitivity is read directly by player controller
    # FOV is read directly by camera
    # Audio volumes
    if AudioManager:
        AudioManager.set_master_volume(settings["master_volume"])
        AudioManager.set_music_volume(settings["music_volume"])
        AudioManager.set_sfx_volume(settings["sfx_volume"])
    # Display
    if settings["fullscreen"]:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
    if settings["vsync"]:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
    else:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
    _save_data()

func get_setting(key: String, default = null) -> Variant:
    if settings.has(key):
        return settings[key]
    return default

func set_setting(key: String, value) -> void:
    settings[key] = value
    _save_data()
