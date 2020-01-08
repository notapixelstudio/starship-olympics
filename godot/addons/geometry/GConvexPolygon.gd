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
	
func get_extents() -> Vector2:
	if len(points) <= 0:
		return Vector2()

	var minX = points[0].x
	var maxX = points[0].x
	var minY = points[0].y
	var maxY = points[0].y
	
	for p in points:
		minX = min(minX, p.x)
		maxX = max(maxX, p.x)
		minY = min(minY, p.y)
		maxY = max(maxY, p.y)
		
	return Vector2(maxX-minX, maxY-minY)
		
