extends RigidBody2D

class_name NewShip
## Ship base class

const max_steer_force = 2500
const MIN_CHARGE = 0.2
const MAX_CHARGE = 0.6 ## after this value, the charge impulse stop to increase
const MAX_OVERCHARGE = 1.8
const MIN_FOR_DASH = 0.2 # it was MIN_CHARGE
const MAX_TAP_CHARGE = 0.3
const CHARGE_BASE = 250
const CHARGE_MULTIPLIER = 7000
const DASH_BASE = -400
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

## constants for basic movement
const THRUST := 6500
## 9 because we enlarged the radius of the ship's collision shape by 3
const ROTATION_TORQUE := 49000*9 

# check variables for actions (e.g. dash, etc.)
var charging := true
var charging_enough := true
var charging_started_since := 0.0 ## in seconds


func move(target_velocity: Vector2, rotation_request: float ):
	var thrusting = not %ChargeManager.can_dash()
	set_constant_force(target_velocity * THRUST*int(thrusting))
	set_constant_torque(min(PI/2, rotation_request) * ROTATION_TORQUE)
	
func are_controls_enabled():
	# TODO: just yet
	return true

func charge():
	%ChargeManager.start_charging()
	
func release():
	var charge
	if %ChargeManager.can_tap():
		tap()
	if %ChargeManager.can_dash():
		dash(%ChargeManager.get_charge())
	%ChargeManager.end_charging()

func dash(charge_started_since: float) -> void:
	var dash_strength = CHARGE_BASE + CHARGE_MULTIPLIER * clamp(charge_started_since - MIN_CHARGE, 0, MAX_CHARGE)
	var recoil = max(0,DASH_BASE+dash_strength*DASH_MULTIPLIER)
	apply_central_impulse(Vector2(recoil, 0).rotated(global_rotation)) # recoil only if dashing
	
func tap():
	pass
