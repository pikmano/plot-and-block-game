extends Node

signal score_changed(new_score: int)
signal high_score_beaten(new_high_score: int)

const POINTS_PER_CELL: int = 10
const POINTS_PER_LINE: int = 100
const COMBO_MULTIPLIER: float = 1.5

var current_score: int = 0
var high_score: int = 0
var session_lines_cleared: int = 0

func _ready() -> void:
	high_score = SaveManager.get_int("high_score", 0)

func reset() -> void:
	current_score = 0
	session_lines_cleared = 0
	emit_signal("score_changed", current_score)

func add_placement_score(cell_count: int) -> void:
	_add_score(cell_count * POINTS_PER_CELL)

func add_clear_score(lines_cleared: int) -> void:
	var base: int = lines_cleared * POINTS_PER_LINE
	var bonus: int = 0
	if lines_cleared > 1:
		bonus = int(base * (lines_cleared - 1) * (COMBO_MULTIPLIER - 1.0))
	session_lines_cleared += lines_cleared
	_add_score(base + bonus)

func _add_score(amount: int) -> void:
	current_score += amount
	emit_signal("score_changed", current_score)
	if current_score > high_score:
		high_score = current_score
		SaveManager.set_int("high_score", high_score)
		emit_signal("high_score_beaten", high_score)

func get_current_score() -> int:
	return current_score

func get_high_score() -> int:
	return high_score
