extends TileMapLayer
class_name BlocksTileMap

# Signal to notify the rest of the game that the game is over.
signal game_over

@export_group("Gameplay")
@export var spawn_every_ticks : int = 10
@export var spawn_coords : Array[Vector2i] = [Vector2i(0,-6)]

@export_group("Play Area")
@export var play_area_width : int = 10
@export var play_area_height : int = 20
@export var draw_debug_border : bool = true

const FALLING_BLOCKS_SOURCE_ID := 0
const PLACED_BLOCKS_SOURCE_ID := 1

const PIECES := [
	[Vector2i(0,0)], # .
	[Vector2i(0,0),Vector2i(1,0)], # -
	[Vector2i(-1,0),Vector2i(0,0),Vector2i(1,0)], # _
	[Vector2i(0,-1),Vector2i(0,0),Vector2i(1,0)], # L
]

var _buffer : TileMapLayer
var _tick := 0
var _next_piece_id := 0

func get_min_x() -> int:
	return 0 - (play_area_width / 2)

func get_max_x() -> int:
	return get_min_x() + play_area_width

func get_min_y() -> int:
	return -(play_area_height/2)

func get_bottom_y() -> int:
	# The bottom coordinate is exclusive (it's the coordinate of the floor)
	return get_min_y() + play_area_height
	
var _falling_pieces : Array[Dictionary] = []
func someone_tapped(tapper) -> void:
	var preview_tile_map = %HeldBlockTileMap
	if not tapper is Ship or preview_tile_map == null:
		return

	# Ship is holding a piece, so we try to RELEASE it
	if tapper.is_holding_piece():
		if not preview_tile_map.is_current_placement_valid():
			return # Do nothing if placement is invalid.

		var piece_to_release = tapper.grabbed_piece
		var piece_shape = piece_to_release['shape']
		var piece_color = piece_to_release['color_i']
		
		var ship_anchor_pos = to_local(tapper.global_position + Vector2(150, 0).rotated(tapper.global_rotation))
		var map_anchor_cell = local_to_map(ship_anchor_pos)
		
		var absolute_cells: Array[Vector2i] = []
		for cell_offset in piece_shape:
			absolute_cells.append(map_anchor_cell + cell_offset)
			
		spawn_piece(absolute_cells, Vector2i(0,0), piece_color)
		
		tapper.release_piece()
		
		preview_tile_map.hide_preview()

	# --- Ship is empty-handed, so we try to GRAB a piece
	else:
		var ship_cell = local_to_map(to_local(tapper.global_position))
		if get_cell_source_id(ship_cell) != FALLING_BLOCKS_SOURCE_ID:
			return

		var grabbed_piece: Dictionary = {}
		for piece in _falling_pieces:
			if ship_cell in piece['cells']:
				grabbed_piece = piece
				break
		
		if grabbed_piece.is_empty():
			return

		_falling_pieces.erase(grabbed_piece)
		for cell in grabbed_piece['cells']:
			erase_cell(cell)
		
		var anchor_cell = grabbed_piece['cells'][0]
		var piece_shape: Array[Vector2i] = []
		for cell in grabbed_piece['cells']:
			piece_shape.append(cell - anchor_cell)
		
		tapper.grab_piece(piece_shape, grabbed_piece['color_i'])
		
		preview_tile_map.show_preview_piece(piece_shape)


func _ready() -> void:
	# let's connect the tap signal
	Events.tap.connect(someone_tapped)
	_buffer = TileMapLayer.new()
	_buffer.tile_set = tile_set
	
	const C1 = [Vector2i(0,-2),Vector2i(0,-1),Vector2i(0,0),Vector2i(1,0),Vector2i(1,-2)]
	const C2 = [Vector2i(1,-3),Vector2i(1,-1),Vector2i(2,-1),Vector2i(2,-2),Vector2i(2,-3)]
	const C3 = [Vector2i(-1,-3),Vector2i(-1,-1),Vector2i(-1,-2),Vector2i(0,-3)]
	const C4 = [Vector2i(-1,-4),Vector2i(0,-4),Vector2i(-2,-4),Vector2i(-3,-4)]
	
	spawn_piece(C2, Vector2i(1,1), 3)
	spawn_piece(C1, Vector2i(1,1), 0)
	spawn_piece(C3, Vector2i(1,1), 1)
	spawn_piece(C4, Vector2i(1,1), 2)
	
	# Initial draw of the spawned pieces onto the main map
	_draw_falling_pieces()

func get_all_placed_blocks_cells() -> Array[Vector2i]:
	return get_used_cells_by_id(PLACED_BLOCKS_SOURCE_ID)

func _check_and_clear_lines():
	# We iterate from the bottom row up to the top.
	var y = get_bottom_y() - 1
	while y >= get_min_y():
		var is_line_full = true
		# Check every cell in the current row.
		for x in range(get_min_x(), get_max_x()):
			# If even one cell is not a placed block, the line is not full.
			if _buffer.get_cell_source_id(Vector2i(x, y)) != PLACED_BLOCKS_SOURCE_ID:
				is_line_full = false
				break
		
		if is_line_full:
			# If the line is full, clear it.
			for x in range(get_min_x(), get_max_x()):
				_buffer.erase_cell(Vector2i(x, y))

			# Then, shift every row above it down by one.
			# We start from the row just above the cleared one and go up to the top.
			for row_to_move_y in range(y - 1, get_min_y() - 1, -1):
				for x in range(get_min_x(), get_max_x()):
					var cell_above = Vector2i(x, row_to_move_y)
					var source_id = _buffer.get_cell_source_id(cell_above)
					
					# Only move cells that are not empty
					if source_id != -1:
						var atlas_coords = _buffer.get_cell_atlas_coords(cell_above)
						# Set the cell in the row below with the data from the cell above.
						_buffer.set_cell(Vector2i(x, row_to_move_y + 1), source_id, atlas_coords)
						# Erase the original cell from above.
						_buffer.erase_cell(cell_above)
			
			# IMPORTANT: Since we shifted rows down, the current 'y' needs to be checked again
			# in the next loop iteration, so we don't increment y.
			# The 'else' block handles the increment for non-cleared lines.
		else:
			# If the line was not full, we move on to check the row above it.
			y -= 1

func tick() -> void:
	# copy all placed blocks on the buffer
	for cell in get_all_placed_blocks_cells():
		_buffer.set_cell(cell, PLACED_BLOCKS_SOURCE_ID, get_cell_atlas_coords(cell))

	var still_falling_pieces = _falling_pieces.duplicate() # Work on a copy.
	var newly_stopped_found = true
	
	while newly_stopped_found:
		newly_stopped_found = false
		var pieces_to_remove : Array[Dictionary] = []

		for piece in still_falling_pieces:
			var should_stop = false
			for cell in piece['cells']:
				var next_cell = cell + Vector2i(0, 1)
				if next_cell.y >= get_bottom_y() or _buffer.get_cell_source_id(next_cell) == PLACED_BLOCKS_SOURCE_ID:
					should_stop = true
					break
			
			if should_stop:
				newly_stopped_found = true
				pieces_to_remove.append(piece)
				
				var atlas_coords = Vector2i(piece['color_i'], 0)
				for cell in piece['cells']:
					_buffer.set_cell(cell, PLACED_BLOCKS_SOURCE_ID, atlas_coords)
		
		for piece in pieces_to_remove:
			still_falling_pieces.erase(piece)

	# This happens after blocks have landed but before we draw the next frame.
	_check_and_clear_lines()

	# Update the state of pieces that survived the fall check.
	for piece in still_falling_pieces:
		var new_cells : Array[Vector2i] = []
		for cell in piece['cells']:
			new_cells.append(cell + Vector2i(0, 1))
		piece['cells'] = new_cells
		
		var atlas_coords = Vector2i(piece['color_i'], 2)
		for cell in piece['cells']:
			_buffer.set_cell(cell, FALLING_BLOCKS_SOURCE_ID, atlas_coords)

	_falling_pieces = still_falling_pieces
	
	clear()
	set_tile_map_data_from_array(_buffer.get_tile_map_data_as_array())
	_buffer.clear()
	
	if _tick % spawn_every_ticks == 0:
		spawn_new_piece() 
	
	_tick += 1

func _draw_falling_pieces() -> void:
	for piece in _falling_pieces:
		var atlas_coords = Vector2i(piece['color_i'], 2)
		for cell in piece['cells']:
			set_cell(cell, FALLING_BLOCKS_SOURCE_ID, atlas_coords)

func spawn_new_piece() -> void:
	var random_piece_i = randi_range(0, PIECES.size() - 1)
	var piece_to_spawn = PIECES[random_piece_i]
	var from_where = spawn_coords.pick_random()
	spawn_piece(piece_to_spawn, from_where, random_piece_i)
	
func spawn_piece(cells, from_where: Vector2i, color_i: int) -> void:
	# Before spawning, check if the target cells are already occupied by placed blocks.
	for cell_offset in cells:
		var target_cell = cell_offset + from_where
		if get_cell_source_id(target_cell) == PLACED_BLOCKS_SOURCE_ID:
			# If the space is blocked, emit the game_over signal and stop.
			game_over.emit()
			return
			
	var new_piece_cells: Array[Vector2i] = []
	for cell_offset in cells:
		new_piece_cells.append(cell_offset + from_where)
		
	_falling_pieces.append({
		'id': _next_piece_id,
		'cells': new_piece_cells,
		'color_i': color_i
	})
	
	_next_piece_id += 1
	
	_draw_falling_pieces()
