extends Node2D
class_name CityBuilder

const BUILDING_COLORS: Array = [
	Color(0.28, 0.45, 0.70),
	Color(0.55, 0.35, 0.70),
	Color(0.70, 0.45, 0.28),
	Color(0.28, 0.65, 0.55),
	Color(0.70, 0.60, 0.28),
]

var _buildings: Array = []
var _total_lines_cleared: int = 0

# Called by Grid when lines are cleared
func on_lines_cleared(count: int) -> void:
	_total_lines_cleared += count
	_spawn_buildings(count)

func _spawn_buildings(count: int) -> void:
	for i in range(count):
		_spawn_building()

func _spawn_building() -> void:
	var building := ColorRect.new()
	var width: float = randf_range(28.0, 72.0)
	var height: float = randf_range(40.0, 130.0)
	var color: Color = BUILDING_COLORS[randi() % BUILDING_COLORS.size()]
	building.size = Vector2(width, height)
	building.color = color
	# City skyline grows from the bottom of the screen (below tray which ends ~y=990)
	# Viewport is 720x1280 so buildings sit in the y=990-1280 strip
	building.position = Vector2(
		randf_range(0.0, 720.0 - width),
		1280.0 - height   # bottom-anchored; tallest buildings reach up to ~y=1150
	)
	add_child(building)
	_buildings.append(building)
	# Animate in from invisible
	building.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(building, "modulate:a", 1.0, 0.5)

func reset() -> void:
	for b in _buildings:
		if is_instance_valid(b):
			b.queue_free()
	_buildings = []
	_total_lines_cleared = 0

func get_city_level() -> int:
	return _total_lines_cleared / 5
