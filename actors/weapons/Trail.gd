extends Area2D

var countdown = 1

func _physics_process(delta):
	countdown -= delta
	
	if $CollisionShape2D.is_disabled() and countdown <= 0.9:
		$CollisionShape2D.set_disabled(false)
	elif countdown <= 0:
		queue_free()

func _on_Trail_body_entered(body):
	if body.has_method('on_trail_entered'):
		body.on_trail_entered()
		