extends Node2D

export var radius = 10
export var color = Color(1.0, 0.0, 0.0)

func _draw():
	var center = Vector2(0, 0)
	draw_circle_arc_poly(center, radius, 0, 360, color)
	
func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])
	
	for i in range(nb_points+1):
		var angle_point = angle_from + i * (angle_to - angle_from) / nb_points - 90
		points_arc.push_back(center + Vector2(cos(deg2rad(angle_point)), sin(deg2rad(angle_point))) * radius)
	draw_polygon(points_arc, colors)
	
func set_radius(value):
	radius = value
	update()
	