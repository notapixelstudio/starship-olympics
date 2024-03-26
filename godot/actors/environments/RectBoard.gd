extends Node2D

@export var tile_scene : PackedScene
@export var tile_rotation_degrees := 45
@export var tile_size := 2.0
@export var tile_step := 142.0
@export var rows := 10
@export var cols := 10
@export var huge_central_tile_probability := 0.0
@export var huge_tile_size := 5.0
@export var huge_tile_points := 50
@export var medium_tile_max_amount := 0


var _cells := {}

func _ready():
	# center the board
	position = Vector2(-tile_step*tile_size*(cols-1)/2.0, -tile_step*tile_size*(rows-1)/2.0)
	
	# prepare small tiles
	for i in range(rows):
		for j in range(cols):
			# skip tiles overlapping the central one, if any
			#if place_central_tile and j > cols/2-huge_tile_size/2 and j < cols/2+huge_tile_size/2 and i > rows/2-huge_tile_size/2 and i < rows/2+huge_tile_size/2:
			#	continue
			
			var tile = tile_scene.instantiate()
			tile.rotation_degrees = tile_rotation_degrees
			tile.set_size(tile_size)
			tile.position = Vector2(j*tile_step*tile_size, i*tile_step*tile_size)
			_cells[Vector2(i,j)] = tile
	
	# replace tiles with huge central tile
	var odd_board := rows%2 != 0 and cols%2 != 0
	if odd_board and randf() <= huge_central_tile_probability:
		var central_tile = tile_scene.instantiate()
		central_tile.rotation_degrees = tile_rotation_degrees
		central_tile.set_size(huge_tile_size)
		central_tile.points = huge_tile_points
		place_big_tile(Vector2(cols/2,rows/2), central_tile)
		
	# randomize placement of medium tiles
	var medium_tiles_amount = ceil(randf()*randf()*medium_tile_max_amount)
	for i in range(medium_tiles_amount):
		var size = 2+randi()%2
		var medium_tile = tile_scene.instantiate()
		medium_tile.rotation_degrees = tile_rotation_degrees
		medium_tile.set_size(size)
		medium_tile.points = size*10
		# do not go too near the edge
		place_big_tile(Vector2(size/2+randi()%(cols-size),size/2+randi()%(rows-size)), medium_tile)
		
	# add remaining tiles to the tree
	var already_added := {}
	for i in range(rows):
		for j in range(cols):
			if not already_added.has(_cells[Vector2(i,j)]):
				add_child(_cells[Vector2(i,j)])
				already_added[_cells[Vector2(i,j)]] = true

func place_big_tile(center, big_tile):
	# bail if we touch an already placed big tile
	for i in range(center.y-big_tile.size/2+1, center.y+big_tile.size/2+1):
		for j in range(center.x-big_tile.size/2+1, center.x+big_tile.size/2+1):
			if _cells.has(Vector2(i,j)) and _cells[Vector2(i,j)].size > 1:
				return
	
	# replace small tiles with the big one
	for i in range(center.y-big_tile.size/2+1, center.y+big_tile.size/2+1):
		for j in range(center.x-big_tile.size/2+1, center.x+big_tile.size/2+1):
			if _cells.has(Vector2(i,j)):
				_cells[Vector2(i,j)].queue_free()
			_cells[Vector2(i,j)] = big_tile
			
	var x = center.x if int(big_tile.size)%2 != 0 else center.x+0.5
	var y = center.y if int(big_tile.size)%2 != 0 else center.y+0.5
	big_tile.position = Vector2(x*tile_step*tile_size, y*tile_step*tile_size)
