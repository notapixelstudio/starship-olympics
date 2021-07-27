extends Area2D

class_name MapLocation

func get_id() -> String:
	return self.name

func get_global_polygon() -> PoolVector2Array:
	var points = []
	for p in $CollisionPolygon2D.polygon:
		points.append(to_global(p))
	return PoolVector2Array(points)
	
