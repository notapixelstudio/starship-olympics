tool
extends RigidBody2D
"""
Node for the RigidBody and Ship physics
it will get as export variable the battle template (containing the species values)
and its keyboard control
"""
class_name Ship

export (String) var controls = "kb1"
export (Resource) var battle_template


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

onready var player = name
onready var skin = $Graphics

const bomb_scene = preload('res://actors/weapons/Bomb.tscn')
const trail_scene = preload('res://actors/weapons/Trail.tscn')
const puzzle_scene = preload("res://actors/battlers/collectables/Collectable.tscn")

var puzzle 
signal dead
signal collectable_released
signal you_can_go
signal collected

func update_wraparound(screen_size):
	# width = screen_size.x
	# height = screen_size.y
	print("updated", width, " ", height)

func initialize():
	pass
	
func _ready():
	species = "another"
	puzzle = puzzle_scene.instance()
	# let's connect this when creating the instance
	# connect("died", get_node('/root/Arena'), "update_score")
	skin.add_child(battle_template.anim.instance())
	skin.initialize()
	# load battlefield size
	

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

func control(delta):
	pass

func _process(delta):
	if not alive:
		return
	control(delta)


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
	
func releasePuzzle():
	# Add to Battlefield
	# using call_deferred in order to avoid the warning (and if the object isn't ready yet
	# TODO: yield("dead completed") and then adding and initialize the puzzle)
	get_parent().call_deferred("add_child", puzzle)
	puzzle.call_deferred("initialize", battle_template.puzzle_anim, self)
	emit_signal("collectable_released")
	yield(self, "collectable_released")

func die():
	if alive:
		get_node("sound").play()
		alive = false
		emit_signal("dead", self.name)
		skin.play_death()
		# deactivate controls and whatnot and wait for the sound to finish
		sleeping = true
		yield(get_node("sound"), "finished")
		releasePuzzle()
		queue_free()
	
func _on_Ship_area_entered(area):
	if area.has_node('DeadlyComponent'):
		die()
		
func _on_DetectionArea_body_entered(body):
	if body.has_node('DetectorComponent'):
		body.try_acquire_target(self)
		
func _on_DetectionArea_body_exited(body):
	if body.has_node('DetectorComponent'):
		body.try_lose_target(self)

func _on_DetectionArea_area_entered(area):
	if area.has_node("CollectableComponent"):
		assert(area is Collectable)
		collect(area)
		
func collect(area:Collectable):
	emit_signal("collected", self.name, area.player_id)
	area.queue_free()
	