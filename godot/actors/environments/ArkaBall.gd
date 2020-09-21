extends RigidBody2D

export var impulse : float = 30.0
var active : bool = false

func start():
	active = true

func _physics_process(delta):
	if active:
		apply_central_impulse(impulse*Vector2(1,0).rotated(linear_velocity.angle()))
	

func _on_ArkaBall_body_entered(body):
	if body is Paddle:
		apply_central_impulse(linear_velocity.normalized()*2000)
	
