extends Node2D
class_name BlockTray

signal piece_placed(shape_name: String)
signal no_valid_placements

var _pieces: Array = []
var _grid: Grid = null

const SLOT_COUNT: int = 3
const TRAY_WIDTH: float = 680.0
const TRAY_HEIGHT: float = 170.0

func setup(grid: Grid) -> void:
	_grid = grid
	_draw_tray_background()
	_fill_tray()

func _draw_tray_background() -> void:
	var bg := ColorRect.new()
	bg.size = Vector2(TRAY_WIDTH, TRAY_HEIGHT)
	bg.position = Vector2(20.0, 0.0)
	bg.color = Color(0.07, 0.09, 0.15, 1.0)
	add_child(bg)

func _fill_tray() -> void:
	for piece in _pieces:
		if is_instance_valid(piece):
			piece.queue_free()
	_pieces = []

	for i in range(SLOT_COUNT):
		var shape_name: String = BlockShapes.get_random_name()
		var piece := _create_piece(shape_name)
		add_child(piece)
		_position_piece_in_slot(piece, i)
		_pieces.append(piece)

	# Wait one frame so positions settle, then check game-over
	await get_tree().process_frame
	_check_game_over()

func _create_piece(shape_name: String) -> BlockPiece:
	var piece := BlockPiece.new()
	piece.setup(shape_name)
	piece.drag_started.connect(_on_drag_started)
	piece.drag_ended.connect(_on_drag_ended)
	return piece

func _position_piece_in_slot(piece: BlockPiece, slot_index: int) -> void:
	var slot_width: float = TRAY_WIDTH / SLOT_COUNT
	var slot_center_x: float = 20.0 + slot_index * slot_width + slot_width / 2.0
	var bounds: Vector2i = BlockShapes.get_bounding_size(piece.shape_name)
	var piece_px_w: float = bounds.x * BlockPiece.CELL_SIZE
	var piece_px_h: float = bounds.y * BlockPiece.CELL_SIZE
	piece.position = Vector2(
		slot_center_x - piece_px_w / 2.0,
		TRAY_HEIGHT / 2.0 - piece_px_h / 2.0 + 5.0
	)

func _on_drag_started(_piece: BlockPiece) -> void:
	pass  # Future: haptic feedback on Android

func _on_drag_ended(piece: BlockPiece, drop_world_pos: Vector2) -> void:
	if _grid == null:
		piece.return_to_tray()
		return

	# drop_world_pos is the piece's global top-left at time of release
	var grid_cell: Vector2i = _grid.world_to_grid(drop_world_pos)
	var place_row: int = grid_cell.y
	var place_col: int = grid_cell.x

	if _grid.can_place(piece.shape_name, place_row, place_col):
		_grid.place_block(piece.shape_name, place_row, place_col)
		_pieces.erase(piece)
		piece.remove_from_tray()
		emit_signal("piece_placed", piece.shape_name)
		if _pieces.is_empty():
			_fill_tray()
		else:
			# Re-center remaining pieces
			var idx := 0
			for p in _pieces:
				if is_instance_valid(p) and not p.is_dragging:
					_position_piece_in_slot(p, idx)
				idx += 1
			await get_tree().process_frame
			_check_game_over()
	else:
		piece.return_to_tray()

func _check_game_over() -> void:
	var active_shapes: Array = []
	for piece in _pieces:
		if is_instance_valid(piece):
			active_shapes.append(piece.shape_name)
	if active_shapes.is_empty():
		return
	if not _grid.has_any_valid_placement(active_shapes):
		emit_signal("no_valid_placements")

func get_active_shapes() -> Array:
	var shapes: Array = []
	for piece in _pieces:
		if is_instance_valid(piece):
			shapes.append(piece.shape_name)
	return shapes

func refill_for_continue() -> void:
	_fill_tray()

func get_grid() -> Grid:
	return _grid

func set_pieces_enabled(enabled: bool) -> void:
	for piece in _pieces:
		if is_instance_valid(piece):
			piece.set_process_input(enabled)
			piece.modulate.a = 1.0 if enabled else 0.5
