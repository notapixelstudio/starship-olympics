extends Node2D
"""
Debug node for movement and vectors
"""

# GDquest colors
var colors = {
	WHITE = Color(1.0, 1.0, 1.0),
	YELLOW = Color(1.0, .757, .027),
	GREEN = Color(.282, .757, .255),
	BLUE = Color(.098, .463, .824),
	PINK = Color(.914, .118, .388)
}

const WIDTH = 2

const MUL = 20

var parent = null


func _ready():
	parent = get_parent()
	update()


func _draw():
	draw_vector(parent.target_velocity*5, Vector2(), colors['GREEN'])
	draw_vector(parent.front * 5, Vector2(), colors['PINK'])
	#draw_vector(parent.velocity.normalized()*5, Vector2(), colors['YELLOW'])


func draw_vector(vector, offset, _color):
	if vector == Vector2():
		return
	draw_line(offset * MUL, vector * MUL, _color, WIDTH)
	var dir = vector.normalized()
	draw_triangle_equilateral(vector * MUL, dir, 10, _color)
	draw_circle(offset, 6, _color)


func draw_triangle_equilateral(center=Vector2(), direction=Vector2(), radius=50, _color=colors.WHITE):
	var point_1 = center + direction * radius
	var point_2 = center + direction.rotated(2*PI/3) * radius
	var point_3 = center + direction.rotated(4*PI/3) * radius

	var points = [point_1, point_2, point_3]
	draw_polygon(points, ([_color]))


func _process(delta):
	update()
