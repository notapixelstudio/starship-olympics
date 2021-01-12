tool

extends GShape

class_name GConvexPolygon

export (PoolVector2Array) var polygon setget set_polygon

func set_polygon(value):
	polygon = value
	emit_signal('changed')
	
func to_PoolVector2Array() -> PoolVector2Array:
	return .clip(polygon)
	
func to_Shape2D():
	var shape = ConvexPolygonShape2D.new()
	shape.set_point_cloud(.clip(polygon))
	return shape
	
func get_extents() -> Vector2:
	if len(polygon) <= 0:
		return Vector2()

	var minX = polygon[0].x
	var maxX = polygon[0].x
	var minY = polygon[0].y
	var maxY = polygon[0].y
	
	for p in polygon:
		minX = min(minX, p.x)
		maxX = max(maxX, p.x)
		minY = min(minY, p.y)
		maxY = max(maxY, p.y)
		
	return Vector2(maxX-minX, maxY-minY)
		
