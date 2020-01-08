extends HBoxContainer

export var star_scene : PackedScene

func initialize(points: int, max_points: int, just_won: bool = false):
	for i in range(max_points):
		var point = star_scene.instance()
		add_child(point)
		point.won = bool(i<points)
		if just_won and i == points-1:
			point.score()
