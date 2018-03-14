extends StaticBody2D

var radius = 4

func _ready():
	# create a collision shape on ready, in order to have a
	different instance of it in each explosion

func _physics_process(delta):
	$CollisionShape2D.shape.set_radius(radius)
	radius += 0.25