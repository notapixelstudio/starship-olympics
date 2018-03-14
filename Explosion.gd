extends StaticBody2D

var radius = 4
var shape
const deadly = true

func _ready():
	shape = CircleShape2D.new()
	$CollisionShape2D.set_shape(shape)

func _physics_process(delta):
	shape.set_radius(radius)
	$Circle.set_radius(radius+8) # the actual hitbox is smaller than the rendered circle
	radius += 0.25