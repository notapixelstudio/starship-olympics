extends StaticBody2D

func _process(delta):
	$Polygon2D.material.set_shader_param('c1', $RigidBody2D.position)
	$Polygon2D.material.set_shader_param('c2', $RigidBody2D2.position)
	$Polygon2D.material.set_shader_param('c3', $RigidBody2D3.position)
	
func wobble(center, intensity):
	# FIXME this should be improved with a more satisfying physics wobbling (sinc?)
	var impulse = max(50, intensity*0.2)
	$RigidBody2D.apply_central_impulse(Vector2(-impulse,0))
	$RigidBody2D2.apply_central_impulse(Vector2(-impulse,0))
	$RigidBody2D3.apply_central_impulse(Vector2(-impulse,0))
	
