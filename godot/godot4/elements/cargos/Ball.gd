extends Cargo
class_name Ball

@export var impulse_unrest : float = 0.0
var rest : bool = true

@export var kick_impulse_base := 500.0
@export var kick_impulse_strength_multiplier := 5500.0

var _owner_ship : Ship = null

func unrest() -> void:
	rest = false
	
func take_ownership(ship: Ship) -> void:
	_owner_ship = ship
	
func get_owner_ship() -> Ship:
	if not _owner_ship or not is_instance_valid(_owner_ship) or _owner_ship.is_queued_for_deletion():
		return null
		
	return _owner_ship
	
func push(impulse: float) -> void:
	apply_central_impulse(impulse*linear_velocity.normalized())
	
func _physics_process(delta):
	if not rest:
		apply_central_impulse(impulse_unrest*Vector2(1,0).rotated(linear_velocity.angle()))

func _integrate_forces(state):
	tracked.tick()

func _on_tap_area_tap(author: Ship, strength: float) -> void:
	volley(author, strength)
	
func volley(author: Ship, strength: float) -> void:
	take_ownership(author)
	unrest()
	
	## use intended direction in addition to actual direction
	#const COMPENSATION = 0.8
	#var distance_vector = global_position - author.global_position
	#var host_intended_forward = author.get_target_velocity().normalized()
	## no compensation if host is not moving
	#if author.get_target_velocity().length_squared() < 1.0:
		#host_intended_forward = distance_vector
		#
	#var compensated_angle = (distance_vector*(1.0-COMPENSATION)+host_intended_forward*COMPENSATION).angle()
	##var spin = 0.01*host_intended_forward.cross(distance_vector)
	### put a limit on spin
	##if abs(spin) > 0.7:
		##spin = sign(spin)*0.7
	#place_and_push(global_position, Vector2(linear_velocity.length()+5500*strength,0).rotated(compensated_angle), compensated_angle, 0)#spin)
	
	
	# use intended direction in addition to actual direction
	var host_forward = Vector2.RIGHT.rotated(author.global_rotation)
	var host_intended_forward = author.get_target_velocity().normalized()
	var distance_versor = (global_position - author.global_position).normalized()
	# no intent compensation if host is not moving
	if author.get_target_velocity().length_squared() < 1.0:
		host_intended_forward = host_forward
		
	var compensated_angle = (0.1*host_forward+0.8*host_intended_forward+0.1*distance_versor).angle()
	var spin = -0.1*(host_intended_forward.cross(host_forward))
	
	place_and_push(global_position, author.linear_velocity + Vector2(max(0, kick_impulse_base+kick_impulse_strength_multiplier*strength),0).rotated(compensated_angle), compensated_angle, spin)
