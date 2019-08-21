tool
extends RigidBody2D
"""
Node for the RigidBody and Ship physics
it will get as export variable the battle template (containing the species values)
and its keyboard control
"""
class_name Ship

export var debug_enabled = false
export (String) var controls = "kb1"
export (Resource) var species_template
export var absolute_controls : bool= true

var arena
var cpu = false
var velocity = Vector2(0,0)
var target_velocity = Vector2(0,0)
var steer_force = 0
var rotation_dir = 0

var THRUST = 2000

var charge = 0
const max_steer_force = 2500
const MAX_CHARGE = 0.6
const MIN_DASHING_CHARGE = 0.1
const MAX_OVERCHARGE = 1.3
const CHARGE_BASE = 200
const ANTI_RECOIL_OFFSET = 260
const CHARGE_MULTIPLIER = 4500
const BOMB_OFFSET = 40
const BOMB_BOOST = 200

const THRESHOLD_DIR = 0.3
var info_player
var count = 0
var alive = true
var stunned = false
var stun_countdown = 0

var species: String
var screen_size = Vector2()
var width = 0
var height = 0

var charging = false
var fire_cooldown = 0
var dash_cooldown = 0

var teleport_to = null

onready var player = name
onready var skin = $Graphics

const dead_ship_scene = preload("res://actors/battlers/DeadShip.tscn")

var dead_ship_instance

signal dead
signal stop_invincible
var invincible : bool

var entity : Entity

func initialize():
	pass

signal spawned
var bombs_enabled : bool = true setget set_bombs_enabled

func set_bombs_enabled(value: bool):
	bombs_enabled = value


func _enter_tree():
	charging = false
	charge = 0
	alive = true
	emit_signal('spawned', self)
	# Invincible for the firs MAX seconds
	invincible = true
	sleeping=true
	if skin:
		skin.invincible()
	sleeping=false
	yield(get_tree().create_timer(0.1), "timeout")
	yield(skin, "stop_invincible")
	invincible = false
	
func _ready():
	dead_ship_instance = dead_ship_scene.instance()
	dead_ship_instance.ship = self
	skin.ship_texture = (species_template as SpeciesTemplate).ship
	skin.invincible()
	entity = ECM.E(self)
	species = species_template.species_name
	
	entity.get('Conqueror').set_species(self)
	
static func magnitude(a:Vector2):
	return sqrt(a.x*a.x+a.y*a.y)
	
var last_velocity = Vector2()
func _integrate_forces(state):
	entity.get('Thrusters').apply_damp(self)
	
	set_applied_force(Vector2())
	steer_force = max_steer_force * rotation_dir
	
	if not absolute_controls:
		add_central_force(Vector2(THRUST, steer_force).rotated(rotation)*int(not charging and not stunned)) # thrusters switch off when charging
		# rotation = atan2(target_velocity.y, target_velocity.x)
	else:
		#rotation = state.linear_velocity.angle()
		#apply_impulse(Vector2(),target_velocity*THRUST)	
		add_central_force(target_velocity*THRUST*int(not charging and not stunned))
		
	if entity.has('Flowing'):
		apply_impulse(Vector2(), entity.get_node('Flowing').get_flow().get_flow_vector(position))
		
	set_applied_torque(rotation_dir * 75000)
	
	# force the physics engine
	var xform = state.get_transform()
	
	# teleport
	if entity.could_have('Teleportable') and entity.get('Teleportable').is_teleporting():
		emit_signal('spawned', self)
		xform.origin = entity.get('Teleportable').get_destination()
		entity.get('Teleportable').teleport_done()
		
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
func _physics_process(delta):
	if not alive:
		return
	
	control(delta)
	
	stun_countdown -= delta
	if stun_countdown <= 0:
		unstun()
		
	dash_cooldown -= delta
	if dash_cooldown <= 0:
		entity.get('Dashing').disable()
		
	for body in $DetectionArea.get_overlapping_bodies():
		emit_signal("detection", body, self)
		
func charge():
	charging = true
	$Graphics/ChargeBar.visible = true
	#$GravitonField.enabled = true
	
func fire():
	"""
	Fire a bomb
	"""
	var charge_impulse = CHARGE_BASE + CHARGE_MULTIPLIER * min(charge, MAX_CHARGE)
	
	# - (CHARGE_BASE + ANTI_RECOIL_OFFSET) is to avoid too much acceleration when repeatedly firing bombs
	apply_impulse(Vector2(0,0), Vector2(max(0, charge_impulse - (CHARGE_BASE + ANTI_RECOIL_OFFSET)), 0).rotated(rotation)) # recoil
	
	if bombs_enabled:
		arena.spawn_bomb(
			position + Vector2(-BOMB_OFFSET,0).rotated(rotation),
			Vector2(-(charge_impulse+BOMB_BOOST),0).rotated(rotation),
			self
		)
	
	# repeal
	$GravitonField.repeal(charge_impulse)
	#$GravitonField.enabled = false
	
	charging = false
	$Graphics/ChargeBar.visible = false
	fire_cooldown = 0 # disabled
	
	if charge > MIN_DASHING_CHARGE:
		entity.get('Dashing').enable()
		dash_cooldown = 0.2
		

func die(killer : Ship):
	if alive and not invincible:
		alive = false
		# skin.play_death()
		# deactivate controls and whatnot and wait for the sound to finish
		yield(get_tree(), "idle_frame")
		emit_signal("dead", self, killer)
		
func stun():
	stunned = true
	stun_countdown = 0.3
	
func unstun():
	stunned = false
	stun_countdown = 0
	
signal near_area_entered
func _on_NearArea_area_entered(area):
	emit_signal("near_area_entered", area, self)
func _on_NearArea_body_entered(body):
	emit_signal("near_area_entered", body, self)
	
signal near_area_exited
func _on_NearArea_area_exited(area):
	emit_signal("near_area_exited", area, self)
func _on_NearArea_body_exited(body):
	emit_signal("near_area_exited", body, self)
	
func is_alive():
	return alive

func update_score(species_template, score, pos):
	$PlayerInfo.update_score(score)
	
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
