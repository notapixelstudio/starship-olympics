extends Area2D

var countdown = 1

func _physics_process(delta):
	countdown -= delta
	
	if countdown <= 0:
		queue_free()