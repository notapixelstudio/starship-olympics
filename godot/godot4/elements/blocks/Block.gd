class_name Block

var _position : Vector2i
var _tiles : Array[BlockTile]

func _init(position:=Vector2i(0,0), tiles:Array[BlockTile]=[]) -> void:
	_position = position
	_tiles = tiles

func copy() -> Block:
	# deep copy the Block as well as its BlockTiles
	var new_tiles_array: Array[BlockTile] = []
	
	for tile in _tiles:
		new_tiles_array.append(tile.copy())
	return Block.new(_position, new_tiles_array)
	
func get_position() -> Vector2i:
	return _position
	
func get_tiles() -> Array[BlockTile]:
	return _tiles
	
func add_tile(tile:BlockTile) -> void:
	_tiles.append(tile)
	
func _to_string() -> String:
	return 'Block(' + str(get_position()) + '): ' + ','.join(_tiles)
	
func rotate(cw) -> void:
	for tile in _tiles:
		tile.rotate(cw)
		
func rotated(cw) -> Block:
	var new_block = copy()
	new_block.rotate(cw)
	return new_block
	
func move_to(p:Vector2i) -> void:
	_position = p
	
func move_by(delta:Vector2i) -> void:
	move_to(get_position()+delta)
	
func has_cell(cell:Vector2i) -> bool:
	for tile in get_tiles():
		if tile.get_cell() + get_position() == cell:
			return true
	return false
	
func get_outline(cell_size:=Vector2(1,1)) -> PackedVector2Array:
	var points = []
	for tile in get_tiles():
		points += Array(tile.get_outline(cell_size))
		
	# TODO: merge_polygons
	points = Geometry2D.convex_hull(points)
	return points
	
enum Name {Dot, Two, L, I}#, Ooo}

static func create(name:Name, liquid:=false) -> Block:
	var b = Block.new()
	var single_color = BlockTile.get_random_color()
	
	var cells : Array[Vector2i]
	match name:
		Name.Dot:
			cells = [Vector2i(0,0)]
		Name.Two:
			cells = [Vector2i(0,0),Vector2i(1,0)]
		Name.L:
			cells = [Vector2i(0,-1),Vector2i(0,0),Vector2i(1,0)]
		Name.I:
			cells = [Vector2i(-1,0),Vector2i(0,0),Vector2i(1,0)]
		#Name.Ooo:
			#cells = [Vector2i(-4,0),Vector2i(-3,0),Vector2i(-2,0),Vector2i(-1,0),Vector2i(0,0),Vector2i(1,0),Vector2i(2,0),Vector2i(3,0)]
		
	for cell in cells:
		b.add_tile(BlockTile.new(cell, (BlockTile.get_random_color() if liquid else single_color), liquid))
		
	return b

static func create_random() -> Block:
	var liquid := randf() > 0.5
	var name : Name = randi() % len(Name)
	return create(name, liquid)

class BlockTile:
	const TILEMAP_START_X := 20
	const COLORS := 5
	enum Source {
		FALLING = 0,
		PLACED = 1
	}
	
	var _cell : Vector2i
	var _color : int
	var _liquid : bool
	
	func _init(cell, color, liquid:=false) -> void:
		_cell = cell
		_color = color
		_liquid = liquid
		
	func copy() -> BlockTile:
		return BlockTile.new(_cell, _color, _liquid)
		
	func get_cell() -> Vector2i:
		return _cell
	
	func set_cell(new_cell: Vector2i) -> void:
		_cell = new_cell
		
	func _to_string() -> String:
		return ('(' if is_liquid() else '[') + str(_color) + '@' + str(_cell.x) + ',' + str(_cell.y) + (')' if is_liquid() else ']')
		
	func is_liquid() -> bool:
		return _liquid
		
	func get_atlas_coords(source: Source) -> Vector2i:
		return Vector2i(TILEMAP_START_X + (COLORS if is_liquid() else 0) + _color, 2 if source == 0 else 0)
		
	func rotated(cw) -> BlockTile:
		var new_tile = copy()
		new_tile.rotate(cw)
		return new_tile
		
	func rotate(cw) -> void:
		_cell = get_rotated_cell(_cell, cw)
		
	func get_outline(cell_size:=Vector2(1,1)) -> PackedVector2Array:
		return PackedVector2Array([
			Vector2(_cell.x*cell_size.x,_cell.y*cell_size.y),
			Vector2((_cell.x+1)*cell_size.x,_cell.y*cell_size.y),
			Vector2((_cell.x+1)*cell_size.x,(_cell.y+1)*cell_size.y),
			Vector2(_cell.x*cell_size.x,(_cell.y+1)*cell_size.y),
		])
		
	static func get_random_color() -> int:
		return randi() % COLORS
	
	static func get_color_from_atlas_coords(atlas_coords: Vector2i) -> int:
		"Returns the color index (0 to COLORS-1) from the atlas coordinates."
		var x_coord = atlas_coords.x
		
		# The atlas is structured with solid blocks first, then liquid blocks.
		# We check if the x-coordinate is in the range of liquid blocks.
		var liquid_offset = TILEMAP_START_X + COLORS
		if x_coord >= liquid_offset:
			# If it is, we subtract the starting offset for liquid blocks to get the color.
			return x_coord - liquid_offset
		else:
			# Otherwise, it's a solid block. We subtract the starting offset for solid blocks.
			return x_coord - TILEMAP_START_X
	
	static func get_rotated_cell(cell:Vector2i, cw) -> Vector2i:
		if cw:
			return Vector2i(-cell.y, cell.x)
		else:
			return Vector2i(cell.y, -cell.x)
