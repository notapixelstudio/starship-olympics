class_name FollowMovement extends FamiliarTrait
## Flies in formation behind the ship: down the follow chain familiars alternate right and left,
## each pair [member row_gap] further back. Slots are in the ship's frame, so they turn with it.

## First right slot in the ship's frame (x forward, y right); the left one mirrors it.
@export var slot_offset := Vector2(-200, 120)
@export var row_gap := 160.0
## Every other row sits this much further out, so each side zig-zags instead of lining up.
@export var stagger := 40.0
## Seconds of drift (relative to the ship) to brake ahead of, so the familiar settles in its slot instead of bouncing around it.
@export var braking := 0.3

func validate():
	super.validate()
	assert(not host.freeze) # steers with forces

func _physics_process(_delta: float) -> void:
	var ship := owner_ship
	if ship == null:
		return
	var index := _chain_index()
	var row := floori(index / 2.0)
	var slot := slot_offset + Vector2(-row_gap * row, stagger * (row % 2))
	if index % 2 == 1:
		slot.y = -slot.y
	var drift := familiar.linear_velocity - ship.linear_velocity
	familiar.steer_to(ship.global_position + slot.rotated(ship.global_rotation) - drift * braking)
	familiar.facing = ship.global_rotation

## Place in the follow chain: familiars between this one and the ship.
func _chain_index() -> int:
	var index := 0
	var node := familiar.leader
	while node is Familiar:
		index += 1
		node = node.leader
	return index
