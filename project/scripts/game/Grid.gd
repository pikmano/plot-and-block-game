extends Node2D
class_name Grid

signal lines_cleared(count: int, positions: Array)
signal block_placed(shape_name: String, grid_pos: Vector2i)
signal grid_full

const GRID_SIZE: int = 8
const CELL_SIZE: int = 72  # pixels per cell

var _cells: Array = []  # 2D array [row][col] = color or null
var _cell_nodes: Array = []  # 2D array of ColorRect nodes

@onready var _city_builder: Node = get_node_or_null("../../CityBuilder")

func _ready() -> void:
	_init_grid()
	_build_visual()

func _init_grid() -> void:
	_cells = []
	for r in range(GRID_SIZE):
		var row := []
		for c in range(GRID_SIZE):
			row.append(null)
		_cells.append(row)

func _build_visual() -> void:
	# Draw grid background
	var bg := ColorRect.new()
	bg.size = Vector2(GRID_SIZE * CELL_SIZE, GRID_SIZE * CELL_SIZE)
	bg.position = Vector2.ZERO
	bg.color = Color(0.10, 0.12, 0.18, 1.0)
	add_child(bg)

	_cell_nodes = []
	for r in range(GRID_SIZE):
		var row_nodes := []
		for c in range(GRID_SIZE):
			var rect := ColorRect.new()
			rect.size = Vector2(CELL_SIZE - 2, CELL_SIZE - 2)
			rect.position = Vector2(c * CELL_SIZE + 1, r * CELL_SIZE + 1)
			rect.color = Color(0.15, 0.15, 0.20, 1.0)
			add_child(rect)
			row_nodes.append(rect)
		_cell_nodes.append(row_nodes)

func get_total_size() -> Vector2:
	return Vector2(GRID_SIZE * CELL_SIZE, GRID_SIZE * CELL_SIZE)

func can_place(shape_name: String, grid_row: int, grid_col: int) -> bool:
	var cells: Array = BlockShapes.get_shape(shape_name)
	for offset in cells:
		var r: int = grid_row + offset[0]
		var c: int = grid_col + offset[1]
		if r < 0 or r >= GRID_SIZE or c < 0 or c >= GRID_SIZE:
			return false
		if _cells[r][c] != null:
			return false
	return true

func place_block(shape_name: String, grid_row: int, grid_col: int) -> void:
	var cells: Array = BlockShapes.get_shape(shape_name)
	var color: Color = BlockShapes.get_color(shape_name)
	for offset in cells:
		var r: int = grid_row + offset[0]
		var c: int = grid_col + offset[1]
		_cells[r][c] = color
		_update_cell_visual(r, c, color)
	emit_signal("block_placed", shape_name, Vector2i(grid_col, grid_row))
	ScoreManager.add_placement_score(cells.size())
	AudioManager.play_sfx("place")
	_check_and_clear_lines()

func _check_and_clear_lines() -> void:
	var rows_to_clear: Array = []
	var cols_to_clear: Array = []

	for r in range(GRID_SIZE):
		var full := true
		for c in range(GRID_SIZE):
			if _cells[r][c] == null:
				full = false
				break
		if full:
			rows_to_clear.append(r)

	for c in range(GRID_SIZE):
		var full := true
		for r in range(GRID_SIZE):
			if _cells[r][c] == null:
				full = false
				break
		if full:
			cols_to_clear.append(c)

	if rows_to_clear.is_empty() and cols_to_clear.is_empty():
		return

	var cleared_positions: Array = []
	for r in rows_to_clear:
		for c in range(GRID_SIZE):
			_cells[r][c] = null
			cleared_positions.append(Vector2i(c, r))
	for c in cols_to_clear:
		for r in range(GRID_SIZE):
			_cells[r][c] = null
			cleared_positions.append(Vector2i(c, r))

	_refresh_visuals()
	var total_lines: int = rows_to_clear.size() + cols_to_clear.size()
	ScoreManager.add_clear_score(total_lines)
	AudioManager.play_sfx("clear")
	emit_signal("lines_cleared", total_lines, cleared_positions)
	if _city_builder:
		_city_builder.on_lines_cleared(total_lines)

func _update_cell_visual(r: int, c: int, color) -> void:
	var rect: ColorRect = _cell_nodes[r][c]
	if color == null:
		rect.color = Color(0.15, 0.15, 0.20, 1.0)
	else:
		rect.color = color

func _refresh_visuals() -> void:
	for r in range(GRID_SIZE):
		for c in range(GRID_SIZE):
			_update_cell_visual(r, c, _cells[r][c])

func highlight_cells(shape_name: String, grid_row: int, grid_col: int, valid: bool) -> void:
	_clear_highlights()
	var cells: Array = BlockShapes.get_shape(shape_name)
	var color: Color = BlockShapes.get_color(shape_name)
	var highlight_color: Color = color if valid else Color(0.9, 0.2, 0.2, 0.5)
	for offset in cells:
		var r: int = grid_row + offset[0]
		var c: int = grid_col + offset[1]
		if r >= 0 and r < GRID_SIZE and c >= 0 and c < GRID_SIZE:
			if _cells[r][c] == null:
				_cell_nodes[r][c].color = highlight_color
			else:
				_cell_nodes[r][c].color = Color(0.9, 0.2, 0.2, 0.5)

func _clear_highlights() -> void:
	_refresh_visuals()

func clear_highlight() -> void:
	_refresh_visuals()

func has_any_valid_placement(shape_names: Array) -> bool:
	for shape_name in shape_names:
		for r in range(GRID_SIZE):
			for c in range(GRID_SIZE):
				if can_place(shape_name, r, c):
					return true
	return false

func world_to_grid(world_pos: Vector2) -> Vector2i:
	var local_pos: Vector2 = to_local(world_pos)
	var col: int = int(local_pos.x / CELL_SIZE)
	var row: int = int(local_pos.y / CELL_SIZE)
	return Vector2i(col, row)

func grid_to_world(grid_col: int, grid_row: int) -> Vector2:
	return to_global(Vector2(grid_col * CELL_SIZE, grid_row * CELL_SIZE))

func reset() -> void:
	_init_grid()
	_refresh_visuals()
