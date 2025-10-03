extends TileMapLayer
class_name PreviewTileMap

@export var blocks_field : BlocksField

@export var block_outline_scene : PackedScene

const INVALID_PLACEMENT_TILE_DELTA = Vector2i(0, 1) # blocked placement tile
const DEFAULT_TRACTOR_BEAM_OFFSET := 50.0

var _current_preview_blocks : Dictionary[Player, Block] = {}


func show_preview_block(player:Player, block) -> void:
	_current_preview_blocks[player] = block
	
func _ready() -> void:
	Events.start_charging.connect(_on_someone_started_charging)
	Events.tap.connect(_on_someone_tapped)
	Events.player_ready.connect(_on_player_ready)
	
	# shift half a cell for odd number of columns
	if blocks_field.play_area_width % 2 != 0:
		position.x -= tile_set.tile_size.x/2.0
		
	# shift half a cell for odd number of rows
	if blocks_field.play_area_height % 2 != 0:
		position.y -= tile_set.tile_size.y/2.0

func _process(delta: float) -> void:
	_update_preview()
	_update_feedback()

var _is_currently_valid : Dictionary[Player,bool] = {}

func is_current_placement_valid(player:Player) -> bool:
	return _is_currently_valid[player]
	
func _get_ship_anchor_cell(ship:Ship, offset:float) -> Vector2i:
	var ship_anchor_pos = to_local(ship.global_position + Vector2(offset, 0).rotated(ship.global_rotation))
	return local_to_map(ship_anchor_pos)
	
func _get_polygon_surrounding_cell(cell:Vector2i) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(cell.x*tile_set.tile_size.x,cell.y*tile_set.tile_size.y),
		Vector2((cell.x+1)*tile_set.tile_size.x,cell.y*tile_set.tile_size.y),
		Vector2((cell.x+1)*tile_set.tile_size.x,(cell.y+1)*tile_set.tile_size.y),
		Vector2(cell.x*tile_set.tile_size.x,(cell.y+1)*tile_set.tile_size.y),
	])
	
func _on_someone_started_charging(charger) -> void:
	pass
	
func _on_someone_tapped(tapper) -> void:
	if not tapper is Ship:
		return

	# Ship is holding a block, so we try to RELEASE it
	if tapper.is_holding_block():
		var anchor_cell
		if tapper.rotation_zone_type != null:
			# rotate the block
			var current_block = tapper.grabbed_block
			var new_block = current_block.rotated(tapper.rotation_zone_type) # cw/ccw
			
			tapper.update_grabbed_block(new_block)
			
			# also rotate the anchor
			tapper.anchor = Block.BlockTile.get_rotated_cell(tapper.anchor, tapper.rotation_zone_type) # cw/ccw
			
			show_preview_block(tapper.get_player(), new_block)
			return
		if is_current_placement_valid(tapper.get_player()):
			anchor_cell = _get_ship_anchor_cell(tapper, DEFAULT_TRACTOR_BEAM_OFFSET) + tapper.anchor
		else:
			return # Do nothing if placement is invalid.

		var block_to_release = tapper.grabbed_block
		
		blocks_field.spawn_block(block_to_release, anchor_cell)
		
		tapper.release_block()
		_current_preview_blocks[tapper.get_player()] = null
		#%Timer.start()
	else:
		_attempt_grabbing(tapper)

func _attempt_grabbing(ship) -> void:
	#if not %Timer.is_stopped():
		#return
		
	if ship.is_holding_block():
		return
		
	var anchor_cell = _get_nearest_valid_anchor_cell(ship)
	var grabbed_block: Block = blocks_field.get_falling_block_or_null_from_cell(anchor_cell)
	
	if grabbed_block == null:
		return
		
	# from which tile did we grab the block?
	var offset = grabbed_block.get_position() - anchor_cell
	
	blocks_field.erase_block(grabbed_block)
	for tile in grabbed_block.get_tiles():
		blocks_field.erase_cell(tile.get_cell()+grabbed_block.get_position())
	
	# offset the block to grab it from the anchor tile
	ship.grab_block(grabbed_block, offset)
	
	show_preview_block(ship.get_player(), grabbed_block)

func _update_preview() -> void:
	clear()
	for ship in get_tree().get_nodes_in_group('Ship'):
		if _current_preview_blocks[ship.get_player()] == null:
			_is_currently_valid[ship.get_player()] = false
			continue
			
		var map_anchor_cell = _get_ship_anchor_cell(ship, DEFAULT_TRACTOR_BEAM_OFFSET)

		var is_placement_valid = true
		
		var min_x = blocks_field.get_min_x()
		var max_x = blocks_field.get_max_x()
		var min_y = blocks_field.get_min_y() # For checking if you're too high
		var bottom_y = blocks_field.get_bottom_y()
		
		# check if placement would be valid here
		var block = _current_preview_blocks[ship.get_player()]
		for tile in block.get_tiles():
			var target_cell = map_anchor_cell + tile.get_cell() + ship.anchor
			
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
		
		_is_currently_valid[ship.get_player()] = is_placement_valid
		
		for tile in block.get_tiles():
			var target_cell = map_anchor_cell + tile.get_cell() + ship.anchor
			set_cell(target_cell, Block.BlockTile.Source.FALLING, tile.get_atlas_coords(Block.BlockTile.Source.FALLING) + (INVALID_PLACEMENT_TILE_DELTA if not is_placement_valid else Vector2i(0,0)))

var _feedback_lines : Dictionary[Player, Line2D] = {}

func _on_player_ready(player:Player) -> void:
	_current_preview_blocks[player] = null
	_is_currently_valid[player] = true
	_feedback_lines[player] = block_outline_scene.instantiate()
	%Feedback.add_child(_feedback_lines[player])

func _update_feedback():
	for child in %Feedback.get_children():
		child.points = PackedVector2Array()
		
	for ship in get_tree().get_nodes_in_group('Ship'):
		if not _feedback_lines.has(ship.get_player()):
			continue
			
		if ship.is_holding_block():
			var ship_cell = _get_ship_anchor_cell(ship, DEFAULT_TRACTOR_BEAM_OFFSET) + ship.anchor
			var outline = ship.grabbed_block.get_outline(tile_set.tile_size)
			
			var line = _feedback_lines[ship.get_player()]
			line.set_points(_get_wobbly_outline(outline))
			line.position.x = ship_cell.x * tile_set.tile_size.x
			line.position.y = ship_cell.y * tile_set.tile_size.y
			line.activate()
		else:
			var ship_cell = _get_nearest_valid_anchor_cell(ship)
			var outline = _get_polygon_surrounding_cell(ship_cell)
			
			var line = _feedback_lines[ship.get_player()]
			line.position = Vector2(0,0)
			line.set_points(_get_wobbly_outline(outline))
			line.deactivate()

func _get_wobbly_outline(straight_outline) -> PackedVector2Array:
	var points = Geometry2D.offset_polygon(straight_outline, 30, Geometry2D.JOIN_ROUND)[0]
	var curve = Curve2D.new()
	for p in points:
		curve.add_point(p)
	return curve.tessellate_even_length()

func _get_nearest_valid_anchor_cell(ship:Ship) -> Vector2i:
	var found = false
	var ship_cell
	for offset in [0,50,100,150,200,250,300,350,400]:
		ship_cell = _get_ship_anchor_cell(ship, offset)
		if blocks_field.get_cell_source_id(ship_cell) == Block.BlockTile.Source.FALLING:
			found = true
			break
			
	if not found:
		ship_cell = _get_ship_anchor_cell(ship, DEFAULT_TRACTOR_BEAM_OFFSET)
		
	return ship_cell
