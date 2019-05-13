tool

extends GShape

class_name GEllipse

export (int) var rx = 100 setget set_rx
export (int) var ry = 200 setget set_ry
export (float) var precision = 10 setget set_precision

func set_rx(value):
	rx = value
	emit_signal('changed')
	
func set_ry(value):
	ry = value
	emit_signal('changed')
	
func set_precision(value):
	precision = value
	emit_signal('changed')

func to_PoolVector2Array():
	var sides = int(round(2*PI*max(rx,ry)/precision))
	var angle = 2*PI/sides
	var points = []
	for i in range(sides):
		points.append(Vector2(rx*cos(i*angle),ry*sin(i*angle)))
		
	return PoolVector2Array(points) # clockwise!
	
func to_Shape2D():
	var shape = ConvexPolygonShape2D.new()
	shape.set_point_cloud(to_PoolVector2Array())
	return shape
	
func get_extents() -> Vector2:
	return Vector2(2*rx, 2*ry)
	