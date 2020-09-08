tool

extends GShape

class_name GBeveledRect

export (int) var width = 200 setget set_width
export (int) var height = 100 setget set_height
export (int) var bevel = 20 setget set_bevel

export (int) var bevel_nw setget set_bevel_nw
export (int) var bevel_ne setget set_bevel_ne
export (int) var bevel_sw setget set_bevel_sw
export (int) var bevel_se setget set_bevel_se

func set_width(value):
	width = value
	emit_signal('changed')

func set_height(value):
	height = value
	emit_signal('changed')
	
func set_bevel(value):
	bevel = value
	bevel_nw = value
	bevel_ne = value
	bevel_sw = value
	bevel_se = value
	emit_signal('changed')
	
func set_bevel_nw(value):
	bevel_nw = value
	emit_signal('changed')
	
func set_bevel_ne(value):
	bevel_ne = value
	emit_signal('changed')
	
func set_bevel_sw(value):
	bevel_sw = value
	emit_signal('changed')
	
func set_bevel_se(value):
	bevel_se = value
	emit_signal('changed')
	
func to_PoolVector2Array():
	var points = ._apply_offset(PoolVector2Array([
		Vector2(-width/2,-height/2+bevel_nw),
		Vector2(-width/2+bevel_nw,-height/2),
		Vector2(width/2-bevel_ne,-height/2),
		Vector2(width/2,-height/2+bevel_ne),
		Vector2(width/2,height/2-bevel_se),
		Vector2(width/2-bevel_se,height/2),
		Vector2(-width/2+bevel_sw,height/2),
		Vector2(-width/2,height/2-bevel_sw)
	])) # clockwise!
	
	return .clip(points)
	
func to_Shape2D():
	var shape = ConvexPolygonShape2D.new()
	shape.set_point_cloud(to_PoolVector2Array())
	return shape
	
func to_Shape2D_offset(vec, scale=1):
	var shape = ConvexPolygonShape2D.new()
	shape.set_point_cloud(to_PoolVector2Array_offset(vec, scale))
	return shape
	
func get_extents() -> Vector2:
	return Vector2(width, height)
	
