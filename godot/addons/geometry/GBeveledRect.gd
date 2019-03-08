tool

extends GShape

class_name GBeveledRect

export (int) var width = 200 setget set_width
export (int) var height = 100 setget set_height
export (int) var bevel = 20 setget set_bevel

func set_width(value):
	width = value
	emit_signal('changed')

func set_height(value):
	height = value
	emit_signal('changed')
	
func set_bevel(value):
	bevel = value
	emit_signal('changed')

func to_PoolVector2Array():
	return PoolVector2Array([
		Vector2(-width/2,-height/2+bevel),
		Vector2(-width/2+bevel,-height/2),
		Vector2(width/2-bevel,-height/2),
		Vector2(width/2,-height/2+bevel),
		Vector2(width/2,height/2-bevel),
		Vector2(width/2-bevel,height/2),
		Vector2(-width/2+bevel,height/2),
		Vector2(-width/2,height/2-bevel)
	]) # clockwise!
	
func to_Shape2D():
	var shape = ConvexPolygonShape2D.new()
	shape.set_point_cloud(to_PoolVector2Array())
	return shape
	