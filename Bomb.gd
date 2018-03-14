extends KinematicBody2D

export var velocity = Vector2(10, 0)

func _physics_process(delta):
	move_and_collide(velocity)
