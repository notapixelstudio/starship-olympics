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
	return PoolVector2Array([Vector2(-width/2,-height/2),Vector2(width/2,-height/2),Vector2(width/2,height/2),Vector2(-width/2,height/2)]) # clockwise!
	
func to_Shape2D():
	var shape = RectangleShape2D.new()
	shape.set_extents(Vector2(width/2, height/2))
	return shape
	