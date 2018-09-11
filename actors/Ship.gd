# script ship
extends Area2D

var left
var right
export var velocity = Vector2(6,0)
var speed_multiplier = 1

const ROTATION_SPEED = 0.1
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
	width = get_viewport().size.x
	height = get_viewport().size.y

	Bomb = preload('res://actors/Bomb.tscn')
	Trail = preload('res://actors/Trail.tscn')

func control(delta):
	left = Input.is_action_pressed(player+'_left')
	right = Input.is_action_pressed(player+'_right')
	
	if left and not right:
		steer(-ROTATION_SPEED)
	elif right and not left:
		steer(ROTATION_SPEED)

	# dash
	#if Input.is_action_just_pressed(player+'_dash') and dash_cooldown <= 0:
	#	speed_multiplier = 3
	#	$TrailParticles.emitting = true
	#	dash_cooldown = 1
	

func _physics_process(delta):
	if not alive:
		return
	control(delta)
	
	var actual_velocity = velocity * speed_multiplier
	
	position.x += actual_velocity.x
	position.y += actual_velocity.y

	# fire
	if Input.is_action_just_pressed(player+'_fire') and fire_cooldown <= 0 and dash_cooldown <= 0:
		fire()
		fire_cooldown = 0.1
	# cooldown
	fire_cooldown -= delta
	dash_cooldown -= delta
	
	# wrap
	if position.x > width:
		position.x -= width
	elif position.x <= 0:
		position.x += width
		
	if position.y > height:
		position.y -= height
	elif position.y <= 0:
		position.y += height
		
	# trail
	if speed_multiplier > 1:
		var trail = Trail.instance()
		trail.position = position
		trail.rotation = rotation + PI/2
		get_parent().add_child(trail)
	else:
		$TrailParticles.emitting = false
		
	# dash recover
	#speed_multiplier = max(1, speed_multiplier - 0.1)
	
# Steer the ship _rad_ radians clockwise.
func steer(rad):
	velocity = velocity.rotated(rad)
	rotate(rad)
	
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
