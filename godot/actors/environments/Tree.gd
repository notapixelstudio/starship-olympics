extends Area2D

export var height := 1

func _ready():
	$"%HidingSpot/CollisionPolygon2D".polygon = $CollisionPolygon2D.polygon
	$"%Canopy".polygon = $CollisionPolygon2D.polygon
	$"%Shadow".polygon = $CollisionPolygon2D.polygon
	$"%Leaves".points = $CollisionPolygon2D.polygon + PoolVector2Array([$CollisionPolygon2D.polygon[0]])
	
	# compute the shade of the canopy
	var polygon_bottom = []
	var polygon_top = []
	for point in $CollisionPolygon2D.polygon:
		if point.y >= 0:
			polygon_bottom.append(point)
			polygon_top.append(point+Vector2(0,-100*height))
			
	polygon_top.invert()
	
	$"%CanopyShade".polygon = PoolVector2Array(polygon_bottom + polygon_top)
	
	modulate.r = 1 + randf() * 5
	modulate.g = 0.8 + randf() * 1
	modulate.b = 0.5 + randf() * 1
