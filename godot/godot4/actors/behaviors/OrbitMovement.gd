class_name OrbitMovement extends FamiliarTrait
## Circles the ship: the familiar is frozen (kinematic), not simulated.
## It rides along with the ship and glides to its orbit slot at [member catch_up_speed], so a new or respawned ship never makes it snap.
## Each orbiter keeps [member chain_gap] behind the previous orbiter of the same player.

@export var orbit_radius := 150.0
@export var orbit_speed := 1.0
@export var chain_gap := PI / 3
## How fast (px/s) the familiar closes the gap to its orbit slot.
@export var catch_up_speed := 400.0
var angle := 0.0
var _ship: Ship
var _ship_position: Vector2

func validate():
	super.validate()
	assert(host.freeze) # placed by hand; physics would fight it

func _physics_process(delta: float) -> void:
	var ship := owner_ship
	if ship == null:
		_ship = null
		return
	var ahead := _orbiter_ahead()
	angle = ahead.angle - chain_gap if ahead != null else fposmod(angle + orbit_speed * delta, TAU)
	var slot := ship.global_position + Vector2.from_angle(angle) * orbit_radius
	var here := familiar.global_position
	if ship == _ship:
		here += ship.global_position - _ship_position # ride along, so only the gap to the slot is eased
	_ship = ship
	_ship_position = ship.global_position
	familiar.facing = ship.global_rotation
	familiar.global_transform = Transform2D(ship.global_rotation, here.move_toward(slot, catch_up_speed * delta))

## Orbiters leave the follow chain, so the one ahead is the previous orbiter on the battlefield.
func _orbiter_ahead() -> OrbitMovement:
	var ahead: OrbitMovement = null
	for node in familiar.get_parent().get_children():
		if node == familiar:
			break
		if node is Familiar and node.player == familiar.player and node.has_node(^"OrbitMovement"):
			ahead = node.get_node(^"OrbitMovement")
	return ahead
