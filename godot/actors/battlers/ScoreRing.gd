extends Node2D

const hole = PI/3
const steps = 200
const start = PI/2 + hole/2

export var radius = 200
export (float, 1.0) var fraction = 0.0 setget set_fraction
export var fill_color = Color(1,1,1,1)
export var empty_color = Color(1,1,1,1)
export var fill_thickness = 20
export var empty_thickness = 1

func _ready():
	$LineEmpty.width = empty_thickness
	$LineFull.width = fill_thickness
	
	refresh()
	
func set_fraction(value):
	fraction = value
	
	if is_inside_tree():
		refresh()
	
func refresh():
	$LineEmpty.points = create_points(fraction, false)
	$LineFull.points = create_points(fraction, true)
	
func create_points(fract, fill):
	var pts = []
	var alpha = start
	for i in range(steps+1):
		var over = alpha - start > (2*PI - hole) * fract
		if fill and not over or not fill and over:
			pts.append(Vector2(radius*cos(alpha),radius*sin(alpha)))
		
		alpha += (2*PI - hole) / steps
		
	return PoolVector2Array(pts)
	