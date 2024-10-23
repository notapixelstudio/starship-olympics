extends Node2D

@export var star_scene : PackedScene
const OFFSET = 128 

func update(points: int, new_points: int, max_points: int):
	# empty container
	for child in get_children():
		child.queue_free()
	
	for i in range(max_points):
		var point = star_scene.instantiate()
		add_child(point)
		point.position.x = 100 + i*OFFSET - max_points*OFFSET/2.0
		point.position.y = 68
		point.floating_star(i)
		if i < points:
			point.won = true
			#point.perfect = points[i].perfect
			if i > points - new_points-1:
				point.score()
		else:
			point.won = false
			point.perfect = false
