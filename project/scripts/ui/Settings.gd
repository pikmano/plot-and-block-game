extends Control

@onready var sfx_check: CheckButton = $VBoxContainer/SFXRow/SFXCheck
@onready var music_check: CheckButton = $VBoxContainer/MusicRow/MusicCheck
@onready var remove_ads_button: Button = $VBoxContainer/RemoveAdsButton
@onready var back_button: Button = $VBoxContainer/BackButton

func _ready() -> void:
	sfx_check.button_pressed = AudioManager.sfx_enabled
	music_check.button_pressed = AudioManager.music_enabled
	remove_ads_button.visible = not GameManager.is_ads_removed
	sfx_check.toggled.connect(_on_sfx_toggled)
	music_check.toggled.connect(_on_music_toggled)
	remove_ads_button.pressed.connect(_on_remove_ads_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _on_sfx_toggled(value: bool) -> void:
	AudioManager.set_sfx_enabled(value)

func _on_music_toggled(value: bool) -> void:
	AudioManager.set_music_enabled(value)

func _on_remove_ads_pressed() -> void:
	# TODO: In production, wire to Google Play Billing or App Store IAP plugin.
	# On success callback: GameManager.set_ads_removed(true); remove_ads_button.visible = false
	print("[IAP] Remove Ads purchase initiated")

func _on_back_pressed() -> void:
	AudioManager.play_sfx("button")
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
