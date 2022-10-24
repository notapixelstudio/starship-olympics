extends Area2D

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
			polygon_top.append(point+Vector2(0,-100))
			
	polygon_top.invert()
	
	$"%CanopyShade".polygon = PoolVector2Array(polygon_bottom + polygon_top)


func _on_Tree_body_entered(body):
	shake()
	
func _on_Tree_body_exited(body):
	shake()
	
func shake():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Shake")
	
