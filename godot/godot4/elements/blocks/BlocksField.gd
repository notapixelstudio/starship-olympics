extends TileMapLayer
class_name BlocksField

# Signal to notify the rest of the game that the game in this BlocksField is over.
signal game_over

@export_group("Gameplay")
@export var tick_duration : = 1.0 : set = set_tick_duration
@export var spawn_every_ticks : int = 10
@export var spawn_coords : Array[Vector2i] = [Vector2i(0,-6)]

@export_group("Play Area")
@export var play_area_width : int = 10
@export var play_area_height : int = 20

var _buffer : TileMapLayer
var _tick := 0


func set_tick_duration(v:float) -> void:
	tick_duration = v
	%FallTimer.wait_time = tick_duration

func get_min_x() -> int:
	return 0 - (play_area_width / 2)

func get_max_x() -> int:
	return get_min_x() + play_area_width

func get_min_y() -> int:
	return -(play_area_height/2)

func get_bottom_y() -> int:
	# The bottom coordinate is exclusive (it's the coordinate of the floor)
	return get_min_y() + play_area_height
	
var _falling_blocks : Array[Block] = []
func someone_tapped(tapper) -> void:
	var preview_tile_map = %BlockPreviewTileMap
	if not tapper is Ship or preview_tile_map == null:
		return

	# Ship is holding a block, so we try to RELEASE it
	if tapper.is_holding_block():
		if tapper.is_in_rotation_zone:
			var current_block = tapper.grabbed_block
			var new_block = current_block.rotated()
			
			tapper.update_grabbed_block(new_block)
			preview_tile_map.show_preview_block(new_block)
			return 
		if not preview_tile_map.is_current_placement_valid():
			return # Do nothing if placement is invalid.

		var block_to_release = tapper.grabbed_block
		
		var ship_anchor_pos = to_local(tapper.global_position + Vector2(150, 0).rotated(tapper.global_rotation))
		var map_anchor_cell = local_to_map(ship_anchor_pos)
		
		spawn_block(block_to_release, map_anchor_cell)
		
		tapper.release_block()
		
		preview_tile_map.hide_preview()

	# --- Ship is empty-handed, so we try to GRAB a block
	else:
		var ship_cell = local_to_map(to_local(tapper.global_position))
		if get_cell_source_id(ship_cell) != Block.BlockTile.Source.FALLING:
			return

		var grabbed_block: Block = null
		for block in _falling_blocks:
			if block.has_cell(ship_cell):
				grabbed_block = block
				break
		
		if grabbed_block == null:
			return

		_falling_blocks.erase(grabbed_block)
		for tile in grabbed_block.get_tiles():
			erase_cell(tile.get_cell()+grabbed_block.get_position())
		
		var anchor_cell = grabbed_block.get_tiles()[0].get_cell()
		tapper.grab_block(grabbed_block)
		
		preview_tile_map.show_preview_block(grabbed_block)

func start() -> void:
	%FallTimer.start()

func _ready() -> void:
	# let's connect the tap signal
	Events.tap.connect(someone_tapped)
	
	# create a buffer for writing modifications to the tilemap without overwriting
	_buffer = TileMapLayer.new()
	_buffer.tile_set = tile_set
	
	# set up the grid
	var style = %Styleable.get_style_from_ancestor_or_self()
	%GridLines.color = style.grid_color
	%GridLines.cell_size = tile_set.tile_size
	%GridLines.size = Vector2i(tile_set.tile_size.x*play_area_width, tile_set.tile_size.y*play_area_height)
	%GridLines.outline_thickness = 20.0
	%GridLines.init_grid()
	

func get_all_placed_blocks_cells() -> Array[Vector2i]:
	return get_used_cells_by_id(Block.BlockTile.Source.PLACED)

func _check_and_clear_lines():
	# We iterate from the bottom row up to the top.
	var y = get_bottom_y() - 1
	while y >= get_min_y():
		var is_line_full = true
		# Check every cell in the current row.
		for x in range(get_min_x(), get_max_x()):
			# If even one cell is not a placed block, the line is not full.
			if _buffer.get_cell_source_id(Vector2i(x, y)) != Block.BlockTile.Source.PLACED:
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
		_buffer.set_cell(cell, Block.BlockTile.Source.PLACED, get_cell_atlas_coords(cell))

	var still_falling_blocks = _falling_blocks.duplicate() # Work on a copy.
	var newly_stopped_found = true
	
	while newly_stopped_found:
		newly_stopped_found = false
		var blocks_to_remove : Array[Block] = []

		for block in still_falling_blocks:
			var should_stop = false
			for tile in block.get_tiles():
				var next_cell = tile.get_cell() + block.get_position() + Vector2i(0, 1)
				if next_cell.y >= get_bottom_y() or _buffer.get_cell_source_id(next_cell) == Block.BlockTile.Source.PLACED:
					should_stop = true
					break
			
			if should_stop:
				newly_stopped_found = true
				blocks_to_remove.append(block)
				
				for tile in block.get_tiles():
					_buffer.set_cell(tile.get_cell() + block.get_position(), Block.BlockTile.Source.PLACED, tile.get_atlas_coords(Block.BlockTile.Source.PLACED))
		
		for block in blocks_to_remove:
			still_falling_blocks.erase(block)

	# This happens after blocks have landed but before we draw the next frame.
	_check_and_clear_lines()

	# Update the state of pieces that survived the fall check.
	for block in still_falling_blocks:
		block.move_by(Vector2i(0, 1))
		
		for tile in block.get_tiles():
			_buffer.set_cell(tile.get_cell() + block.get_position(), Block.BlockTile.Source.FALLING, tile.get_atlas_coords(Block.BlockTile.Source.FALLING))

	_falling_blocks = still_falling_blocks
	
	clear()
	set_tile_map_data_from_array(_buffer.get_tile_map_data_as_array())
	_buffer.clear()
	
	if _tick % spawn_every_ticks == 0:
		spawn_new_piece() 
	
	_tick += 1

func _draw_falling_blocks() -> void:
	for block in _falling_blocks:
		for tile in block.get_tiles():
			set_cell(block.get_position()+tile.get_cell(), Block.BlockTile.Source.FALLING, tile.get_atlas_coords(Block.BlockTile.Source.FALLING))

func spawn_new_piece() -> void:
	#var new_block = Block.create(Block.Name.Ooo, true)
	var new_block = Block.create_random()
	var from_where = spawn_coords.pick_random()
	
	# Before spawning, check if the target cells are already occupied by placed blocks.
	for tile in new_block.get_tiles():
		if get_cell_source_id(tile.get_cell() + from_where) == Block.BlockTile.Source.PLACED:
			# If the space is blocked, emit the game_over signal and stop.
			game_over.emit()
			print("GAME_OVER")
			return
	
	spawn_block(new_block, from_where)
	
func spawn_block(block:Block, from_where: Vector2i) -> void:
	block.move_to(from_where)
	_falling_blocks.append(block)
	_draw_falling_blocks()

# FIXME this should be deleted soon
func _rotate_piece_shape(shape) -> Array[Vector2i]:
	var new_shape: Array[Vector2i] = []
	# Rotate each Vector2i in the shape by 90 degrees clockwise
	for cell_offset in shape:
		new_shape.append(Vector2i(cell_offset.y, -cell_offset.x))
	return new_shape
