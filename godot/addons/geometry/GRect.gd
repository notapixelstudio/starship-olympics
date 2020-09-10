tool

extends GShape

class_name GRect

export (int) var width = 100 setget set_width
export (int) var height = 100 setget set_height

func set_width(value):
	width = value
	emit_signal('changed')

func set_height(value):
	height = value
	emit_signal('changed')

func to_PoolVector2Array():
	return .clip([Vector2(-width/2,-height/2),Vector2(width/2,-height/2),Vector2(width/2,height/2),Vector2(-width/2,height/2)]) # clockwise!
	
func to_Shape2D():
	var shape = ConvexPolygonShape2D.new()
	shape.set_point_cloud(to_PoolVector2Array())
	return shape
	
func get_extents() -> Vector2:
	return Vector2(width, height)
	
