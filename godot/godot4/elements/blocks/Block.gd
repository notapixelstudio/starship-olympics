class_name Block

var _tiles : Array[BlockTile]

func _init() -> void:
	_tiles = []
	
func add_tile(tile:BlockTile) -> void:
	_tiles.append(tile)
	
func _to_string() -> String:
	return 'Block: ' + ','.join(_tiles)
	
func rotate() -> void:
	for tile in _tiles:
		tile.rotate()
	
enum Name {Dot, Two, L, I}

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
		
	func _to_string() -> String:
		return ('(' if is_liquid() else '[') + str(_color) + '@' + str(_cell.x) + ',' + str(_cell.y) + (')' if is_liquid() else ']')
		
	func is_liquid() -> bool:
		return _liquid
		
	func get_atlas_coords(source: Source) -> Vector2i:
		return Vector2i(TILEMAP_START_X + (COLORS if is_liquid() else 0), source)
		
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
