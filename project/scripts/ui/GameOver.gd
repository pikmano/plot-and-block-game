extends Control
class_name GameOverScreen

@onready var score_label: Label = $Panel/VBoxContainer/ScoreLabel
@onready var high_score_label: Label = $Panel/VBoxContainer/HighScoreLabel
@onready var continue_button: Button = $Panel/VBoxContainer/ContinueButton
@onready var menu_button: Button = $Panel/VBoxContainer/MenuButton
@onready var share_button: Button = $Panel/VBoxContainer/ShareButton
@onready var new_record_label: Label = $Panel/VBoxContainer/NewRecordLabel

var _continue_used: bool = false

func _ready() -> void:
	# Only wire up button connections here; score/display happens in activate()
	continue_button.pressed.connect(_on_continue_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	share_button.pressed.connect(_on_share_pressed)

# Call this before show() to set score text and trigger interstitial
func activate(continue_already_used: bool = false) -> void:
	_continue_used = continue_already_used
	score_label.text = "SCORE\n" + str(ScoreManager.get_current_score())
	high_score_label.text = "BEST: " + str(ScoreManager.get_high_score())
	var score := ScoreManager.get_current_score()
	new_record_label.visible = score > 0 and score >= ScoreManager.get_high_score()
	continue_button.visible = not _continue_used
	AdManager.maybe_show_interstitial()

func _on_continue_pressed() -> void:
	_continue_used = true
	continue_button.visible = false
	AdManager.rewarded_ad_completed.connect(_on_ad_completed, CONNECT_ONE_SHOT)
	AdManager.rewarded_ad_failed.connect(_on_ad_failed, CONNECT_ONE_SHOT)
	AdManager.show_rewarded_ad()

func _on_ad_completed() -> void:
	# Tell Game scene to resume with a fresh tray
	GameManager.request_continue_with_ad()
	hide()

func _on_ad_failed() -> void:
	var dialog := AcceptDialog.new()
	dialog.dialog_text = "Ad not available right now. Try again later."
	add_child(dialog)
	dialog.popup_centered()

func _on_menu_pressed() -> void:
	AudioManager.play_sfx("button")
	GameManager.go_to_main_menu()

func _on_share_pressed() -> void:
	var score: int = ScoreManager.get_current_score()
	var text: String = "I scored %d in Plot & Block! Can you beat me? #PlotAndBlock" % score
	# Copy to clipboard on all platforms; on Android a full share intent requires a plugin
	DisplayServer.clipboard_set(text)
	print("[Share] Score copied to clipboard: ", text)
