extends Position2D

tool

export (String, 'slash/', 'backslash\\', 'line', "single", "custom") var pattern = "line"

export var element_scene: PackedScene
export var guest_star_scene: PackedScene
export (String, "center", "random") var position_guest_star = "center"

var map_pattern_distance = {
	"line": [Vector2(-300,0), Vector2(-150,0), Vector2(0,0), Vector2(150,0), Vector2(300,0)],
	"backslash": [Vector2(-300,-300),Vector2(-150, -150),Vector2(0,0), Vector2(150,150), Vector2(300,300)],
	"slash": [Vector2(-300, 300), Vector2(-150, 150), Vector2(0,0), Vector2(150, -150), Vector2(300, -300)]
	}

