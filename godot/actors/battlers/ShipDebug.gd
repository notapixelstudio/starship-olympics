extends Node2D

# Debug node for movement and vectors

@export var enabled :bool = false

# GDquest colors
var colors = {
	WHITE = Color(1.0, 1.0, 1.0),
	YELLOW = Color(1.0, .757, .027),
	GREEN = Color(.282, .757, .255),
	BLUE = Color(.098, .463, .824),
	PINK = Color(.914, .118, .388)
}

const WIDTH = 8

const MUL = 0.5

var parent = null

func _ready():
	parent = get_parent()


func _draw():
	if not enabled:
		return
	
	# draw direction vector
	draw_vector(Vector2.RIGHT.rotated(parent.global_rotation)*400, Vector2(), colors['PINK'])
	
	# draw linear velocity
	draw_vector(parent.linear_velocity, Vector2(), colors['YELLOW'])
	
	# draw drift vector
	draw_vector(parent.drift, Vector2(), colors['WHITE'] if parent.drift.length() > 400 else colors['BLUE'])
	
	#draw_vector(parent.target_pos*0.5, Vector2(), colors['PINK'])
	
	# draw_vector(parent.last_target_pos, Vector2(), colors['WHITE'])
	#var i = 0
	#for r in parent.hit_pos:
	#	draw_vector(r, Vector2(), colors['WHITE'].darkened(0.3))
	#	i += 1
	#draw_vector(parent.velocity.normalized()*5, Vector2(), colors['YELLOW'])


func draw_vector(vector, offset, _color):
	if vector == Vector2() or not vector:
		return
	draw_line(offset * MUL, vector * MUL, _color, WIDTH)
	var dir = vector.normalized()
	draw_triangle_equilateral(vector * MUL, dir, 30, _color)
	draw_circle(offset, 6, _color)


func draw_triangle_equilateral(center=Vector2(), direction=Vector2(), radius=50, _color=colors.WHITE):
	var point_1 = center + direction * radius
	var point_2 = center + direction.rotated(2*PI/3) * radius
	var point_3 = center + direction.rotated(4*PI/3) * radius

	var points = [point_1, point_2, point_3]
	draw_polygon(points, ([_color]))


func _process(_delta):
	if not enabled:
		return
		
	rotation = -parent.rotation
	if parent and parent.cpu :
		$Label.text = parent.behaviour_mode
