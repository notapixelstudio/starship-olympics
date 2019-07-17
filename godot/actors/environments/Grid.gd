extends Node2D

export var grid_point_scene : PackedScene 
export var line_scene : PackedScene
export var offset: Vector2 = Vector2(100, 100)

onready var lines = $Lines

func _ready():
	initialize(Rect2(0,0, 1600, 1600))

func initialize(rect: Rect2):
	var grid = []
	var count_x = 0
	var count_y = 0
	var grid_point_original  = grid_point_scene.instance()
	for y in range(-rect.size.y/2, rect.size.y/2+offset.y, offset.y):
		grid.append([])
		count_x = 0
		for x in range(-rect.size.x/2+offset.y, rect.size.x/2, offset.x):
			
			var grid_point = grid_point_original.duplicate()
			
			grid_point.position = Vector2(x, y)
			grid_point.name = str(x) + str(y)
			add_child(grid_point)
			grid[count_y].append(grid_point)
			if count_x> 0:
				var line1 : GridLine  = line_scene.instance()
				line1.nodeA = grid[count_y][count_x-1].get_point()
				line1.nodeB = grid_point.get_point()
				lines.add_child(line1)
				
			if count_y > 0:
				var line2 : GridLine  = line_scene.instance()
				line2.nodeA = grid[count_y-1][count_x].get_point() 
				line2.nodeB = grid[count_y][count_x].get_point()
				lines.add_child(line2)
			count_x += 1
		count_y += 1