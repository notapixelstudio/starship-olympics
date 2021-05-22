extends Area2D

var velocity = Vector2(100,0)

func _on_Bullet_body_entered(body):
	if not ECM.E(body).has('Phasing'):
		queue_free()

func _physics_process(delta):
	position += velocity*delta
	
