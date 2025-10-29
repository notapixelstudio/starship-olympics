extends Weapon

@export var bullet_scene : PackedScene
@export var bullet_speed := 250.0
@export var bullet_lifetime := 10.0
@export var offset := 120.0

func _ready() -> void:
	get_host().tap.connect(_on_tap)

func _on_tap() -> void:
	fire(get_host())
	
func fire(source):
	var bullet = bullet_scene.instantiate()
	# TODO configure bullet size
	if bullet.has_method('set_lifetime'):
		bullet.set_lifetime(bullet_lifetime)
	bullet.linear_velocity = (Vector2.RIGHT * bullet_speed).rotated(global_rotation)
	bullet.global_position = global_position + offset*Vector2.RIGHT.rotated(global_rotation)
	#bullet.global_rotation = global_rotation
	Events.spawn_request.emit(bullet)
