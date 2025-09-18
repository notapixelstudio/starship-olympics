extends TileMapLayer
class_name PreviewTileMap

@export var ship : Ship
@export var blocks_tile_map : BlocksField

const INVALID_PLACEMENT_TILE_DELTA = Vector2i(0, 1) # blocked placement tile

var _current_preview_block : Block = null


func show_preview_block(block) -> void:
	_current_preview_block = block
	_update_preview()

func hide_preview() -> void:
	_current_preview_block = null
	clear()

func _process(delta: float) -> void:
	_update_preview()

var _is_currently_valid := true

func is_current_placement_valid() -> bool:
	return _is_currently_valid

func _update_preview() -> void:
	if _current_preview_block == null:
		clear()
		_is_currently_valid = false
		return
		
	if not ship:
		return

	var ship_anchor_pos = to_local(ship.global_position + Vector2(150, 0).rotated(ship.global_rotation))
	var map_anchor_cell = local_to_map(ship_anchor_pos)

	var is_placement_valid = true
	
	var min_x = blocks_tile_map.get_min_x()
	var max_x = blocks_tile_map.get_max_x()
	var min_y = blocks_tile_map.get_min_y() # For checking if you're too high
	var bottom_y = blocks_tile_map.get_bottom_y()
	
	# check if placement would be valid here
	for tile in _current_preview_block.get_tiles():
		var target_cell = map_anchor_cell + tile.get_cell() + _current_preview_block.get_position()
		
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
		if blocks_tile_map.get_cell_source_id(target_cell) != -1:
			is_placement_valid = false
			break
	
	_is_currently_valid = is_placement_valid
	
	clear()
	for tile in _current_preview_block.get_tiles():
		var target_cell = map_anchor_cell + tile.get_cell()
		set_cell(target_cell, Block.BlockTile.Source.FALLING, tile.get_atlas_coords(Block.BlockTile.Source.FALLING) + (INVALID_PLACEMENT_TILE_DELTA if not is_placement_valid else Vector2i(0,0)))
