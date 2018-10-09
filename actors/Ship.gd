# script ship
extends RigidBody2D

var left
var right
var max_velocity = 600
var max_steer_force = 2500
var thrust = 2000

var velocity = Vector2(0,0)

var speed_multiplier = 1

var steer_force = 0
var rot = 0
var rotation_dir = 0
const ROTATION_SPEED = 100000000 # to be removed

var charge = 0
const BOMB_OFFSET = 40

var count = 0
signal died
var alive = true 

var species
var width
var height

var charging = false
var fire_cooldown = 0
var dash_cooldown = 0

export var player = 'p1'

var Bomb
var Trail
var target = null

func _ready():
	species = global.chosen_species[player]
	$Graphics/Sprite.set_texture(load('res://actors/'+species+'_ship.png'))
	connect("died", get_node('/root/Arena'), "update_score")

	Bomb = preload('res://actors/Bomb.tscn')
	Trail = preload('res://actors/Trail.tscn')
	
	# load battlefield size
	
	width = get_parent().owner.size_multiplier * OS.window_size.x
	height = OS.window_size.y * get_parent().owner.size_multiplier

func control(delta):
	rotation_dir = int(Input.is_action_pressed(player+'_right')) - int(Input.is_action_pressed(player+'_left'))
		
	# charge
	if charging:
		charge += delta
	else:
		charge = 0
	
	if not charging and Input.is_action_pressed(player+'_fire') and fire_cooldown <= 0:
		charging = true
		
	# fire
	if charging and Input.is_action_just_released(player+'_fire'):
		fire()
		charging = false
		fire_cooldown = 0.1
		
	# cooldown
	fire_cooldown -= delta
		
	# dash
	#if Input.is_action_just_pressed(player+'_dash') and dash_cooldown <= 0:
	#	speed_multiplier = 3
	#	$TrailParticles.emitting = true
	#	dash_cooldown = 1
	
func _integrate_forces(state):
	steer_force = max_steer_force * rotation_dir
	
	#rotation = state.linear_velocity.angle()
	set_applied_force(Vector2(thrust,steer_force).rotated(rotation)*int(not charging)) # thrusters switch off when charging
	set_applied_torque(rotation_dir * 30000)
	
	# force the physics engine
	var xform = state.get_transform()
	
	# wrap
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
	
	# rotate: match rotation with velocity angle
	
	#$Graphics.rotation = -rotation + state.linear_velocity.angle()
	#rotation = rot
	
	state.set_transform(xform)

func _process(delta):
	if not alive:
		return
	control(delta)
	
#func _physics_process(delta):
#	if not alive:
#		return
#	control(delta)
#	
#	var actual_velocity = velocity * speed_multiplier
#	
#	position.x += actual_velocity.x
#	position.y += actual_velocity.y
#
#	# fire
#	if Input.is_action_just_pressed(player+'_fire') and fire_cooldown <= 0 and dash_cooldown <= 0:
#		fire()
#		fire_cooldown = 0.1
#	# cooldown
#	fire_cooldown -= delta
#	dash_cooldown -= delta
#	
#	# wrap
#	if position.x > width:
#		position.x -= width
#	elif position.x <= 0:
#		position.x += width
#		
#	if position.y > height:
#		position.y -= height
#	elif position.y <= 0:
#		position.y += height
#		
#	# trail
#	if speed_multiplier > 1:
#		var trail = Trail.instance()
#		trail.position = position
#		trail.rotation = rotation + PI/2
#		get_parent().add_child(trail)
#	else:
#		$TrailParticles.emitting = false
#		
#	# dash recover
#	#speed_multiplier = max(1, speed_multiplier - 0.1)

# Fire a bomb
func fire():
	var bomb = Bomb.instance()
	bomb.origin_ship = self
	bomb.player_id = player
	bomb.apply_impulse(Vector2(0,0), Vector2(-500-1200*charge,0).rotated(rotation)) # the more charge the stronger the impulse
	
	apply_impulse(Vector2(0,0), Vector2(1200*charge,0).rotated(rotation)) # recoil
	
	bomb.position = position + Vector2(-BOMB_OFFSET,0).rotated(rotation) # this keeps the bomb away from the ship
	get_parent().add_child(bomb)
	
func die():
	if alive:
		alive = false
		emit_signal("died", player)
		queue_free()
	
func _on_Ship_area_entered(area):
	if area.has_node('DeadlyComponent'):
		die()
		

func _on_DetectionArea_body_entered(body):
	if body.has_node('DetectorComponent'):
		body.try_acquire_target(self)
		