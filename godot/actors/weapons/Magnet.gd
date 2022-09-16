extends Area2D

@export var active = false :
	get:
		return active # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_active
var owner_ship : Ship
const ATTRACTION = 150
const REPULSION = 220

func _ready():
	owner_ship = get_parent() # WARNING

func set_active(v):
	active = v
	$Sprite2D.visible = active
	$Zone.visible = active
	$CollisionShape2D.set_disabled(not active)
	
func _process(delta):
	if active:
		for body in get_overlapping_bodies():
			if body is Rocket:
				pass
			if body is RigidBody2D:
				var direction = (body.global_position-global_position).normalized()
				var nearness = max(0, $CollisionShape2D.shape.radius - (body.global_position-global_position).length()) / $CollisionShape2D.shape.radius
				if is_good(body):
					body.apply_central_impulse(-ATTRACTION*nearness*direction)
				elif is_bad(body):
					body.apply_central_impulse(REPULSION*nearness*direction)
				
func is_good(body : RigidBody2D):
	# crown and coins
	return body.get_collision_layer_value(9) or body.get_collision_layer_value(11)
	
func is_bad(body : RigidBody2D):
	if not(body is Rocket):
		return false
		
	var bomb_owner = ECM.E(body).get('Owned').get_owned_by()
	return bomb_owner != owner_ship
	
