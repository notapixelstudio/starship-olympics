extends StaticBody2D

func _ready():
	$"%Top".polygon = $CollisionPolygon2D.polygon
	$"%Overlay".polygon = $CollisionPolygon2D.polygon
	$"%Outline".points = $CollisionPolygon2D.polygon + PoolVector2Array([$CollisionPolygon2D.polygon[0]])
	$"%Bottom".points = $"%Outline".points
	$"%OverlapArea/CollisionPolygon2D".polygon = $CollisionPolygon2D.polygon


func _on_OverlapArea_body_entered(body):
	if body.has_method('set_phasing_in_prevented'):
		body.set_phasing_in_prevented(true)
		

func _on_OverlapArea_body_exited(body):
	if body.has_method('set_phasing_in_prevented') and body.has_method('phase_in'):
		body.set_phasing_in_prevented(false)
		body.phase_in()

