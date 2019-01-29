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

var arena

var velocity = Vector2(0,0)

var thrust = 2000
var steer_force = 0
var rotation_dir = 0

var charge = 0
const max_steer_force = 2500
const MAX_CHARGE = 1
const MAX_OVERCHARGE = 2
const BOMB_OFFSET = 40

var count = 0
var alive = true 

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

const bomb_scene = preload('res://actors/weapons/Bomb.tscn')
const trail_scene = preload('res://actors/weapons/Trail.tscn')

signal dead
signal stop_invincible
var invincible : bool
signal collectable_released
signal collected

func update_wraparound(screen_size):
	# width = screen_size.x
	# height = screen_size.y
	print("updated", width, " ", height)

func initialize():
	pass
	
func _ready():
	skin.add_child(species_template.ship_anim.instance())
	skin.initialize()
	
	# Invincible for the firs MAX seconds
	invincible = true
	skin.invincible()
	yield(skin, "stop_invincible")
	invincible = false

func _integrate_forces(state):
	steer_force = max_steer_force * rotation_dir
	
	#rotation = state.linear_velocity.angle()
	set_applied_force(Vector2(thrust,steer_force).rotated(rotation)*int(not charging)) # thrusters switch off when charging
	set_applied_torque(rotation_dir * 75000)
	
	# force the physics engine
	var xform = state.get_transform()
	
	# wrap (?)
	if xform.origin.x > width:
		xform.origin.x = 0
	if xform.origin.x < 0:
		xform.origin.x = width
	if xform.origin.y > height:
		xform.origin.y = 0
	if xform.origin.y < 0:
		xform.origin.y = height
	
	# clamp velocity
	#state.linear_velocity = state.linear_velocity.clamped(max_velocity)
	
	# store velocity as a readable var
	velocity = state.linear_velocity
	state.set_transform(xform)

func control(_delta):
	pass

func _process(delta):
	if not alive:
		return
		
	control(delta)
	
	# keep the crown up
	$Crown.rotation = -rotation
	

func fire():
	"""
	Fire a bomb
	"""
	var charge_impulse = 100 + 3500*min(charge, MAX_CHARGE)
	
	var bomb = bomb_scene.instance()
	bomb.origin_ship = self
	bomb.player_id = player
	bomb.apply_impulse(Vector2(0,0), Vector2(-charge_impulse,0).rotated(rotation)) # the more charge the stronger the impulse
	
	# -200 is to avoid too much acceleration when repeatedly firing bombs
	apply_impulse(Vector2(0,0), Vector2(max(0,charge_impulse-200),0).rotated(rotation)) # recoil
	
	bomb.position = position + Vector2(-BOMB_OFFSET,0).rotated(rotation) # this keeps the bomb away from the ship
	get_parent().add_child(bomb)
	
	charging = false
	$Graphics/ChargeBar.visible = false
	fire_cooldown = 0 # disabled
	

func die():
	if alive and not invincible:
		get_node("sound").play()
		alive = false
		emit_signal("dead", self.name, self.position)
		skin.play_death()
		# deactivate controls and whatnot and wait for the sound to finish
		sleeping = true
		yield(get_node("sound"), "finished")
		queue_free()
	
func set_queen(value):
	queen = value
	$Crown.visible = queen
	
func _on_Ship_area_entered(area):
	if area.has_node('DeadlyComponent') and not invincible:
		die()
	elif area.has_node("CollectableComponent"):
		assert(area is Collectable)
		collect(area)

func _on_DetectionArea_body_entered(body):
	if body.has_node('DetectorComponent'):
		body.try_acquire_target(self)
func _on_DetectionArea_body_exited(body):
	if body.has_node('DetectorComponent'):
		body.try_lose_target(self)

func _on_DetectionArea_area_entered(area):
	if area.has_node("CollectableComponent"):
		assert(area is Collectable)
		#collect(area)

func collect(area:Collectable):
	if alive:
		emit_signal("collected", self)
