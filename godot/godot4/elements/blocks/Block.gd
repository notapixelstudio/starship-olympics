class_name Block

var _position : Vector2i
var _tiles : Array[BlockTile]

func _init(position:=Vector2i(0,0), tiles:Array[BlockTile]=[]) -> void:
	_position = position
	_tiles = tiles

func copy() -> Block:
	# deep copy the Block as well as its BlockTiles
	var new_block = Block.new(_position, _tiles)
	var new_tiles : Array[BlockTile] = []
	for tile in get_tiles():
		new_tiles.append(tile.copy())
	return new_block
	
func get_position() -> Vector2i:
	return _position
	
func get_tiles() -> Array[BlockTile]:
	return _tiles
	
func add_tile(tile:BlockTile) -> void:
	_tiles.append(tile)
	
func _to_string() -> String:
	return 'Block(' + str(get_position()) + '): ' + ','.join(_tiles)
	
func rotate() -> void:
	for tile in _tiles:
		tile.rotate()
		
func rotated() -> Block:
	var new_block = copy()
	new_block.rotate()
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
		
	func _to_string() -> String:
		return ('(' if is_liquid() else '[') + str(_color) + '@' + str(_cell.x) + ',' + str(_cell.y) + (')' if is_liquid() else ']')
		
	func is_liquid() -> bool:
		return _liquid
		
	func get_atlas_coords(source: Source) -> Vector2i:
		return Vector2i(TILEMAP_START_X + (COLORS if is_liquid() else 0) + _color, 2 if source == 0 else 0)
		
	func rotated() -> BlockTile:
		var new_tile = copy()
		new_tile.rotate()
		return new_tile
		
	func rotate() -> void:
		var swap = _cell.x
		_cell.x = _cell.y
		_cell.y = -swap
		
	static func get_random_color() -> int:
		return randi() % COLORS
