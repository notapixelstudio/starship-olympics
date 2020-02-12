extends HBoxContainer

export var star_scene : PackedScene
const OFFSET = 128 

func initialize(points: int, max_points: int, just_won: bool = false):
	for i in range(max_points):
		var point = star_scene.instance()
		add_child(point)
		point.position.x += i*OFFSET
		point.position.y = 80
		point.floating_star(i)
		point.won = bool(i<points)
		if just_won and i == points-1:
			point.score()
