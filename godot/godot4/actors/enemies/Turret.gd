extends Node2D

@export var bullet_scene : PackedScene
@export var wait_time := 2.0 : set = set_time
@export var distance := 200.0
@export var rotation_speed := PI/8

func set_time(v:float) -> void:
	wait_time = v
	
func _ready() -> void:
	set_physics_process(false)
	
func start() -> void:
	set_physics_process(true)
	%Timer.start(wait_time)

func _on_timer_timeout() -> void:
	fire()
	%Timer.start(wait_time)
	
func fire() -> void:
	var bullet = bullet_scene.instantiate()
	# TODO configure bullet speed, size, lifetime
	bullet.linear_velocity = (Vector2.RIGHT * 300).rotated(global_rotation)
	bullet.global_position = global_position + distance*Vector2.RIGHT.rotated(global_rotation)
	#bullet.global_rotation = global_rotation
	get_parent().add_child(bullet)

func _physics_process(delta: float) -> void:
	rotation += delta * rotation_speed
