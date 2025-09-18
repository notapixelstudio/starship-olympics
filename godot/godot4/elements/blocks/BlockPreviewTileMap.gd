extends TileMapLayer
class_name PreviewTileMap

@export var blocks_field : BlocksField

const INVALID_PLACEMENT_TILE_DELTA = Vector2i(0, 1) # blocked placement tile

var _current_preview_block : Block = null


func show_preview_block(block) -> void:
	_current_preview_block = block
	_update_preview()

func hide_preview() -> void:
	_current_preview_block = null
	clear()
	
func _ready() -> void:
	Events.tap.connect(someone_tapped)
	
	# shift half a cell for odd number of columns
	if blocks_field.play_area_width % 2 != 0:
		position.x -= tile_set.tile_size.x/2.0
		
	# shift half a cell for odd number of rows
	if blocks_field.play_area_height % 2 != 0:
		position.y -= tile_set.tile_size.y/2.0

func _process(delta: float) -> void:
	_update_preview()

var _is_currently_valid := true

func is_current_placement_valid() -> bool:
	return _is_currently_valid
	
func someone_tapped(tapper) -> void:
	if not tapper is Ship:
		return

	# Ship is holding a block, so we try to RELEASE it
	if tapper.is_holding_block():
		if tapper.is_in_rotation_zone:
			var current_block = tapper.grabbed_block
			var new_block = current_block.rotated()
			
			tapper.update_grabbed_block(new_block)
			show_preview_block(new_block)
			return 
		if not is_current_placement_valid():
			return # Do nothing if placement is invalid.

		var block_to_release = tapper.grabbed_block
		
		var ship_anchor_pos = to_local(tapper.global_position + Vector2(150, 0).rotated(tapper.global_rotation))
		var map_anchor_cell = local_to_map(ship_anchor_pos)
		
		blocks_field.spawn_block(block_to_release, map_anchor_cell)
		
		tapper.release_block()
		
		hide_preview()

	# --- Ship is empty-handed, so we try to GRAB a block
	else:
		var ship_cell = local_to_map(to_local(tapper.global_position))
		if blocks_field.get_cell_source_id(ship_cell) != Block.BlockTile.Source.FALLING:
			return

		var grabbed_block: Block = blocks_field.get_falling_block_or_null_from_cell(ship_cell)
		
		if grabbed_block == null:
			return

		blocks_field.erase_block(grabbed_block)
		for tile in grabbed_block.get_tiles():
			blocks_field.erase_cell(tile.get_cell()+grabbed_block.get_position())
		
		var anchor_cell = grabbed_block.get_tiles()[0].get_cell()
		tapper.grab_block(grabbed_block)
		
		show_preview_block(grabbed_block)

func _update_preview() -> void:
	for ship in get_tree().get_nodes_in_group('Ship'): # FIXME this supports either 0 or 1 ship - not 2 or more
		if _current_preview_block == null:
			clear()
			_is_currently_valid = false
			return
			
		if not ship:
			return

		var ship_anchor_pos = to_local(ship.global_position + Vector2(150, 0).rotated(ship.global_rotation))
		var map_anchor_cell = local_to_map(ship_anchor_pos)

		var is_placement_valid = true
		
		var min_x = blocks_field.get_min_x()
		var max_x = blocks_field.get_max_x()
		var min_y = blocks_field.get_min_y() # For checking if you're too high
		var bottom_y = blocks_field.get_bottom_y()
		
		# check if placement would be valid here
		for tile in _current_preview_block.get_tiles():
			var target_cell = map_anchor_cell + tile.get_cell()
			
			# Check if outside horizontal bounds
			if target_cell.x < min_x or target_cell.x >= max_x:
				is_placement_valid = false
				break
			
			# Check if outside vertical bounds (can be above, but not below)
			if target_cell.y >= bottom_y:
				is_placement_valid = false
				break
			# not above
			if target_cell.y < min_y:
				is_placement_valid = false
				break
			
			# collision check
			if blocks_field.get_cell_source_id(target_cell) != -1:
				is_placement_valid = false
				break
		
		_is_currently_valid = is_placement_valid
		
		clear()
		for tile in _current_preview_block.get_tiles():
			var target_cell = map_anchor_cell + tile.get_cell()
			set_cell(target_cell, Block.BlockTile.Source.FALLING, tile.get_atlas_coords(Block.BlockTile.Source.FALLING) + (INVALID_PLACEMENT_TILE_DELTA if not is_placement_valid else Vector2i(0,0)))
