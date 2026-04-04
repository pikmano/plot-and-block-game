extends RefCounted
class_name DailyChallengeManager

static func get_today_seed() -> int:
	var date: Dictionary = Time.get_date_dict_from_system()
	# Create a deterministic seed from YYYYMMDD
	return date.year * 10000 + date.month * 100 + date.day

static func get_today_string() -> String:
	var date: Dictionary = Time.get_date_dict_from_system()
	return "%04d-%02d-%02d" % [date.year, date.month, date.day]

static func has_played_today() -> bool:
	return SaveManager.get_last_daily_date() == get_today_string()

static func mark_played_today() -> void:
	SaveManager.set_last_daily_date(get_today_string())

static func get_daily_shapes(count: int = 20) -> Array:
	# Generate a seeded list of block shape names for the daily challenge
	var shapes: Array = []
	var all_names: Array = BlockShapes.get_all_names()
	var rng := RandomNumberGenerator.new()
	rng.seed = get_today_seed()
	for i in range(count):
		shapes.append(all_names[rng.randi() % all_names.size()])
	return shapes
