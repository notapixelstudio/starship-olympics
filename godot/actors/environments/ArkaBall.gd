extends RigidBody2D
class_name ArkaBall

var Ripple = load('res://actors/weapons/Ripple.tscn')

export var impulse : float = 300
var active : bool = false

var player : InfoPlayer

func start():
	active = true

func _physics_process(delta):
	if active:
		apply_central_impulse(impulse*Vector2(1,0).rotated(linear_velocity.angle()))
	

func _on_ArkaBall_body_entered(body):
	$AudioStreamPlayer.play()
	
	apply_central_impulse(linear_velocity.normalized()*4000)
	
	var ripple = Ripple.instance()
	ripple.position = position
	ripple.scale = Vector2(2,2)
	get_parent().call_deferred("add_child", ripple)
		
	#if body is Paddle and body.linked_to:
	#	apply_central_impulse(linear_velocity.normalized()*500)
	#	if body.linked_to is Ship:
	#		modulate = body.linked_to.species.color
	if body is WallGoal and player != null and body.get_player().species != player.species:
		body.do_goal(player, position)
	
func get_strategy(ship, distance, game_mode):
	return {"seek": 10}
	
	
func set_player(v : InfoPlayer):
	player = v
	modulate = player.species.color
	
func get_player():
	return player
	
