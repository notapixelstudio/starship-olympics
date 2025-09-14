extends TileMapLayer
class_name BlocksTileMap

@export var spawn_every_ticks : int = 5
@export var spawn_coords : Array[Vector2i] = [Vector2i(0,-5)]

const FALLING_BLOCKS_SOURCE_ID := 0
const PLACED_BLOCKS_SOURCE_ID := 1

const PIECES := [
	[Vector2i(0,0)], # .
	[Vector2i(0,0),Vector2i(1,0)], # -
	[Vector2i(-1,0),Vector2i(0,0),Vector2i(1,0)], # _
	[Vector2i(0,-1),Vector2i(0,0),Vector2i(1,0)], # L
]

var _buffer : TileMapLayer

var _tick := 0
var _next_piece_id := 0
var _piece_ids : Array[int] = []

func _ready() -> void:
	_buffer = TileMapLayer.new()
	_buffer.tile_set = tile_set

func get_all_falling_blocks_cells() -> Array[Vector2i]:
	return get_used_cells_by_id(FALLING_BLOCKS_SOURCE_ID)
	
func get_all_pieces() -> Array[Dictionary]:
	var pieces_index = {}
	for cell in get_all_falling_blocks_cells():
		var piece_id = get_cell_tile_data(cell).get_custom_data('piece_id')
		if not pieces_index.has(piece_id):
			pieces_index[piece_id] = []
		pieces_index[piece_id].append(cell)
		
	var pieces : Array[Dictionary] = []
	for id in pieces_index:
		var cells = pieces_index[id]
		pieces.append({
			'id': id,
			'cells': cells
		})
		
	return pieces
	
func get_all_placed_blocks_cells() -> Array[Vector2i]:
	return get_used_cells_by_id(PLACED_BLOCKS_SOURCE_ID)

func tick() -> void:
	# copy all placed blocks on the buffer
	for cell in get_all_placed_blocks_cells():
		_buffer.set_cell(cell, PLACED_BLOCKS_SOURCE_ID, get_cell_atlas_coords(cell))
	
	for piece in get_all_pieces():
		var stop := false
		for cell in piece['cells']:
			var next_cell = cell+Vector2i(0,1)
			if get_cell_source_id(next_cell) == PLACED_BLOCKS_SOURCE_ID:
				# the whole piece must stop
				stop = true
				break
				
		
		if stop:
			# actually stop the piece
			for cell in piece['cells']:
				_buffer.set_cell(cell, PLACED_BLOCKS_SOURCE_ID, get_cell_atlas_coords(cell)+Vector2i(0,-2)) # FIXME please
		else:
			# move the piece
			for cell in piece['cells']:
				_buffer.set_cell(cell+Vector2i(0,1), FALLING_BLOCKS_SOURCE_ID, get_cell_atlas_coords(cell))
	
	if _tick % spawn_every_ticks == 0:
		spawn_new_piece()
	
	clear()
	set_tile_map_data_from_array(_buffer.get_tile_map_data_as_array())
	_buffer.clear()
	
	_tick += 1

func spawn_new_piece() -> void:
	var random_piece_i = randi_range(0,len(PIECES)-1)
	var piece_to_spawn = PIECES[random_piece_i]
	var from_where = spawn_coords.pick_random()
	
	for cell in piece_to_spawn:
		# TBD check if space is available (game over?)
		_buffer.set_cell(cell+from_where, FALLING_BLOCKS_SOURCE_ID, Vector2i(random_piece_i,2))
		_buffer.get_cell_tile_data(cell+from_where).set_custom_data('piece_id', _next_piece_id)
		
		
	_piece_ids.append(_next_piece_id)
	_next_piece_id += 1
