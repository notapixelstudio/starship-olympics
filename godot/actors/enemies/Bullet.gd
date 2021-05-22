extends RigidBody2D


func _on_Bullet_body_entered(body):
	queue_free()
