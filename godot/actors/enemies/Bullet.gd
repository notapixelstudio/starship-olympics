extends RigidBody2D
class_name Bullet

func _on_Bullet_body_entered(body):
	if not (body is Mirror) and not (body is MirrorWall):
		destroy()

func _process(delta):
	$Halo.rotation = linear_velocity.angle()
	
func dissolve():
	pass
	
func destroy():
	dissolve()
	queue_free()
