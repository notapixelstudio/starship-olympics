extends RigidBody2D
class_name Bullet

func _on_Bullet_body_entered(body):
	if not (body is Mirror):
		queue_free()

func _process(delta):
	$Halo.rotation = linear_velocity.angle()
	
