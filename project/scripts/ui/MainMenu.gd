extends Control
class_name MainMenu

@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var daily_button: Button = $VBoxContainer/DailyButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var high_score_label: Label = $HighScoreLabel
@onready var daily_played_label: Label = $DailyPlayedLabel

func _ready() -> void:
	high_score_label.text = "BEST: " + str(ScoreManager.get_high_score())
	_update_daily_status()
	play_button.pressed.connect(_on_play_pressed)
	daily_button.pressed.connect(_on_daily_pressed)
	settings_button.pressed.connect(_on_settings_pressed)

func _update_daily_status() -> void:
	if DailyChallengeManager.has_played_today():
		daily_played_label.text = "Daily Best: " + str(SaveManager.get_daily_best_score())
		daily_played_label.visible = true
	else:
		daily_played_label.visible = false

func _on_play_pressed() -> void:
	AudioManager.play_sfx("button")
	GameManager.start_game()
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_daily_pressed() -> void:
	AudioManager.play_sfx("button")
	GameManager.start_daily_challenge()
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_settings_pressed() -> void:
	AudioManager.play_sfx("button")
	get_tree().change_scene_to_file("res://scenes/Settings.tscn")
