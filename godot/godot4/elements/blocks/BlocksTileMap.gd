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

const PIECES = [
	[Vector2i(0,0)], # .
	[Vector2i(0,0),Vector2i(1,0)], # -
	[Vector2i(-1,0),Vector2i(0,0),Vector2i(1,0)], # _
	[Vector2i(0,-1),Vector2i(0,0),Vector2i(1,0)], # L
]

var _buffer : TileMapLayer
var _tick := 0
var _next_piece_id := 0

func _ready():
	Events.tap.connect(someone_tapped)
	_buffer = TileMapLayer.new()
	_buffer.tile_set = tile_set
	
	_draw_falling_pieces()

func get_min_x(): return 0 - (play_area_width / 2)
func get_max_x(): return get_min_x() + play_area_width
func get_min_y(): return -(play_area_height/2)
func get_bottom_y(): return get_min_y() + play_area_height
func get_all_placed_blocks_cells(): return get_used_cells_by_id(PLACED_BLOCKS_SOURCE_ID)


func someone_tapped(tapper):
	var preview_tile_map = %HeldBlockTileMap
	if not tapper is Ship or preview_tile_map == null:
		return

	if tapper.is_holding_piece():
		if not preview_tile_map.is_current_placement_valid():
			return

		var piece_to_release = tapper.grabbed_piece
		var piece_color = piece_to_release['color_i']
		var rotated_shape = preview_tile_map.get_current_rotated_shape()
		var ship_anchor_pos = to_local(tapper.global_position + Vector2(150, 0).rotated(tapper.global_rotation))
		var map_anchor_cell = local_to_map(ship_anchor_pos)
		
		# Spawn the piece using the final rotated shape. shape_index is irrelevant here.
		spawn_piece(rotated_shape, map_anchor_cell, piece_color)
		
		tapper.release_piece()
		preview_tile_map.hide_preview()

	# Ship is empty-handed, so we try to GRAB a piece
	else:
		var ship_cell = local_to_map(to_local(tapper.global_position))
		if get_cell_source_id(ship_cell) != FALLING_BLOCKS_SOURCE_ID:
			return

		var grabbed_piece: Dictionary = {}
		for piece in _falling_pieces:
			if ship_cell in piece['cells']:
				grabbed_piece = piece
				break
		
		if grabbed_piece.is_empty()
			return

		_falling_pieces.erase(grabbed_piece)
		for cell in grabbed_piece['cells']:
			erase_cell(cell)

		# this won't allow us to have composite pieces
		var canonical_shape = PIECES[grabbed_piece['shape_index']]
		var color = grabbed_piece['color_i']

		var ship_grab_angle_degrees = snapped(rad_to_deg(tapper.global_rotation), 90.0)
		var ship_grab_angle_radians = deg_to_rad(ship_grab_angle_degrees)

		#The falling piece's rotation is always 0. The offset is the difference.
		var orientation_offset = 0.0 - ship_grab_angle_radians

		# Pass the CANONICAL shape and the calculated offset to the ship and preview.
		tapper.grab_piece(canonical_shape, color, orientation_offset)
		preview_tile_map.show_preview_piece(canonical_shape, orientation_offset)

func tick():
	# Copy placed blocks to buffer
	for cell in get_all_placed_blocks_cells():
		_buffer.set_cell(cell, PLACED_BLOCKS_SOURCE_ID, get_cell_atlas_coords(cell))

	var still_falling_pieces = _falling_pieces.duplicate()
	var newly_stopped_found = true
	while newly_stopped_found:
		newly_stopped_found = false
		var pieces_to_remove = []

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
				var atlas_coords = Vector2i(piece['color_i'], 0) # Placed block tile
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
		
		var atlas_coords = Vector2i(piece['color_i'], 2) # Falling block tile
		for cell in piece['cells']:
			_buffer.set_cell(cell, FALLING_BLOCKS_SOURCE_ID, atlas_coords)

	_falling_pieces = still_falling_pieces

	clear()
	set_tile_map_data_from_array(_buffer.get_tile_map_data_as_array())
	_buffer.clear()

	if _tick % spawn_every_ticks == 0:
		spawn_new_piece() 
	
	_tick += 1


func _check_and_clear_lines():
	var y = get_bottom_y() - 1
	while y >= get_min_y():
		var is_line_full = true
		for x in range(get_min_x(), get_max_x()):
			if _buffer.get_cell_source_id(Vector2i(x, y)) != PLACED_BLOCKS_SOURCE_ID:
				is_line_full = false
				break
		
		if is_line_full:
			for x in range(get_min_x(), get_max_x()):
				_buffer.erase_cell(Vector2i(x, y))

			for row_to_move_y in range(y - 1, get_min_y() - 1, -1):
				for x in range(get_min_x(), get_max_x()):
					var cell_above = Vector2i(x, row_to_move_y)
					var source_id = _buffer.get_cell_source_id(cell_above)
					if source_id != -1:
						var atlas = _buffer.get_cell_atlas_coords(cell_above)
						_buffer.set_cell(Vector2i(x, row_to_move_y + 1), source_id, atlas)
						_buffer.erase_cell(cell_above)
		else:
			y -= 1 # Only move to the next row if no line was cleared.


func spawn_new_piece():
	var random_piece_i = randi_range(0, PIECES.size() - 1)
	var piece_to_spawn = PIECES[random_piece_i]
	var from_where = spawn_coords.pick_random()
	spawn_piece(piece_to_spawn, from_where, random_piece_i, random_piece_i)
	
func spawn_piece(cells, from_where, color_i, shape_index = -1):
	# Game Over check
	for cell_offset in cells:
		var target_cell = cell_offset + from_where
		if get_cell_source_id(target_cell) == PLACED_BLOCKS_SOURCE_ID:
			game_over.emit()
			return
			
	var new_piece_cells = []
	for cell_offset in cells:
		new_piece_cells.append(cell_offset + from_where)
		
	_falling_pieces.append({
		'id': _next_piece_id,
		'cells': new_piece_cells,
		'color_i': color_i,
		'shape_index': shape_index # Store the original shape index
	})
	
	_next_piece_id += 1
	_draw_falling_pieces()

func _draw_falling_pieces():
	for piece in _falling_pieces:
		var atlas_coords = Vector2i(piece['color_i'], 2) # Falling block tile
		for cell in piece['cells']:
			set_cell(cell, FALLING_BLOCKS_SOURCE_ID, atlas_coords)
