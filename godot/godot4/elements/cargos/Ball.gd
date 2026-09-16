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

func _on_tap_area_tap(author: Ship, strength: float) -> void:
	# kick the ball without catching it
	
	take_ownership(author)
	
	# use intended direction in addition to actual direction
	const COMPENSATION = 0.8
	var distance_vector = global_position - author.global_position
	var host_intended_forward = author.get_target_velocity().normalized()
	# no compensation if host is not moving
	if author.get_target_velocity().length_squared() < 1.0:
		host_intended_forward = distance_vector
		
	var compensated_angle = (distance_vector*(1.0-COMPENSATION)+host_intended_forward*COMPENSATION).angle()
	#var spin = 0.01*host_intended_forward.cross(distance_vector)
	## put a limit on spin
	#if abs(spin) > 0.7:
		#spin = sign(spin)*0.7
	place_and_push(global_position, Vector2(linear_velocity.length()+5500*strength,0).rotated(compensated_angle), compensated_angle, 0)#spin)
	
