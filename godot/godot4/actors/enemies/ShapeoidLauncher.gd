extends Turret
## Launches Bloids toward the nearest ship as its shots.

@export var shapeoid_scene: PackedScene
@export var launch_speed := 700.0
@export var max_active_shapeoids := 4

@onready var _ctx := ArenaScope.get_scope(self)

func _physics_process(_delta: float) -> void:
	var target := _nearest_ship()
	if target != null:
		%Weapons.global_rotation = global_position.angle_to_point(target.global_position)

func fire() -> void:
	var target := _nearest_ship()
	if target != null and get_tree().get_nodes_in_group("Shapeoid").size() < max_active_shapeoids:
		var direction := Vector2.RIGHT.rotated(global_position.angle_to_point(target.global_position))
		var shapeoid := shapeoid_scene.instantiate() as Shapeoid
		shapeoid.global_position = global_position + direction * 180.0
		shapeoid.linear_velocity = direction * launch_speed
		_ctx.spawn_request.emit(shapeoid)

func _nearest_ship() -> Ship:
	var nearest: Ship
	var nearest_distance := INF
	for ship in get_tree().get_nodes_in_group("Ship"):
		if not ship is Ship or ship.is_queued_for_deletion():
			continue
		var distance := global_position.distance_squared_to(ship.global_position)
		if distance < nearest_distance:
			nearest = ship
			nearest_distance = distance
	return nearest
