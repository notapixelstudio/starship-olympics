tool

extends GShape

class_name GConvexPolygon

export (PoolVector2Array) var points setget set_points

func set_points(value):
	points = value
	emit_signal('changed')
	
func to_PoolVector2Array() -> PoolVector2Array:
	return points
	
func to_Shape2D():
	var shape = ConvexPolygonShape2D.new()
	shape.set_point_cloud(points)
	return shape
	