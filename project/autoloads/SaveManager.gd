extends Node

const SAVE_FILE_PATH: String = "user://save_data.cfg"

var _data: Dictionary = {}

func _ready() -> void:
	_load()

func _load() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return
	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file == null:
		return
	var text := file.get_as_text()
	file.close()
	var parsed := JSON.parse_string(text)
	if parsed is Dictionary:
		_data = parsed

func _save() -> void:
	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(_data))
	file.close()

func get_int(key: String, default_val: int = 0) -> int:
	return int(_data.get(key, default_val))

func set_int(key: String, value: int) -> void:
	_data[key] = value
	_save()

func get_bool(key: String, default_val: bool = false) -> bool:
	return bool(_data.get(key, default_val))

func set_bool(key: String, value: bool) -> void:
	_data[key] = value
	_save()

func get_string(key: String, default_val: String = "") -> String:
	return str(_data.get(key, default_val))

func set_string(key: String, value: String) -> void:
	_data[key] = value
	_save()

func get_float(key: String, default_val: float = 0.0) -> float:
	return float(_data.get(key, default_val))

func set_float(key: String, value: float) -> void:
	_data[key] = value
	_save()

func get_last_daily_date() -> String:
	return get_string("last_daily_date", "")

func set_last_daily_date(date: String) -> void:
	set_string("last_daily_date", date)

func get_daily_best_score() -> int:
	return get_int("daily_best_score", 0)

func set_daily_best_score(score: int) -> void:
	if score > get_daily_best_score():
		set_int("daily_best_score", score)

func get_achievements() -> Array:
	var raw = _data.get("achievements", [])
	if raw is Array:
		return raw
	return []

func unlock_achievement(id: String) -> bool:
	var achievements := get_achievements()
	if id in achievements:
		return false
	achievements.append(id)
	_data["achievements"] = achievements
	_save()
	return true
