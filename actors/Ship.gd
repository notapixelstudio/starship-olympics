# script ship
extends RigidBody2D

var left
var right
var max_velocity = 500
var max_steer_force = 2500
var thrust = 200

var speed_multiplier = 1

var steer_force = 0
var rot = 0
var rotation_dir = 0
const ROTATION_SPEED = 100000000

var count = 0
signal died
var alive = true 

var species
var width
var height

var fire_cooldown = 0
var dash_cooldown = 0

export var player = 'p1'

var Bomb
var Trail
var target = null

func _ready():
	species = global.chosen_species[player]
	$Sprite.set_texture(load('res://actors/'+species+'_ship.png'))
	connect("died", get_node('/root/Arena'), "update_score")

	Bomb = preload('res://actors/Bomb.tscn')
	Trail = preload('res://actors/Trail.tscn')
	
	# load battlefield size
	width = get_node('/root/Arena').width
	height = get_node('/root/Arena').height

func control(delta):
	rotation_dir = 0
	
	if Input.is_action_pressed(player+'_left'):
		rotation_dir -= 1
		
	if Input.is_action_pressed(player+'_right'):
		rotation_dir += 1
		
	# dash
	#if Input.is_action_just_pressed(player+'_dash') and dash_cooldown <= 0:
	#	speed_multiplier = 3
	#	$TrailParticles.emitting = true
	#	dash_cooldown = 1
	
func _integrate_forces(state):
	#steer_force = max_steer_force * rotation_dir
	
	set_applied_force(Vector2(thrust,0).rotated(rotation))
	set_applied_torque(rotation_dir * 25000)
	
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
	
	# rotate: match rotation with velocity angle
	#rot = state.linear_velocity.angle()
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
	bomb.player_id = player
	bomb.velocity = bomb.velocity.rotated(rotation-PI)
	bomb.acceleration = bomb.acceleration.rotated(rotation-PI)
	
	bomb.position = position + bomb.velocity*6 # this moves the bomb away from the ship
	get_parent().add_child(bomb)
	
func die():
	if alive:
		alive = false
		emit_signal("died", player)
		queue_free()
	
func _on_Ship_area_entered(area):
	if area.has_node('DeadlyComponent'):
		die()
