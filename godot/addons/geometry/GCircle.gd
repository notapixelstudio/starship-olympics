tool

extends GShape

class_name GCircle

export (int) var radius = 100 setget set_radius
export (float) var precision = 100 setget set_precision

func set_radius(value):
	radius = value
	emit_signal('changed')
	
func set_precision(value):
	precision = value
	emit_signal('changed')

func to_PoolVector2Array():
	var sides = int(round(2*PI*radius/precision))
	var angle = 2*PI/sides
	var points = []
	for i in range(sides):
		points.append(Vector2(radius*cos(i*angle),radius*sin(i*angle)))
		
	return .clip(points) # clockwise!
	
func to_Shape2D():
	var shape = ConvexPolygonShape2D.new()
	shape.set_point_cloud(to_PoolVector2Array())
	return shape
	
func get_extents() -> Vector2:
	return Vector2(2*radius, 2*radius)
	
