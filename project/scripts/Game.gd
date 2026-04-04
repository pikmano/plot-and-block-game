extends Node2D
class_name Game

@onready var grid: Grid = $GridContainer/Grid
@onready var tray: BlockTray = $TrayContainer/BlockTray
@onready var city_builder: CityBuilder = $CityBuilder
@onready var hud: HUD = $HUD
@onready var game_over_screen: GameOverScreen = $GameOverLayer/GameOverScreen

var _is_daily: bool = false
var _continue_used: bool = false

func _ready() -> void:
	_is_daily = GameManager.current_state == GameManager.GameState.DAILY_CHALLENGE

	ScoreManager.reset()
	game_over_screen.hide()

	tray.setup(grid)
	tray.no_valid_placements.connect(_on_no_valid_placements)
	grid.lines_cleared.connect(_on_lines_cleared)
	GameManager.continue_with_ad.connect(_on_continue_with_ad)

	if _is_daily:
		if DailyChallengeManager.has_played_today():
			_show_game_over(true)
			return
		seed(DailyChallengeManager.get_today_seed())

func _on_lines_cleared(_count: int, _positions: Array) -> void:
	# Future: spawn particle effects at cleared _positions
	pass

func _on_no_valid_placements() -> void:
	if _is_daily:
		DailyChallengeManager.mark_played_today()
		SaveManager.set_daily_best_score(ScoreManager.get_current_score())

	AudioManager.play_sfx("game_over")
	GameManager.trigger_game_over()
	_show_game_over(false)

func _on_continue_with_ad() -> void:
	# Player successfully watched the ad; give them a fresh tray
	_continue_used = true
	game_over_screen.hide()
	GameManager.current_state = GameManager.GameState.PLAYING
	tray.refill_for_continue()
	# Re-connect no_valid_placements for post-continue game over (no second continue)
	tray.no_valid_placements.disconnect(_on_no_valid_placements)
	tray.no_valid_placements.connect(_on_final_game_over)

func _on_final_game_over() -> void:
	if _is_daily:
		DailyChallengeManager.mark_played_today()
		SaveManager.set_daily_best_score(ScoreManager.get_current_score())
	AudioManager.play_sfx("game_over")
	GameManager.trigger_game_over()
	_show_game_over(true)  # no continue available

func _show_game_over(continue_used: bool) -> void:
	game_over_screen.activate(continue_used)
	game_over_screen.show()
