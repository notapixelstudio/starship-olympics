extends KinematicBody2D

export var velocity = Vector2(10, 0)

var Explosion

func _ready():
	Explosion = preload('res://Explosion.tscn')

func _physics_process(delta):
	var collision = move_and_collide(velocity)
	if collision != null:
		detonate()
		
func detonate():
	queue_free()
	var explosion = Explosion.instance()
	get_node('/root/Arena').add_child(explosion)
	explosion.position = position
	