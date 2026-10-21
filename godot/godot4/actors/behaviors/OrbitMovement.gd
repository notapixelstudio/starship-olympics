class_name OrbitMovement extends FamiliarTrait
## Circles the ship in rings (look at shields as ref).
## each ring [member ring_gap] further out and spinning the other way. The slot is [member Familiar.slot_index].
## The familiar is kinematic: it rides along with the ship and glides to its slot at [member catch_up_speed],
## so a new or respawned ship never makes it snap.

@export var orbit_radius := 150.0
@export var ring_gap := 100.0
## Radians per second: the inner ring turns clockwise, the next one counter-clockwise, and so on.
@export var orbit_speed := 1.0
## How fast (px/s) the familiar closes the gap to get back at its slot
@export var catch_up_speed := 400.0
var _ship: Ship
var _ship_position: Vector2

func validate():
	super.validate()
	assert(host.freeze) # should be a kinematic, and not a rigidbody

func _physics_process(delta: float) -> void:
	var ship := owner_ship
	if ship == null:
		_ship = null
		return
	var spin_time: float = ship.get_node(^"FamiliarManager").spin_time
	var slot := ship.global_position + slot_offset(familiar.slot_index, spin_time)
	var here := familiar.global_position
	if ship == _ship:
		here += ship.global_position - _ship_position # ride along, so only the gap to the slot is eased
	_ship = ship
	_ship_position = ship.global_position
	familiar.facing = ship.global_rotation
	familiar.global_transform = Transform2D(ship.global_rotation, here.move_toward(slot, catch_up_speed * delta))

## Offset from the ship of orbit slot [param index] at [param time] seconds.
func slot_offset(index: int, time: float) -> Vector2:
	var ring := floori((sqrt(4.0 * index + 1.0) - 1.0) / 2.0) # rings hold 2, 4, 6...: ring r starts at index r*(r+1)
	var slots := 2 * (ring + 1)
	var spin := orbit_speed * time * (1.0 if ring % 2 == 0 else -1.0)
	return Vector2.from_angle(spin + TAU * (index - ring * (ring + 1)) / slots) * (orbit_radius + ring * ring_gap)
