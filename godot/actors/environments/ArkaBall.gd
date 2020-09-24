extends RigidBody2D

export var impulse : float = 500
var active : bool = false

func start():
	active = true

func _physics_process(delta):
	if active:
		apply_central_impulse(impulse*Vector2(1,0).rotated(linear_velocity.angle()))
	

func _on_ArkaBall_body_entered(body):
	$AudioStreamPlayer.play()
	
	if body is Paddle and body.linked_to:
		apply_central_impulse(linear_velocity.normalized()*500)
		if body.linked_to is Ship:
			modulate = body.linked_to.species.color
