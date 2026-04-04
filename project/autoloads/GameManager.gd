extends Node

signal game_started
signal game_over
signal game_paused(is_paused: bool)
signal continue_with_ad

enum GameState { MENU, PLAYING, PAUSED, GAME_OVER, DAILY_CHALLENGE }

var current_state: GameState = GameState.MENU
var is_ads_removed: bool = false

func _ready() -> void:
	is_ads_removed = SaveManager.get_bool("ads_removed", false)

func start_game() -> void:
	current_state = GameState.PLAYING
	emit_signal("game_started")

func start_daily_challenge() -> void:
	current_state = GameState.DAILY_CHALLENGE
	emit_signal("game_started")

func trigger_game_over() -> void:
	current_state = GameState.GAME_OVER
	emit_signal("game_over")

func pause_game() -> void:
	if current_state == GameState.PLAYING or current_state == GameState.DAILY_CHALLENGE:
		get_tree().paused = true
		current_state = GameState.PAUSED
		emit_signal("game_paused", true)

func resume_game() -> void:
	get_tree().paused = false
	current_state = GameState.PLAYING
	emit_signal("game_paused", false)

func request_continue_with_ad() -> void:
	emit_signal("continue_with_ad")

func set_ads_removed(value: bool) -> void:
	is_ads_removed = value
	SaveManager.set_bool("ads_removed", value)

func go_to_main_menu() -> void:
	current_state = GameState.MENU
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
