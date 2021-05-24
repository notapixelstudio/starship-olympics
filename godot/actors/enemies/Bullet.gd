extends RigidBody2D


func _on_Bullet_body_entered(body):
	if not (body is Mirror):
		queue_free()
