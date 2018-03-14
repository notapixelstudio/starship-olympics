extends Area2D

var radius = 4

func _physics_process(delta):
	$CollisionShape2D.shape.set_radius(radius)
	radius += 0.25