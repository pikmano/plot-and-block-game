extends Node

const SOUNDS: Dictionary = {
	"place": "",       # res://assets/sounds/place.wav
	"clear": "",       # res://assets/sounds/clear.wav
	"game_over": "",   # res://assets/sounds/game_over.wav
	"button": "",      # res://assets/sounds/button.wav
}

var _sfx_player: AudioStreamPlayer
var _music_player: AudioStreamPlayer

var sfx_enabled: bool = true
var music_enabled: bool = true

func _ready() -> void:
	sfx_enabled = SaveManager.get_bool("sfx_enabled", true)
	music_enabled = SaveManager.get_bool("music_enabled", true)

	_sfx_player = AudioStreamPlayer.new()
	add_child(_sfx_player)
	_music_player = AudioStreamPlayer.new()
	add_child(_music_player)

func play_sfx(sound_name: String) -> void:
	if not sfx_enabled:
		return
	var path: String = SOUNDS.get(sound_name, "")
	if path == "":
		return
	var stream := load(path) as AudioStream
	if stream:
		_sfx_player.stream = stream
		_sfx_player.play()

func play_music(path: String) -> void:
	if not music_enabled:
		return
	if path == "":
		return
	var stream := load(path) as AudioStream
	if stream:
		_music_player.stream = stream
		_music_player.play()

func stop_music() -> void:
	_music_player.stop()

func set_sfx_enabled(value: bool) -> void:
	sfx_enabled = value
	SaveManager.set_bool("sfx_enabled", value)

func set_music_enabled(value: bool) -> void:
	music_enabled = value
	SaveManager.set_bool("music_enabled", value)
