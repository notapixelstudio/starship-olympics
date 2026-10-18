class_name FollowMovement extends FamiliarTrait
## Trails its leader (the ship or the previous familiar), holding [member follow_distance] from it.

@export var follow_distance := 300.0

func validate():
	super.validate()
	assert(not host.freeze) # steers with forces

func _physics_process(_delta: float) -> void:
	var ship := owner_ship
	if ship == null:
		return
	var offset := familiar.global_position - familiar.leader.global_position
	if offset.is_zero_approx(): # just spawned on top of it
		offset = Vector2.LEFT.rotated(ship.global_rotation)
	familiar.steer_to(familiar.leader.global_position + offset.normalized() * follow_distance)
	familiar.facing = ship.global_rotation
