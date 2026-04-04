extends RefCounted
class_name BlockShapes

# Each shape is an Array of [row, col] offsets from origin.
# All shapes defined with top-left as anchor.

const SHAPES: Dictionary = {
	"I1":  [[0,0]],
	"I2":  [[0,0],[0,1]],
	"I3":  [[0,0],[0,1],[0,2]],
	"I4":  [[0,0],[0,1],[0,2],[0,3]],
	"I5":  [[0,0],[0,1],[0,2],[0,3],[0,4]],
	"I2V": [[0,0],[1,0]],
	"I3V": [[0,0],[1,0],[2,0]],
	"I4V": [[0,0],[1,0],[2,0],[3,0]],
	"I5V": [[0,0],[1,0],[2,0],[3,0],[4,0]],
	"SQ2": [[0,0],[0,1],[1,0],[1,1]],
	"SQ3": [[0,0],[0,1],[0,2],[1,0],[1,1],[1,2],[2,0],[2,1],[2,2]],
	"L":   [[0,0],[1,0],[2,0],[2,1]],
	"LR":  [[0,0],[0,1],[1,0],[2,0]],
	"J":   [[0,1],[1,1],[2,0],[2,1]],
	"JR":  [[0,0],[0,1],[0,2],[1,2]],
	"T":   [[0,0],[0,1],[0,2],[1,1]],
	"TV":  [[0,0],[1,0],[1,1],[2,0]],
	"S":   [[0,1],[0,2],[1,0],[1,1]],
	"Z":   [[0,0],[0,1],[1,1],[1,2]],
}

const SHAPE_COLORS: Dictionary = {
	"I1":  Color(0.98, 0.82, 0.27),   # Yellow
	"I2":  Color(0.98, 0.82, 0.27),
	"I3":  Color(0.27, 0.73, 0.98),   # Light Blue
	"I4":  Color(0.27, 0.73, 0.98),
	"I5":  Color(0.27, 0.73, 0.98),
	"I2V": Color(0.98, 0.82, 0.27),
	"I3V": Color(0.27, 0.73, 0.98),
	"I4V": Color(0.27, 0.73, 0.98),
	"I5V": Color(0.27, 0.73, 0.98),
	"SQ2": Color(0.98, 0.45, 0.27),   # Orange
	"SQ3": Color(0.98, 0.27, 0.27),   # Red
	"L":   Color(0.98, 0.60, 0.20),   # Orange-yellow
	"LR":  Color(0.98, 0.60, 0.20),
	"J":   Color(0.20, 0.40, 0.98),   # Blue
	"JR":  Color(0.20, 0.40, 0.98),
	"T":   Color(0.65, 0.27, 0.98),   # Purple
	"TV":  Color(0.65, 0.27, 0.98),
	"S":   Color(0.27, 0.85, 0.45),   # Green
	"Z":   Color(0.85, 0.27, 0.45),   # Pink-red
}

static func get_shape(name: String) -> Array:
	return SHAPES.get(name, [])

static func get_color(name: String) -> Color:
	return SHAPE_COLORS.get(name, Color.WHITE)

static func get_all_names() -> Array:
	return SHAPES.keys()

static func get_random_name() -> String:
	var keys := SHAPES.keys()
	return keys[randi() % keys.size()]

static func get_bounding_size(shape_name: String) -> Vector2i:
	var cells: Array = SHAPES.get(shape_name, [])
	var max_r := 0
	var max_c := 0
	for cell in cells:
		max_r = max(max_r, cell[0])
		max_c = max(max_c, cell[1])
	return Vector2i(max_c + 1, max_r + 1)
