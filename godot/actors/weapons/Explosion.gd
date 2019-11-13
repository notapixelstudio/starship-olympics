extends Area2D

class_name Explosion

var radius = 4
var shape

var t = 0
const growT = 0.3
const stillT = 0.3
const shrinkT = 0.2
const minRadius = 40
const maxRadius = 80

onready var repeal_field_width = $RepealField/CollisionShape2D.get_shape().radius

signal end_explosion
var explosions = ["res://assets/audio/gameplay/explosions//SFX_Explosion_05.wav", "res://assets/audio/gameplay/explosions//SFX_Explosion_08.wav"]

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
		get_parent().call_deferred("remove_child", self)
		yield(get_tree().create_timer(1), "timeout")
		call_deferred("queue_free")
		
	for body in $RepealField.get_overlapping_bodies():
		if body is Bomb:
			var vec = body.position-position
			body.apply_central_impulse(vec.normalized()*global.sigmoid(vec.length(), repeal_field_width)*30)
		
func sigmoid(x, dt, amp):
	return x/dt*amp
	

func _on_RepealField_body_entered(body):
	if body is Bomb:
		ECM.E(body).get('Pursuer').set_target(null)
		ECM.E(body).get('Pursuer').disable()
		yield(get_tree().create_timer(1), "timeout")
		ECM.E(body).get('Pursuer').enable()
		