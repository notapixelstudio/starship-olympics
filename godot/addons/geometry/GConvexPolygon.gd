@tool

extends GShape

class_name GConvexPolygon

@export (PackedVector2Array) var polygon :
	get:
		return polygon # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_polygon

func set_polygon(value):
	polygon = value
	emit_signal('changed')
	
func to_PoolVector2Array() -> PackedVector2Array:
	return super.clip(polygon)
	
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
		
