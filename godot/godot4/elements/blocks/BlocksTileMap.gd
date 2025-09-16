# File: BlocksTileMap.gd
# Attach this to your main game board TileMapLayer node.

extends TileMapLayer
class_name BlocksTileMap

signal game_over

@export_group("Gameplay")
@export var spawn_every_ticks = 10
@export var spawn_coords = [Vector2i(0,-6)]

## ADDED: We define some example shapes for spawning new pieces.
## You can add any shape you want here.
@export var SPAWNABLE_SHAPES = [
	[Vector2i(0,0)], # .
	[Vector2i(0,0),Vector2i(1,0)], # -
	[Vector2i(-1,0),Vector2i(0,0),Vector2i(1,0)], # _
	[Vector2i(0,-1),Vector2i(0,0),Vector2i(1,0)], # L
]

@export_group("Play Area")
@export var play_area_width = 10
@export var play_area_height = 20
@export var draw_debug_border = true

const FALLING_BLOCKS_SOURCE_ID = 0
const PLACED_BLOCKS_SOURCE_ID = 1

var _buffer
var _tick = 0
var _next_piece_id = 0
var _falling_pieces = []

func _ready():
	Events.tap.connect(someone_tapped)
	_buffer = TileMapLayer.new()
	_buffer.tile_set = tile_set
	
	# Note: These initial pieces are now grabbable just like any other piece.
	const C1 = [Vector2i(0,-2),Vector2i(0,-1),Vector2i(0,0),Vector2i(1,0),Vector2i(1,-2)]
	const C2 = [Vector2i(1,-3),Vector2i(1,-1),Vector2i(2,-1),Vector2i(2,-2),Vector2i(2,-3)]
	spawn_piece(C2, Vector2i(1,1), 3)
	spawn_piece(C1, Vector2i(1,1), 0)
	
	_draw_falling_pieces()

# --- Public Getters for boundaries ---
func get_min_x(): return 0 - (play_area_width / 2)
func get_max_x(): return get_min_x() + play_area_width
func get_min_y(): return -(play_area_height/2)
func get_bottom_y(): return get_min_y() + play_area_height
func get_all_placed_blocks_cells(): return get_used_cells_by_id(PLACED_BLOCKS_SOURCE_ID)


# --- Core Interaction Logic ---
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
		
		spawn_piece(rotated_shape, map_anchor_cell, piece_color)
		
		tapper.release_piece()
		preview_tile_map.hide_preview()
		
	else:
		var ship_cell = local_to_map(to_local(tapper.global_position))
		if get_cell_source_id(ship_cell) != FALLING_BLOCKS_SOURCE_ID:
			return

		var grabbed_piece_data = {}
		for piece in _falling_pieces:
			if ship_cell in piece['cells']:
				grabbed_piece_data = piece
				break
		
		if grabbed_piece_data.is_empty():
			return

		var anchor_cell = ship_cell
		var relative_shape = []
		for cell in grabbed_piece_data['cells']:
			relative_shape.append(cell - anchor_cell)

		_falling_pieces.erase(grabbed_piece_data)
		for cell in grabbed_piece_data['cells']:
			erase_cell(cell)
		
		var color = grabbed_piece_data['color_i']

		## ADDED: Get the ship's snapped rotation at the moment of the grab.
		var ship_grab_angle_degrees = snapped(rad_to_deg(tapper.global_rotation), 90.0)
		var ship_grab_angle_radians = deg_to_rad(ship_grab_angle_degrees)

		## MODIFIED: Pass the grab angle to the ship.
		tapper.grab_piece(relative_shape, color, ship_grab_angle_radians)
		preview_tile_map.show_preview()


# --- Gameplay Tick Loop (Unchanged) ---
func tick():
	# 1. Copy placed blocks to buffer
	for cell in get_all_placed_blocks_cells():
		_buffer.set_cell(cell, PLACED_BLOCKS_SOURCE_ID, get_cell_atlas_coords(cell))

	# 2. Process falling blocks
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

	# 3. Check for and clear any completed lines
	_check_and_clear_lines()

	# 4. Update and draw pieces that are still falling
	for piece in still_falling_pieces:
		var new_cells = []
		for cell in piece['cells']: new_cells.append(cell + Vector2i(0, 1))
		piece['cells'] = new_cells
		
		var atlas_coords = Vector2i(piece['color_i'], 2) # Falling block tile
		for cell in piece['cells']:
			_buffer.set_cell(cell, FALLING_BLOCKS_SOURCE_ID, atlas_coords)

	_falling_pieces = still_falling_pieces
	
	# 5. Redraw the main tilemap from the buffer
	clear()
	set_tile_map_data_from_array(_buffer.get_tile_map_data_as_array())
	_buffer.clear()
	
	# 6. Spawn a new piece if it's time
	if _tick % spawn_every_ticks == 0:
		spawn_new_piece() 
	
	_tick += 1

# --- Line Clearing Logic (Unchanged) ---
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

# --- Piece Spawning (Modified) ---
func spawn_new_piece():
	## MODIFIED: Use the new SPAWNABLE_SHAPES array
	var random_piece_i = randi_range(0, SPAWNABLE_SHAPES.size() - 1)
	var piece_to_spawn = SPAWNABLE_SHAPES[random_piece_i]
	var from_where = spawn_coords.pick_random()
	spawn_piece(piece_to_spawn, from_where, random_piece_i)
	
## MODIFIED: Removed the 'shape_index' parameter as it's no longer needed.
func spawn_piece(cells, from_where, color_i):
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
	})
	
	_next_piece_id += 1
	_draw_falling_pieces()

func _draw_falling_pieces():
	for piece in _falling_pieces:
		var atlas_coords = Vector2i(piece['color_i'], 2) # Falling block tile
		for cell in piece['cells']:
			set_cell(cell, FALLING_BLOCKS_SOURCE_ID, atlas_coords)
