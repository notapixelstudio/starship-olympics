extends HBoxContainer

export var star_scene : PackedScene
const OFFSET = 128 

func initialize(points, max_points: int, just_won: bool = false):
	for i in range(max_points):
		var point = star_scene.instance()
		add_child(point)
		point.position.x = 100 + i*OFFSET
		point.position.y = 72
		point.floating_star(i)
		if i < len(points):
			point.won = true
			point.perfect = points[i].perfect
			if just_won and i == len(points)-1:
				point.score()
		else:
			point.won = false
			point.perfect = false
