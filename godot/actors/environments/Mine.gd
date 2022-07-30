extends RigidBody2D
class_name Mine

export var explosion_scene : PackedScene

var dive_speed := 300.0

func start() -> void:
	$AnimationPlayer.play("Idle")
	
func set_dive_speed(v: float) -> void:
	dive_speed = v
	
func dive() -> void:
	apply_central_impulse(Vector2.UP*dive_speed)

func _on_Mine_body_entered(body):
	detonate()
	
func detonate():
	var explosion = explosion_scene.instance()
	explosion.scale = Vector2(4,4)
	explosion.kilotons = 400
	explosion.global_position = global_position
	get_parent().add_child(explosion)
	queue_free()
