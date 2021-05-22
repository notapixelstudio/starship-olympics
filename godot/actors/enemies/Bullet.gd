extends Area2D

var velocity = Vector2(100,0)

func _on_Bullet_body_entered(body):
	queue_free()

func _physics_process(delta):
	position += velocity*delta
	
