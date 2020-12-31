extends YSort

const step = 100
var matrix = {}

func _ready():
	for child in get_children():
		var x = child.position.x/step
		var y = child.position.y/step
		if not matrix.has(x):
			matrix[x] = {}
		matrix[x][y] = child
		

func get_neighbours(tile):
	var x = tile.position.x/step
	var y = tile.position.y/step
	var neighbours = []
	
	if matrix.has(x+1) and matrix[x+1].has(y+1):
		neighbours.append(matrix[x+1][y+1])
		
	if matrix.has(x+1) and matrix[x+1].has(y-1):
		neighbours.append(matrix[x+1][y-1])
		
	if matrix.has(x-1) and matrix[x-1].has(y+1):
		neighbours.append(matrix[x-1][y+1])
		
	if matrix.has(x-1) and matrix[x-1].has(y-1):
		neighbours.append(matrix[x-1][y-1])
		
	
	return neighbours
