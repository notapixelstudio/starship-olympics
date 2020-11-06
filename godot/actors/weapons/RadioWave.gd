extends Line2D

func _on_GCircle_changed():
	points = $GCircle.to_closed_PoolVector2Array()
	$Area2D/CollisionShape2D.shape = $GCircle.to_concave_Shape2D()
