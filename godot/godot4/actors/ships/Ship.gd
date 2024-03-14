extends RigidBody2D

class_name Ship
## Ship base class

@export var dash_ring_scene : PackedScene

const max_steer_force = 2500
const MIN_CHARGE = 0.2
const MAX_OVERCHARGE = 1.8
const MIN_FOR_DASH = 0.2 # it was MIN_CHARGE
const MAX_TAP_CHARGE = 0.3
const CHARGE_BASE = 250
const CHARGE_MULTIPLIER = 7000
const DASH_HANDICAP = 400
const DASH_MULTIPLIER = 2.6 # was 2.7, decreased to lessen the chance of tunneling
const BOMB_OFFSET = 50
const BOMB_BOOST = 1600
const BALL_BOOST = 2300
const BOMB_CHARGE_MULTIPLIER = 1.65
const BALL_CHARGE_MULTIPLIER = 2.2
const BULLET_BOOST = 1600
const BULLET_CHARGE_MULTIPLIER = 1.65
const BUBBLE_BOOST = 1200
const FIRE_COOLDOWN = 0.03
const OUTSIDE_COUNTUP = 3.0
const ARKABALL_OFFSET = 200
const ARKABALL_MULTIPLIER = 1.5
const MAGNETIC_OFFSET = 200
const MAGNETIC_MULTIPLIER = 1.5
const ON_ICE_MAX_THRUST = 2200
const ON_ICE_MAX_DASH = 2500
const ON_ICE_CHARGE_BRAKE = 0.99
const MIN_DRIFT := 400.0
const MIN_DIVING_TIME := 0.05

signal touch(sth: CollisionObject2D)
signal hurt_by(sth: CollisionObject2D)

## constants for basic movement
const THRUST := 6500
## 9 because we enlarged the radius of the ship's collision shape by 3
var rotation_torque := 49000*9 

# check variables for actions (e.g. dash, etc.)
var charging := true
var charging_enough := true
var charging_started_since := 0.0 ## in seconds

var target_velocity := Vector2(0, 0)
var rotation_request := 0.0

func set_target_velocity(v: Vector2) -> void:
	target_velocity = v
	set_constant_force(target_velocity * THRUST*int(is_thrusting()))
	
func set_rotation_request(v: float) -> void:
	rotation_request = v
	set_constant_torque(min(PI/2, rotation_request) * rotation_torque)
	
func are_controls_enabled():
	# TODO: just yet
	return true
	
## returns whether the ship is using their thrusters, i.e., it's attempting to reach a nonzero
## target velocity and it's not charging enough to dash
func is_thrusting() -> bool:
	return not %ChargeManager.can_dash() and target_velocity.length() > 0.1

func charge():
	%ChargeManager.start_charging()
	
func release():
	if %ChargeManager.can_tap():
		tap()
	if %ChargeManager.can_dash():
		dash(%ChargeManager.get_charge())
	%ChargeManager.end_charging()

func dash(charge: float) -> void:
	var dash_strength = CHARGE_BASE + CHARGE_MULTIPLIER * clamp(charge - MIN_CHARGE, 0, %ChargeManager.MAX_CHARGE)
	var recoil = max(0,-DASH_HANDICAP+dash_strength*DASH_MULTIPLIER)
	apply_central_impulse(Vector2(recoil, 0).rotated(global_rotation)) # recoil only if dashing
	
	_drop_dash_ring_effect()
	
func tap():
	pass


func _on_charge_manager_charged_too_much_for_tap():
	pass # Replace with function body.


func _on_charge_manager_charged_enough_to_dash():
	pass # Replace with function body.


func _on_charge_manager_reset():
	pass # Replace with function body.

func graphics_enlarge():
	pass

func _drop_dash_ring_effect() -> void:
	var dash_ring = dash_ring_scene.instantiate()
	get_parent().add_child(dash_ring)
	dash_ring.global_position = global_position
	dash_ring.global_rotation = global_rotation
	dash_ring.scale = Vector2(1,1) * %ChargeManager.get_charge_normalized()


func _on_touch_area_area_entered(area):
	_on_touch_area_entered(area)

func _on_touch_area_body_entered(body):
	_on_touch_area_entered(body)
	
func _on_touch_area_entered(sth):
	touch.emit(sth)
	Events.ship_touch_sth.emit(self, sth)
	
	if sth.has_method('touched_by'):
		sth.touched_by(self)

func _on_hurt_area_area_entered(area):
	_on_hurt_area_entered(area)
	
func _on_hurt_area_body_entered(body):
	_on_hurt_area_entered(body)
	
func _on_hurt_area_entered(sth):
	hurt_by.emit(sth)
	Events.sth_hurt_ship.emit(sth, self)