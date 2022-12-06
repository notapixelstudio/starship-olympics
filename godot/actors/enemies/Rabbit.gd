extends RigidBody2D

export var min_jump_speed := 2000.0
export var delta_jump_speed := 6000.0

func start():
	queue_jump()

func jump():
	apply_central_impulse(Vector2.UP.rotated(randf()*TAU)*(min_jump_speed+randf()*delta_jump_speed))

func queue_jump():
	yield(get_tree().create_timer(1+2*randf()), "timeout")
	$AnimationPlayer.play("Jump")
	yield($AnimationPlayer, "animation_finished")
	queue_jump()
