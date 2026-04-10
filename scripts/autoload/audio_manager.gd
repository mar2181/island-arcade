extends Node

## Island Arcade - Audio Manager (Autoload)
## Manages music and SFX playback with spatial audio support

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var ambient_player: AudioStreamPlayer

var master_volume: float = 1.0
var music_volume: float = 0.7
var sfx_volume: float = 1.0

const MAX_SFX_PLAYERS: int = 16

# Music tracks (loaded at runtime)
var music_tracks: Dictionary = {}
var current_music: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	# Ambient player
	ambient_player = AudioStreamPlayer.new()
	ambient_player.bus = "Ambient"
	add_child(ambient_player)
	# SFX pool
	for i in range(MAX_SFX_PLAYERS):
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		sfx_players.append(player)

func play_music(track_name: String) -> void:
	if track_name == current_music and music_player.playing:
		return
	var stream = load("res://assets/audio/music/" + track_name)
	if stream:
		music_player.stream = stream
		music_player.volume_db = linear_to_db(music_volume * master_volume)
		music_player.play()
		current_music = track_name

func stop_music() -> void:
	music_player.stop()
	current_music = ""

func play_sfx(path: String, pitch: float = 1.0, volume_db: float = 0.0) -> void:
	for player in sfx_players:
		if not player.playing:
			var stream = load(path)
			if stream:
				player.stream = stream
				player.pitch_scale = pitch
				player.volume_db = volume_db + linear_to_db(sfx_volume * master_volume)
				player.play()
			return

func play_sfx_at_position(path: String, position: Vector3, pitch: float = 1.0) -> void:
	# For 3D positioned audio, we need a temporary AudioStreamPlayer3D
	var player_3d = AudioStreamPlayer3D.new()
	player_3d.position = position
	player_3d.bus = "SFX"
	var stream = load(path)
	if stream:
		player_3d.stream = stream
		player_3d.pitch_scale = pitch
		player_3d.volume_db = linear_to_db(sfx_volume * master_volume)
		# Attach to the game scene's root
		var game_scene = get_tree().current_scene
		if game_scene:
			game_scene.add_child(player_3d)
			player_3d.play()
			# Auto-cleanup after sound finishes
			await player_3d.finished
			player_3d.queue_free()

func play_ambient(stream_path: String) -> void:
	var stream = load(stream_path)
	if stream:
		ambient_player.stream = stream
		ambient_player.volume_db = linear_to_db(0.3 * music_volume * master_volume)
		ambient_player.play()

func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	_update_volumes()

func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	_update_volumes()

func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	_update_volumes()

func _update_volumes() -> void:
	music_player.volume_db = linear_to_db(music_volume * master_volume)
	ambient_player.volume_db = linear_to_db(0.3 * music_volume * master_volume)
