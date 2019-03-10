tool

extends GShape

class_name GSegment

export (Vector2) var a setget set_a
export (Vector2) var b setget set_b

func set_a(value):
	a = value
	emit_signal('changed')
	
func set_b(value):
	b = value
	emit_signal('changed')
	
func to_PoolVector2Array() -> PoolVector2Array:
	return PoolVector2Array([a, b])
	
func to_Shape2D():
	var shape = SegmentShape2D.new()
	shape.a = a
	shape.b = b
	return shape
	