extends Area2D

func _ready():
	$"%Top".polygon = $CollisionPolygon2D.polygon
	$"%Outline".points = $CollisionPolygon2D.polygon + PoolVector2Array([$CollisionPolygon2D.polygon[0]])
	
