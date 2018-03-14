extends StaticBody2D

var radius

func _physics_process(delta):
	$CollisionShape2D.shape.set_radius(radius)
	radius += 0.25