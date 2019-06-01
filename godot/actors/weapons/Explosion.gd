extends Area2D

class_name Explosion

var radius = 4
var shape

var t = 0
const growT = 0.4
const stillT = 0.4
const shrinkT = 0.2
const minRadius = 40
const maxRadius = 80

signal end_explosion
var explosions = ["res://assets/sounds/gameplay/explosions/SFX_Explosion_05.wav", "res://assets/sounds/gameplay/explosions/SFX_Explosion_08.wav"]

func _ready():
	shape = CircleShape2D.new()
	$CollisionShape2D.set_shape(shape)
	var index_explosion = randi() % len(explosions)
	get_node("sound").stream = load(explosions[index_explosion])
	get_node("sound").play()
	
func _physics_process(delta):
	shape.set_radius(radius)
	#$Circle.set_radius(radius+8) # the actual hitbox is smaller than the rendered circle
	$Image.scale = Vector2(radius+8, radius+8)
	
	# update the explosion's radius
	var t1 = t
	var t2 = t1 + delta
	
	t = t2
	if t1 < growT:
		radius = minRadius + sigmoid(t2, growT, maxRadius - minRadius)
	elif t1 < growT+stillT:
		pass
	elif t1 < growT+stillT+shrinkT:
		radius = maxRadius - sigmoid(t1-growT-stillT, shrinkT, maxRadius)
	else:
		# destroy the explosion
		emit_signal("end_explosion")
		call_deferred("queue_free")
		
func sigmoid(x, dt, amp):
  return x/dt*amp
