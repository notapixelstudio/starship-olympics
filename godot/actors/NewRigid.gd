extends RigidBody2D

class_name NewRigid
## Ship base class
## 

const max_steer_force = 2500
const MAX_CHARGE = 0.6
const MAX_OVERCHARGE = 1.8
const MIN_CHARGE = 0.2
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

const ROTATION_TORQUE = 49000*9 # 9 because we enlarged the radius of the ship's collision shape by 3

## constants for classic movements
const THRUST := 6500

func get_brain() -> Brain:
	if not has_node('Brain'):
		return null
	return ($Brain as Brain)

func set_brain(new_brain: Brain) -> void:
	var old_brain = get_brain()
	if old_brain != null:
		old_brain.disconnect('charge', Callable(self, '_on_charge_requested'))
		old_brain.disconnect('release', Callable(self, '_on_release_requested'))
		old_brain.free()
	new_brain.set_name('Brain')
	new_brain.connect('charge', Callable(self, '_on_charge_requested'))
	new_brain.connect('release', Callable(self, '_on_release_requested'))
	add_child(new_brain)

