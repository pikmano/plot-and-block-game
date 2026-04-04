extends CanvasLayer
class_name HUD

@onready var score_label: Label = $HUDContainer/ScoreLabel
@onready var high_score_label: Label = $HUDContainer/HighScoreLabel
@onready var pause_button: Button = $HUDContainer/PauseButton

func _ready() -> void:
	ScoreManager.score_changed.connect(_on_score_changed)
	ScoreManager.high_score_beaten.connect(_on_high_score_beaten)
	pause_button.pressed.connect(_on_pause_button_pressed)
	_refresh()

func _refresh() -> void:
	score_label.text = str(ScoreManager.get_current_score())
	high_score_label.text = "BEST: " + str(ScoreManager.get_high_score())

func _on_score_changed(new_score: int) -> void:
	score_label.text = str(new_score)

func _on_high_score_beaten(new_high: int) -> void:
	high_score_label.text = "BEST: " + str(new_high)
	# Flash the high score label gold
	var tween := create_tween()
	tween.tween_property(high_score_label, "modulate", Color.YELLOW, 0.2)
	tween.tween_property(high_score_label, "modulate", Color.WHITE, 0.2)

func _on_pause_button_pressed() -> void:
	GameManager.pause_game()
