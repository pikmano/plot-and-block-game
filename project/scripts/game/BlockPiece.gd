extends Node2D
class_name BlockPiece

signal drag_started(piece: BlockPiece)
signal drag_ended(piece: BlockPiece, piece_world_top_left: Vector2)
signal returned_to_tray

const CELL_SIZE: int = 48    # Size when sitting in tray
const DRAG_CELL_SIZE: int = 72  # Matches grid cell size while dragging

var shape_name: String = ""
var is_dragging: bool = false
var _original_position: Vector2 = Vector2.ZERO
var _drag_offset: Vector2 = Vector2.ZERO
var _current_cell_size: int = CELL_SIZE
var _cell_rects: Array = []

func setup(p_shape_name: String) -> void:
	shape_name = p_shape_name
	_build_visual(CELL_SIZE)

func _build_visual(cell_size: int) -> void:
	_current_cell_size = cell_size
	for child in get_children():
		child.queue_free()
	_cell_rects = []
	var cells: Array = BlockShapes.get_shape(shape_name)
	var color: Color = BlockShapes.get_color(shape_name)
	for offset in cells:
		var rect := ColorRect.new()
		rect.size = Vector2(cell_size - 3, cell_size - 3)
		rect.position = Vector2(offset[1] * cell_size + 1, offset[0] * cell_size + 1)
		rect.color = color
		# Subtle inner highlight
		var inner := ColorRect.new()
		inner.size = Vector2(cell_size - 10, cell_size - 10)
		inner.position = Vector2(4, 4)
		var lighter := Color(
			minf(color.r + 0.18, 1.0),
			minf(color.g + 0.18, 1.0),
			minf(color.b + 0.18, 1.0),
			1.0
		)
		inner.color = lighter
		rect.add_child(inner)
		add_child(rect)
		_cell_rects.append(rect)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var e := event as InputEventScreenTouch
		if e.pressed and not is_dragging:
			if _is_point_over_piece(e.position):
				_start_drag(e.position)
				get_viewport().set_input_as_handled()
		elif not e.pressed and is_dragging:
			_end_drag()
			get_viewport().set_input_as_handled()

	elif event is InputEventMouseButton:
		var e := event as InputEventMouseButton
		if e.button_index == MOUSE_BUTTON_LEFT:
			if e.pressed and not is_dragging:
				if _is_point_over_piece(e.position):
					_start_drag(e.position)
					get_viewport().set_input_as_handled()
			elif not e.pressed and is_dragging:
				_end_drag()
				get_viewport().set_input_as_handled()

	elif event is InputEventScreenDrag:
		if is_dragging:
			_update_drag((event as InputEventScreenDrag).position)
			get_viewport().set_input_as_handled()

	elif event is InputEventMouseMotion:
		if is_dragging:
			_update_drag((event as InputEventMouseMotion).position)
			get_viewport().set_input_as_handled()

func _is_point_over_piece(pos: Vector2) -> bool:
	var cells: Array = BlockShapes.get_shape(shape_name)
	for offset in cells:
		var cell_world := global_position + Vector2(
			offset[1] * _current_cell_size,
			offset[0] * _current_cell_size
		)
		if Rect2(cell_world, Vector2(_current_cell_size, _current_cell_size)).has_point(pos):
			return true
	return false

func _start_drag(touch_pos: Vector2) -> void:
	is_dragging = true
	_original_position = global_position
	# Position piece above the finger so it's visible on mobile
	var bounds: Vector2i = BlockShapes.get_bounding_size(shape_name)
	_drag_offset = Vector2(
		-(bounds.x * DRAG_CELL_SIZE) / 2.0,
		-(bounds.y * DRAG_CELL_SIZE) - 30.0
	)
	_build_visual(DRAG_CELL_SIZE)
	global_position = touch_pos + _drag_offset
	z_index = 10
	emit_signal("drag_started", self)

func _update_drag(touch_pos: Vector2) -> void:
	global_position = touch_pos + _drag_offset
	# Live grid highlight - find parent tray's grid and highlight
	if get_parent() and get_parent().has_method("get_grid"):
		var grid = get_parent().get_grid()
		if grid:
			var cell: Vector2i = grid.world_to_grid(global_position)
			var valid: bool = grid.can_place(shape_name, cell.y, cell.x)
			grid.highlight_cells(shape_name, cell.y, cell.x, valid)

func _end_drag() -> void:
	is_dragging = false
	z_index = 0
	# Clear any grid highlight
	if get_parent() and get_parent().has_method("get_grid"):
		var grid = get_parent().get_grid()
		if grid:
			grid.clear_highlight()
	# Emit the piece's current global position (top-left of piece)
	emit_signal("drag_ended", self, global_position)

func return_to_tray() -> void:
	is_dragging = false
	z_index = 0
	global_position = _original_position
	_build_visual(CELL_SIZE)
	emit_signal("returned_to_tray")

func remove_from_tray() -> void:
	queue_free()
