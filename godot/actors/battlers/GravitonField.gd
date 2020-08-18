extends Area2D

export var multiplier : float = 1.0
export var timeout : float = 0.0
export var enabled : bool = false setget set_enabled

var ship : Ship

func _enter_tree():
	yield(get_tree().create_timer(timeout), "timeout")
	if timeout:
		enabled = false
		
		
func get_influence_radius():
	return $CollisionShape2D.shape.radius
	
func get_gravity():
	if not enabled:
		return 0
	return gravity * multiplier

func set_enabled(v):
	enabled = v
	refresh()
	
func _ready():
	ship = get_parent() as Ship
	refresh()
	
func refresh():
	$CollisionShape2D.disabled = not enabled
	
func repeal(amount):
	
	for body in get_overlapping_bodies():
		if body == ship or not(body is RigidBody2D):
			continue
			
		var difference = body.global_position-ship.position
		body.apply_impulse(Vector2(0,0), difference.normalized()*100*amount/difference.length())
		
