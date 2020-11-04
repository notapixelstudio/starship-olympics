extends Node2D

export var height = global.isometric_offset
var h = height
var shape : GShape setget set_shape
var points = []
var closed_points = []
export var color = Color(1,1,1,1)
export var thickness = 15
export var opaque_tint = Color(0,0,0,0.8)

func set_shape(v):
	shape = v
	points = shape.to_PoolVector2Array()
	closed_points = shape.to_closed_PoolVector2Array()
	update()

func _draw():
	for i in range(len(closed_points)-1):
		var p0 = closed_points[i]
		var p1 = closed_points[i+1]
		draw_colored_polygon(PoolVector2Array([p0,p1,p1+h,p0+h]), Color(color.r, color.g, color.b, 0.4))
		draw_line(p0, p1, color, thickness)
		draw_line(p1, p1+h, color, thickness)
		draw_line(p1+h, p0+h, color, thickness)
		draw_line(p0+h, p0, color, thickness)
	draw_colored_polygon(points, opaque_tint)
	
func _process(delta):
	h = height.rotated(-global_rotation)
	update()
	
