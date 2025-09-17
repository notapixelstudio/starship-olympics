# File: BlocksTileMap.gd
# Attach this to your main game board TileMapLayer node.

extends TileMapLayer
class_name BlocksTileMap

signal game_over

@export_group("Gameplay")
@export var spawn_every_ticks = 10
@export var spawn_coords = [Vector2i(0,-6)]

@export var SPAWNABLE_PATTERNS = [
	[{"pos": Vector2i(0,0), "color_i": 0}], # Single block
	[{"pos": Vector2i(0,0), "color_i": 1}, {"pos": Vector2i(1,0), "color_i": 2}], # Two-tone bar
	[{"pos": Vector2i(-1,0), "color_i": 3}, {"pos": Vector2i(0,0), "color_i": 0}, {"pos": Vector2i(1,0), "color_i": 3}], # Symmetrical 3-bar
	[{"pos": Vector2i(0,-1), "color_i": 1}, {"pos": Vector2i(0,0), "color_i": 1}, {"pos": Vector2i(1,0), "color_i": 2}], # L-shape with two colors
	[{"pos": Vector2i(0,0), "color_i": 0}, {"pos": Vector2i(1,0), "color_i": 1}, {"pos": Vector2i(0,1), "color_i": 2}, {"pos": Vector2i(1,1), "color_i": 3}], # 2x2 rainbow square
]


@export_group("Play Area")
@export var play_area_width = 10
@export var play_area_height = 20
@export var draw_debug_border = true

const FALLING_BLOCKS_SOURCE_ID = 0
const PLACED_BLOCKS_SOURCE_ID = 1

var _buffer: TileMapLayer
var _tick = 0
var _next_piece_id = 0
var _falling_pieces = []

func _ready():
	Events.tap.connect(someone_tapped)
	_buffer = TileMapLayer.new()
	_buffer.tile_set = tile_set
	
	# Manual
	const C1 = [
		{"pos": Vector2i(0,-2), "color_i": 0}, {"pos": Vector2i(0,-1), "color_i": 1},
		{"pos": Vector2i(0,0), "color_i": 0}, {"pos": Vector2i(1,0), "color_i": 1},
		{"pos": Vector2i(1,-2), "color_i": 0}
	]
	spawn_piece(C1, Vector2i(1,1))
	
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
		
		var pattern_to_spawn = piece_to_release["pattern"]
		
		var rotated_shape_positions = preview_tile_map.get_current_rotated_shape()
		var ship_anchor_pos = to_local(tapper.global_position + Vector2(150, 0).rotated(tapper.global_rotation))
		var map_anchor_cell = local_to_map(ship_anchor_pos)
		
		var final_pattern = []
		for i in range(pattern_to_spawn.size()):
			final_pattern.append({
				"pos": rotated_shape_positions[i],
				"color_i": pattern_to_spawn[i]["color_i"]
			})
		
		spawn_piece(final_pattern, map_anchor_cell) 
		
		tapper.release_piece()
		preview_tile_map.hide_preview()
		
	else:
		var ship_cell = local_to_map(to_local(tapper.global_position))
		if get_cell_source_id(ship_cell) != FALLING_BLOCKS_SOURCE_ID:
			return

		var grabbed_piece_data = {}
		for piece in _falling_pieces:
			for cell_data in piece['cells']:
				if cell_data["pos"] == ship_cell:
					grabbed_piece_data = piece
					break
			if not grabbed_piece_data.is_empty():
				break
		
		if grabbed_piece_data.is_empty():
			return

		var anchor_cell = ship_cell
		
		var relative_pattern = []
		for cell_data in grabbed_piece_data['cells']:
			relative_pattern.append({
				"pos": cell_data["pos"] - anchor_cell,
				"color_i": cell_data["color_i"]
			})

		_falling_pieces.erase(grabbed_piece_data)
		for cell_data in grabbed_piece_data['cells']:
			erase_cell(cell_data["pos"])
		
		var ship_grab_angle_degrees = snapped(rad_to_deg(tapper.global_rotation), 90.0)
		var ship_grab_angle_radians = deg_to_rad(ship_grab_angle_degrees)

		# MODIFIED: Pass the whole pattern to the ship, not just shape and color
		tapper.grab_piece(relative_pattern, ship_grab_angle_radians)
		preview_tile_map.show_preview()



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
			
			for cell_data in piece['cells']:
				var next_cell = cell_data["pos"] + Vector2i(0, 1)
				if next_cell.y >= get_bottom_y() or _buffer.get_cell_source_id(next_cell) == PLACED_BLOCKS_SOURCE_ID:
					should_stop = true
					break
			
			if should_stop:
				newly_stopped_found = true
				pieces_to_remove.append(piece)
				
				for cell_data in piece['cells']:
					var atlas_coords = Vector2i(cell_data['color_i'], 0) # Placed block tile
					_buffer.set_cell(cell_data["pos"], PLACED_BLOCKS_SOURCE_ID, atlas_coords)
		
		for piece in pieces_to_remove:
			still_falling_pieces.erase(piece)

	# Check for and clear any completed color groups
	_check_and_clear_color_groups()

	# 4. Update and draw pieces that are still falling
	for piece in still_falling_pieces:
		for cell_data in piece['cells']:
			cell_data["pos"] += Vector2i(0, 1)
		
		for cell_data in piece['cells']:
			var atlas_coords = Vector2i(cell_data['color_i'], 2) # Falling block tile
			_buffer.set_cell(cell_data["pos"], FALLING_BLOCKS_SOURCE_ID, atlas_coords)

	_falling_pieces = still_falling_pieces
	
	# 5. Redraw the main tilemap from the buffer
	clear()
	set_tile_map_data_from_array(_buffer.get_tile_map_data_as_array())
	_buffer.clear()
	
	# 6. Spawn a new piece if it's time
	if _tick % spawn_every_ticks == 0:
		spawn_new_piece() 
	
	_tick += 1

# --- Color Group Clearing Logic ---
func _check_and_clear_color_groups():
	var all_placed_blocks = _buffer.get_used_cells_by_id(PLACED_BLOCKS_SOURCE_ID) # Check the buffer
	var visited_cells = []
	var groups_to_clear = []

	for block in all_placed_blocks:
		if block in visited_cells:
			continue

		var color = _buffer.get_cell_atlas_coords(block).x
		var group = _find_color_group(block, color)
		
		for cell in group:
			visited_cells.append(cell)
			
		if group.size() >= 4:
			groups_to_clear.append_array(group)
	
	if not groups_to_clear.is_empty():
		for cell in groups_to_clear:
			_buffer.erase_cell(cell)
		
		_apply_gravity_after_clear()

func _find_color_group(start_cell, color_index):
	var group = []
	var to_visit = [start_cell]
	var visited = [start_cell]

	while not to_visit.is_empty():
		var current_cell = to_visit.pop_front()
		group.append(current_cell)

		const NEIGHBORS = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
		for offset in NEIGHBORS:
			var neighbor_cell = current_cell + offset
			if not neighbor_cell in visited:
				visited.append(neighbor_cell)
				if _buffer.get_cell_source_id(neighbor_cell) == PLACED_BLOCKS_SOURCE_ID and \
				   _buffer.get_cell_atlas_coords(neighbor_cell).x == color_index:
					to_visit.append(neighbor_cell)
	
	return group

func _apply_gravity_after_clear():
	for x in range(get_min_x(), get_max_x()):
		var empty_count = 0
		for y in range(get_bottom_y() - 1, get_min_y() - 1, -1):
			var current_cell = Vector2i(x, y)
			if _buffer.get_cell_source_id(current_cell) == -1:
				empty_count += 1
			elif empty_count > 0:
				var source_id = _buffer.get_cell_source_id(current_cell)
				var atlas = _buffer.get_cell_atlas_coords(current_cell)
				_buffer.set_cell(current_cell + Vector2i(0, empty_count), source_id, atlas)
				_buffer.erase_cell(current_cell)


func spawn_new_piece():
	var random_pattern_i = randi_range(0, SPAWNABLE_PATTERNS.size() - 1)
	var pattern_to_spawn = SPAWNABLE_PATTERNS[random_pattern_i]
	var from_where = spawn_coords.pick_random()
	spawn_piece(pattern_to_spawn, from_where)
	
func spawn_piece(pattern, from_where):
	# Game Over check
	for cell_data in pattern:
		var target_cell = cell_data["pos"] + from_where
		if get_cell_source_id(target_cell) == PLACED_BLOCKS_SOURCE_ID:
			game_over.emit()
			return
			
	var new_piece_cells = []
	for cell_data in pattern:
		new_piece_cells.append({
			"pos": cell_data["pos"] + from_where,
			"color_i": cell_data["color_i"]
		})
		
	_falling_pieces.append({
		'id': _next_piece_id,
		'cells': new_piece_cells,
	})
	
	_next_piece_id += 1
	_draw_falling_pieces()

func _draw_falling_pieces():
	
	for piece in _falling_pieces:
		for cell_data in piece['cells']:
			var atlas_coords = Vector2i(cell_data['color_i'], 2) # Falling block tile
			set_cell(cell_data["pos"], FALLING_BLOCKS_SOURCE_ID, atlas_coords)
