extends Cargo
class_name Ball

@export var impulse_unrest : float = 0.0
var rest : bool = true

var _owner_ship : Ship = null

@onready var tracked = %Tracked

func unrest() -> void:
	rest = false
	
func take_ownership(ship: Ship) -> void:
	_owner_ship = ship
	
func get_owner_ship() -> Ship:
	if not _owner_ship or not is_instance_valid(_owner_ship) or _owner_ship.is_queued_for_deletion():
		return null
		
	return _owner_ship

func _physics_process(delta):
	if not rest:
		apply_central_impulse(impulse_unrest*Vector2(1,0).rotated(linear_velocity.angle()))

func _integrate_forces(state):
	tracked.tick()
