tool
extends RigidBody2D
"""
Node for the RigidBody and Ship physics
it will get as export variable the battle template (containing the species values)
and its keyboard control
"""
class_name Ship

export (String) var controls = "kb1"
export (Resource) var species_template
export var absolute_controls : bool= true

var arena

var velocity = Vector2(0,0)
var target_velocity = Vector2(0,0)
var thrust = 2000
var steer_force = 0
var rotation_dir = 0

var charge = 0
const max_steer_force = 2500
const MAX_CHARGE = 1
const MAX_OVERCHARGE = 2
const BOMB_OFFSET = 40

const THRESHOLD_DIR = 0.3

var count = 0
var alive = true
var stunned = false
var stun_countdown = 0

var species
var screen_size = Vector2()
var width = 0
var height = 0

var charging = false
var fire_cooldown = 0
var dash_cooldown = 0

var queen:bool = false

onready var player = name
onready var skin = $Graphics

const trail_scene = preload('res://actors/weapons/Trail.tscn')

signal dead
signal stop_invincible
var invincible : bool

signal collected

func initialize():
	pass

func _enter_tree():
	charging = false
	charge = 0
	alive = true
	# Invincible for the firs MAX seconds
	invincible = true
	sleeping=true
	if skin:
		skin.invincible()
	yield(get_tree().create_timer(0.5), "timeout")
	sleeping=false
	yield(skin, "stop_invincible")
	invincible = false
	
func _ready():
	skin.add_child(species_template.ship_anim.instance())
	skin.initialize()
	skin.invincible()
	
static func magnitude(a:Vector2):
	return sqrt(a.x*a.x+a.y*a.y)
	
var last_velocity = Vector2()
func _integrate_forces(state):
	
	set_applied_force(Vector2())
	steer_force = max_steer_force * rotation_dir
	
	if not absolute_controls:
		add_central_force(Vector2(thrust,steer_force).rotated(rotation)*int(not charging and not stunned)) # thrusters switch off when charging
		# rotation = atan2(target_velocity.y, target_velocity.x)
	else:
		#rotation = state.linear_velocity.angle()
		#apply_impulse(Vector2(),target_velocity*thrust)	
		add_central_force(target_velocity*thrust*int(not charging and not stunned))
		
	set_applied_torque(rotation_dir * 75000)
	
	# force the physics engine
	var xform = state.get_transform()
	
	# wrap (?)

	#if xform.origin.x > width:
	#	xform.origin.x = 0
	#if xform.origin.x < 0:
	#	xform.origin.x = width
	#if xform.origin.y > height:
	#	xform.origin.y = 0
	#if xform.origin.y < 0:
	#	xform.origin.y = height

	# clamp velocity
	#state.linear_velocity = state.linear_velocity.clamped(max_velocity)
	
	# store velocity as a readable var
	velocity = state.linear_velocity
	state.set_transform(xform)

func control(_delta):
	pass

signal detection
func _process(delta):
	if not alive:
		return
	
	control(delta)
	
	stun_countdown -= delta
	if stun_countdown <= 0:
		unstun()
		
	for body in $DetectionArea.get_overlapping_bodies():
		emit_signal("detection", body, self)
		
func fire():
	"""
	Fire a bomb
	"""
	var charge_impulse = 100 + 4000*min(charge, MAX_CHARGE)
	
	# -300 is to avoid too much acceleration when repeatedly firing bombs
	apply_impulse(Vector2(0,0), Vector2(max(0,charge_impulse-300),0).rotated(rotation)) # recoil
	
	arena.spawn_bomb(
	  position + Vector2(-BOMB_OFFSET,0).rotated(rotation),
	  Vector2(-charge_impulse,0).rotated(rotation),
	  self
	)
	
	charging = false
	$Graphics/ChargeBar.visible = false
	fire_cooldown = 0 # disabled
	

func die():
	if alive and not invincible:
		alive = false
		# skin.play_death()
		# deactivate controls and whatnot and wait for the sound to finish
		yield(get_tree(), "idle_frame")
		emit_signal("dead", self)
		
func stun():
	stunned = true
	stun_countdown = 0.3
	
func unstun():
	stunned = false
	stun_countdown = 0
	
signal near_area_entered
func _on_NearArea_area_entered(area):
	emit_signal("near_area_entered", area, self)

func is_alive():
	return alive

static func find_side(a: Vector2, b: Vector2, check: Vector2) -> int:
	"""
	Given two points a, b will return the side check is on.
 	@return integer code for which side of the line ab c is on.  
	1 means left turn, -1 means right turn.  Returns
 	0 if all three are on a line (THRESHOLD will adjust the wiggle in movements)
	"""
	var possible_dirs : Array = [-1,1]
	var cross = (b.x - a.x)*(check.y-a.y) - (b.y - a.y)*(check.x-a.x)
	if check == -b:
		cross = possible_dirs[randi()%len(possible_dirs)]

	if cross > -THRESHOLD_DIR and cross < THRESHOLD_DIR :
		if sign(check.y)==sign(b.y) or sign(b.x) == sign(check.x) :
			return 0
	
	return int(sign(cross))
