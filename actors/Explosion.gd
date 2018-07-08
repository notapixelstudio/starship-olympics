extends Area2D

var radius = 4
var shape

var t = 0
const growT = 0.4
const stillT = 1
const shrinkT = 0.2
const maxRadius = 60

func _ready():
	shape = CircleShape2D.new()
	$CollisionShape2D.set_shape(shape)

func _physics_process(delta):
	shape.set_radius(radius)
	$Circle.set_radius(radius+8) # the actual hitbox is smaller than the rendered circle
	
	# update the explosion's radius
	var t1 = t
	var t2 = t1 + delta
	
	t = t2
	if t1 < growT:
		radius = sigmoid(t2, growT, maxRadius)
	elif t1 < growT+stillT:
		pass
	elif t1 < growT+stillT+shrinkT:
		radius = maxRadius - sigmoid(t1-growT-stillT, shrinkT, maxRadius)
	else:
		# destroy the explosion
		queue_free()
		
func sigmoid(x, dt, amp):
  return x/dt*amp


func _on_Explosion_body_entered(body):
	if body.has_method('on_explosion_entered'):
		body.on_explosion_entered()
		
