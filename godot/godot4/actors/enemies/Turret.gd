extends Node2D

@export var bullet_scene : PackedScene

func _on_timer_timeout() -> void:
	fire()
	
func fire() -> void:
	var bullet = bullet_scene.instantiate()
	# TODO configure bullet speed, size, lifetime
	bullet.linear_velocity = (Vector2.RIGHT * 300).rotated(global_rotation)
	bullet.global_position = global_position
	#bullet.global_rotation = global_rotation
	get_parent().add_child(bullet)

func _physics_process(delta: float) -> void:
	rotation += delta
