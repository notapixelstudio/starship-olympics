@tool

extends GShape

class_name GSegment

@export (Vector2) var a :
	get:
		return a # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_a
@export (Vector2) var b :
	get:
		return b # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_b

func set_a(value):
	a = value
	emit_signal('changed')
	
func set_b(value):
	b = value
	emit_signal('changed')
	
func to_PoolVector2Array() -> PackedVector2Array:
	return PackedVector2Array([a, b])
	
func to_Shape2D():
	var shape = SegmentShape2D.new()
	shape.a = a
	shape.b = b
	return shape
	
func get_extents() -> Vector2:
	var width = max(a.x, b.x) - min(a.x, b.x)
	var height = max(a.y, b.y) - min(a.y, b.y)
	return Vector2(width, height)
	
