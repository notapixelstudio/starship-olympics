tool

extends GShape

class_name GHexagon

export (int) var radius = 100 setget set_radius

func set_radius(value):
	radius = value
	emit_signal('changed')

func to_PoolVector2Array():
	return PoolVector2Array([
		Vector2(radius*cos(0),radius*sin(0)),
		Vector2(radius*cos(PI/3),radius*sin(PI/3)),
		Vector2(radius*cos(2*PI/3),radius*sin(2*PI/3)),
		Vector2(radius*cos(PI),radius*sin(PI)),
		Vector2(radius*cos(4*PI/3),radius*sin(4*PI/3)),
		Vector2(radius*cos(5*PI/3),radius*sin(5*PI/3))
	]) # clockwise!
	
func to_Shape2D():
	var shape = ConvexPolygonShape2D.new()
	shape.set_point_cloud(to_PoolVector2Array())
	return shape
	