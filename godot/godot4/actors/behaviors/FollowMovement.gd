class_name FollowMovement extends FamiliarTrait
## Flies in formation behind the ship: by [member Familiar.slot_index] familiars alternate right and left,
## each pair [member row_gap] further back.

## First right slot in the ship's frame (x forward, y right); the left one mirrors it.
@export var slot_offset := Vector2(-200, 120)
@export var row_gap := 160.0
## Every other row sits this much further out
@export var stagger := 40.0
## drift into braking, this avoid bouncing around the ship
@export var braking := 0.3

func validate():
	super.validate()
	assert(not host.freeze) # steers with forces

func _physics_process(_delta: float) -> void:
	var ship := owner_ship
	if ship == null:
		return
	var drift := familiar.linear_velocity - ship.linear_velocity
	familiar.steer_to(ship.global_position + local_slot(familiar.slot_index).rotated(ship.global_rotation) - drift * braking)
	familiar.facing = ship.global_rotation

## Formation slot [param index] for the ship. even indexes on the right, odd ones mirrored on the left.
func local_slot(index: int) -> Vector2:
	var row := floori(index / 2.0)
	var slot := slot_offset + Vector2(-row_gap * row, stagger * (row % 2))
	if index % 2 == 1:
		slot.y = -slot.y
	return slot
