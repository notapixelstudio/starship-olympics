extends Node2D

@export var size := Vector2(200, 200)
@export var cell_size := Vector2.ONE * 100

@export var grid_point_scene : PackedScene
@export var grid_anchor_scene : PackedScene
@export var grid_segment_scene : PackedScene

var v_cells : int
var h_cells : int
var matrix = []

func _ready() -> void:
	v_cells = ceil(size.y/cell_size.y) + 1
	h_cells = ceil(size.x/cell_size.x) + 1
	
	# create the grid points and anchors
	for x in h_cells:
		matrix.append([])
		for y in v_cells:
			var grid_point = grid_point_scene.instantiate()
			grid_point.position = Vector2(cell_size.x*x-size.x/2, cell_size.y*y-size.y/2)
			add_child(grid_point)
			matrix[x].append(grid_point)

			var grid_anchor = grid_anchor_scene.instantiate()
			grid_anchor.position = Vector2(cell_size.x*x-size.x/2, cell_size.y*y-size.y/2)
			add_child(grid_anchor)

			# connect the grid anchors to the grid points
			create_grid_segment(grid_point, grid_anchor, 0)
	
	## create the grid segments between each neighbor grid point
	#for x in h_cells:
		#for y in v_cells:
			## just connect the right and bottom neighbors
			#var neighbors = []
			#if x < h_cells-1:
				#create_grid_segment(matrix[x][y], matrix[x+1][y], cell_size.x)
			#if y < v_cells-1:
				#create_grid_segment(matrix[x][y], matrix[x][y+1], cell_size.y)
			
				
func create_grid_segment(node_a, node_b, length):
	var grid_segment = grid_segment_scene.instantiate()
	grid_segment.set_node_a(node_a.get_path())
	grid_segment.set_node_b(node_b.get_path())
	grid_segment.length = length
	grid_segment.rest_length = length
	add_child(grid_segment)
