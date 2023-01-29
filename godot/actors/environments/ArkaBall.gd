extends RigidBody2D
class_name ArkaBall

var Ripple = load('res://actors/weapons/Ripple.tscn')

export var impulse : float = 80
var active : bool = false

var ship # Ship
var pickable = false

func start():
	active = true

func _physics_process(delta):
	if active:
		apply_central_impulse(impulse*Vector2(1,0).rotated(linear_velocity.angle()))
	

func _on_ArkaBall_body_entered(body):
	AudioManager.play($AudioStreamPlayer)
	
	apply_central_impulse(linear_velocity.normalized()*2000)
	
	var ripple = Ripple.instance()
	ripple.position = position
	ripple.scale = Vector2(2,2)
	get_parent().call_deferred("add_child", ripple)
		
	#if body is Paddle and body.linked_to:
	#	apply_central_impulse(linear_velocity.normalized()*500)
	#	if body.linked_to is Ship:
	#		modulate = body.linked_to.species.color
	if body is WallGoal and ship != null and body.get_player().species != ship.get_species():
		body.do_goal(ship.get_player(), position)
	elif body is Brick:
		body.break(null)
	elif body is Marble:
		body.conquered_by(ship)
	
func get_strategy(ship, distance, game_mode):
	return {"seek": 10}
	
	
func set_ship(v):
	ship = v
	modulate = ship.get_color()
	
func get_ship():
	return ship
	
func is_pickable() -> bool:
	return pickable

func _on_Timer_timeout():
	pickable = true
