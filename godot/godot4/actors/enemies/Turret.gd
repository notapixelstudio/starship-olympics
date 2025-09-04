extends Area2D
class_name Turret

@export var bullet_scene : PackedScene
@export var bullet_speed := 250.0
@export var bullet_lifetime := 10.0
@export var wait_time := 2.0 : set = set_time
@export var distance := 200.0

func set_time(v:float) -> void:
	wait_time = v
	
func start() -> void:
	%Timer.start(wait_time)

func _on_timer_timeout() -> void:
	fire()
	%Timer.start(wait_time)
	
func fire() -> void:
	var bullet = bullet_scene.instantiate()
	# TODO configure bullet size
	if bullet.has_method('set_lifetime'):
		bullet.set_lifetime(bullet_lifetime)
	bullet.linear_velocity = (Vector2.RIGHT * bullet_speed).rotated(global_rotation)
	bullet.global_position = global_position + distance*Vector2.RIGHT.rotated(global_rotation)
	#bullet.global_rotation = global_rotation
	Events.spawn_request.emit(bullet)

func get_team() -> String:
	return 'rogue'
