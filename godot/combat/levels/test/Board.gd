extends YSort

const step = 100
var matrix = {}

func _ready():
	for child in get_children():
		var x = child.position.x/step
		var y = child.position.y/step
		
		if child.size == 1:
			if not matrix.has(x):
				matrix[x] = {}
			matrix[x][y] = child
		elif child.size == 2:
			if not matrix.has(x+1):
				matrix[x+1] = {}
			matrix[x+1][y] = child
			if not matrix.has(x-1):
				matrix[x-1] = {}
			matrix[x-1][y] = child
			if not matrix.has(x):
				matrix[x] = {}
			matrix[x][y+1] = child
			if not matrix.has(x):
				matrix[x] = {}
			matrix[x][y-1] = child
		elif child.size == 3:
			if not matrix.has(x+1):
				matrix[x+1] = {}
			matrix[x+1][y+1] = child
			if not matrix.has(x-1):
				matrix[x-1] = {}
			matrix[x-1][y-1] = child
			if not matrix.has(x-1):
				matrix[x-1] = {}
			matrix[x-1][y+1] = child
			if not matrix.has(x+1):
				matrix[x+1] = {}
			matrix[x+1][y-1] = child
			
			if not matrix.has(x+2):
				matrix[x+2] = {}
			matrix[x+2][y] = child
			if not matrix.has(x-2):
				matrix[x-2] = {}
			matrix[x-2][y] = child
			if not matrix.has(x):
				matrix[x] = {}
			matrix[x][y+2] = child
			if not matrix.has(x):
				matrix[x] = {}
			matrix[x][y-2] = child
		
func get_neighbours(tile):
	var x = tile.position.x/step
	var y = tile.position.y/step
	var neighbours = []
	
	for i in range(tile.size):
		append_if_exists(x+(tile.size-i), y+(1+i), neighbours) # bottom right
		append_if_exists(x-(tile.size-i), y+(1+i), neighbours) # bottom left
		append_if_exists(x+(tile.size-i), y-(1+i), neighbours) # top right
		append_if_exists(x-(tile.size-i), y-(1+i), neighbours) # top left
	
	#if matrix.has(x+1) and matrix[x+1].has(y+1):
	#	neighbours.append(matrix[x+1][y+1])
		
	#if matrix.has(x+1) and matrix[x+1].has(y-1):
	#	neighbours.append(matrix[x+1][y-1])
		
	#if matrix.has(x-1) and matrix[x-1].has(y+1):
	#	neighbours.append(matrix[x-1][y+1])
		
	#if matrix.has(x-1) and matrix[x-1].has(y-1):
	#	neighbours.append(matrix[x-1][y-1])
		
	
	return neighbours

func append_if_exists(cx, cy, neighbours):
	if matrix.has(cx) and matrix[cx].has(cy):
		neighbours.append(matrix[cx][cy])
		
