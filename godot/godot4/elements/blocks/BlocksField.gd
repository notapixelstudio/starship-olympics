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

@export_group("Graphics")
@export var block_cleared_scene : PackedScene

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

func start() -> void:
	%FallTimer.start()

func _ready() -> void:
	# shift half a cell for odd number of columns
	if play_area_width % 2 != 0:
		position.x -= tile_set.tile_size.x/2.0
		%GridLines.position.x += tile_set.tile_size.x/2.0
		
	# shift half a cell for odd number of rows
	if play_area_height % 2 != 0:
		position.y -= tile_set.tile_size.y/2.0
		%GridLines.position.y += tile_set.tile_size.y/2.0
		
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
	
func get_falling_block_or_null_from_cell(cell:Vector2i):
	for block in _falling_blocks:
		if block.has_cell(cell):
			return block
	return null
	
func erase_block(block:Block) -> void:
	_falling_blocks.erase(block)

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
			%FallTimer.paused = true

			Events.blocks_cleared.emit(self, play_area_width, global_position +  Vector2(0.5, (y+0.5)*tile_set.tile_size.y))
			
			# If the line is full, clear it.
			var block_cleared_effect
			for x in range(get_min_x(), get_max_x()):
				# spawn the block cleared effect
				var cell = Vector2i(x, y)
				block_cleared_effect = block_cleared_scene.instantiate()
				block_cleared_effect.set_color(_get_cell_color(_buffer, cell))
				block_cleared_effect.set_liquid(_is_cell_liquid(_buffer, cell))
				block_cleared_effect.global_position = Vector2(cell.x*tile_set.tile_size.x, cell.y*tile_set.tile_size.y)
				add_child(block_cleared_effect)

				_buffer.erase_cell(cell)
				
			# wait for the last block cleared effect to finish
			await block_cleared_effect.done
			%FallTimer.paused = false
			
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

func _check_and_clear_colors():
	var cells_to_clear: Array[Vector2i] = []
	var visited_cells: Dictionary = {}

	for y in range(get_min_y(), get_bottom_y()):
		for x in range(get_min_x(), get_max_x()):
			var current_cell = Vector2i(x, y)

			if visited_cells.has(current_cell) or _buffer.get_cell_source_id(current_cell) != Block.BlockTile.Source.PLACED:
				continue

			# Get the atlas coords and try to find the specific color integer.
			var atlas_coords = _buffer.get_cell_atlas_coords(current_cell)
			var current_color = Block.BlockTile.get_color_from_atlas_coords(atlas_coords)
			
			var group: Array[Vector2i] = []
			var queue: Array[Vector2i] = [current_cell]
			visited_cells[current_cell] = true

			while not queue.is_empty():
				var cell = queue.pop_front()
				group.append(cell)
				
				# we could use, .get_neighbor_cell(cell, TileSet.CellNeighbor.BOTTOM_SIDE) Worth it? I don't know
				var neighbors = [
					cell + Vector2i(0, 1), cell + Vector2i(0, -1),
					cell + Vector2i(1, 0), cell + Vector2i(-1, 0)
				]
				
				for neighbor in neighbors:
					if not visited_cells.has(neighbor) and _buffer.get_cell_source_id(neighbor) == Block.BlockTile.Source.PLACED:
						
						# get the color of neighbor
						var neighbor_atlas_coords = _buffer.get_cell_atlas_coords(neighbor)
						var neighbor_color = Block.BlockTile.get_color_from_atlas_coords(neighbor_atlas_coords)

						if neighbor_color == current_color:
							visited_cells[neighbor] = true
							queue.append(neighbor)
			
			if group.size() >= 4:
				cells_to_clear.append_array(group)

	if cells_to_clear.is_empty():
		return
	
	%FallTimer.paused = true

	var centroid = Vector2(cells_to_clear[0].x*tile_set.tile_size.x, cells_to_clear[0].y*tile_set.tile_size.y)
	for i in range(1,len(cells_to_clear)):
		centroid += Vector2(cells_to_clear[i].x*tile_set.tile_size.x, cells_to_clear[i].y*tile_set.tile_size.y)
	centroid /= len(cells_to_clear)
	
	Events.blocks_cleared.emit(self, len(cells_to_clear), centroid+Vector2(0.5,0.5))

	var block_cleared_effect
	for cell in cells_to_clear:
		# spawn the block cleared effect
		block_cleared_effect = block_cleared_scene.instantiate()
		block_cleared_effect.set_color(_get_cell_color(_buffer, cell))
		block_cleared_effect.set_liquid(_is_cell_liquid(_buffer, cell))
		block_cleared_effect.global_position = Vector2(cell.x*tile_set.tile_size.x, cell.y*tile_set.tile_size.y)
		add_child(block_cleared_effect)

		# clear the cell
		_buffer.erase_cell(cell)

	# wait for the last block cleared effect to finish
	await block_cleared_effect.done
	%FallTimer.paused = false

	for x in range(get_min_x(), get_max_x()):
		var empty_space_count = 0
		for y in range(get_bottom_y() - 1, get_min_y() - 1, -1):
			var current_cell = Vector2i(x, y)
			if _buffer.get_cell_source_id(current_cell) == -1:
				empty_space_count += 1
			elif empty_space_count > 0:
				var source_id = _buffer.get_cell_source_id(current_cell)
				var cell_atlas_coords = _buffer.get_cell_atlas_coords(current_cell)
				_buffer.set_cell(current_cell + Vector2i(0, empty_space_count), source_id, cell_atlas_coords)
				_buffer.erase_cell(current_cell)

func tick() -> void:
	if _falling_blocks.is_empty() and get_used_cells_by_id(Block.BlockTile.Source.PLACED).is_empty():
		# Optimization: If nothing is happening, just handle spawning and exit.
		if _tick % spawn_every_ticks == 0:
			spawn_new_piece()
		_tick += 1
		return

	for cell in get_all_placed_blocks_cells():
		_buffer.set_cell(cell, Block.BlockTile.Source.PLACED, get_cell_atlas_coords(cell))

	var current_falling_blocks = _falling_blocks.duplicate()
	var next_tick_falling_blocks: Array[Block] = []
	# This tracks cells that become solid during this tick, for other blocks to land on.
	var halting_cells_this_tick: Dictionary = {}

	# Sort all blocks from bottom-to-top to resolve chain reactions between separate blocks.
	current_falling_blocks.sort_custom(func(a, b):
		var a_max_y = -INF
		for tile in a.get_tiles(): a_max_y = max(a_max_y, a.get_position().y + tile.get_cell().y)
		var b_max_y = -INF
		for tile in b.get_tiles(): b_max_y = max(b_max_y, b.get_position().y + tile.get_cell().y)
		return a_max_y > b_max_y
	)

	for block in current_falling_blocks:
		if block.get_tiles().is_empty(): continue

		# Check if the block as a whole is supported by anything solid below.
		var is_block_supported = false
		for tile in block.get_tiles():
			var cell_below = block.get_position() + tile.get_cell() + Vector2i(0, 1)
			if cell_below.y >= get_bottom_y() or \
			   _buffer.get_cell_source_id(cell_below) != -1 or \
			   halting_cells_this_tick.has(cell_below):
				is_block_supported = true
				break

		if not is_block_supported:
			# Block is in free-fall. Move it and keep it for the next tick.
			block.move_by(Vector2i(0, 1))
			next_tick_falling_blocks.append(block)
		else:
			# Block has collided. Process based on type.
			if not block.get_tiles()[0].is_liquid():
				# SOLID BLOCK: Halts as a single rigid unit.
				for tile in block.get_tiles():
					var current_cell = block.get_position() + tile.get_cell()
					_buffer.set_cell(current_cell, Block.BlockTile.Source.PLACED, tile.get_atlas_coords(Block.BlockTile.Source.PLACED))
					halting_cells_this_tick[current_cell] = true
			else:
				# LIQUID BLOCK: It breaks apart and settles
				
				# Deconstruct the block into a list of its individual tiles with absolute positions.
				var tiles_to_process: Array[Dictionary] = []
				for tile in block.get_tiles():
					tiles_to_process.append({"pos": block.get_position() + tile.get_cell(), "tile": tile})
				
				# Sort from bottom-to-top
				tiles_to_process.sort_custom(func(a, b): return a.pos.y > b.pos.y)
				
				# Process the tiles sequentially
				for item in tiles_to_process:
					var current_pos: Vector2i = item.pos
					var tile: Block.BlockTile = item.tile
					var cell_below = current_pos + Vector2i(0, 1)

					# A tile is supported if the cell below is the floor, a pre-existing block, OR
					# another tile (from any block, including its own) that has already halted in this tick.
					var is_tile_supported = cell_below.y >= get_bottom_y() or \
										   _buffer.get_cell_source_id(cell_below) != -1 or \
										   halting_cells_this_tick.has(cell_below)
					
					if is_tile_supported:
						# This tile halts. Solidify it and add it to the list of halted cells
						_buffer.set_cell(current_pos, Block.BlockTile.Source.PLACED, tile.get_atlas_coords(Block.BlockTile.Source.PLACED))
						halting_cells_this_tick[current_pos] = true
					else:
						# Nothing beneath, free fall
						var new_tile = tile.copy()
						new_tile.set_cell(Vector2i.ZERO)
						var new_falling_block = Block.new(current_pos + Vector2i(0, 1), [new_tile])
						next_tick_falling_blocks.append(new_falling_block)

	# First colors and then lines, so lines get priority in case of overlap
	_check_and_clear_colors()
	_check_and_clear_lines()

	_falling_blocks = next_tick_falling_blocks

	# Double buffering
	clear()
	set_tile_map_data_from_array(_buffer.get_tile_map_data_as_array())
	for block in _falling_blocks:
		for tile in block.get_tiles():
			set_cell(block.get_position() + tile.get_cell(), Block.BlockTile.Source.FALLING, tile.get_atlas_coords(Block.BlockTile.Source.FALLING))
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

func _get_cell_color(tilemap: TileMapLayer, cell: Vector2i) -> int:
	var atlas_x = tilemap.get_cell_atlas_coords(cell).x - Block.BlockTile.TILEMAP_START_X
	var liquid = _is_cell_liquid(tilemap, cell)
	return atlas_x if not liquid else atlas_x - Block.BlockTile.COLORS

func _is_cell_liquid(tilemap: TileMapLayer, cell: Vector2i) -> bool:
	var atlas_x = tilemap.get_cell_atlas_coords(cell).x - Block.BlockTile.TILEMAP_START_X
	return atlas_x >= Block.BlockTile.COLORS

# FIXME this should be deleted soon
func _rotate_piece_shape(shape) -> Array[Vector2i]:
	var new_shape: Array[Vector2i] = []
	# Rotate each Vector2i in the shape by 90 degrees clockwise
	for cell_offset in shape:
		new_shape.append(Vector2i(cell_offset.y, -cell_offset.x))
	return new_shape
