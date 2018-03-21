# script ship
extends KinematicBody2D

var left
var right
export var velocity = Vector2(6,0)
var speed_multiplier = 1

const ROTATION_SPEED = 0.1
var count = 0
signal died 

var width
var height

export var color = Color(0,0,0)
export var player = 'p1'

var Bomb

func _ready():
	$Sprite.set_texture(load('res://'+player+'_ship.png'))
	connect("died", get_node('/root/Arena'), "update_score")
	width = get_viewport().size.x
	height = get_viewport().size.y
	
	Bomb = load('res://Bomb.tscn')

func _physics_process(delta):
	left = Input.is_action_pressed(player+'_left')
	right = Input.is_action_pressed(player+'_right')
	
	if left and not right:
		steer(-ROTATION_SPEED)
	elif right and not left:
		steer(ROTATION_SPEED)
		
	# dash
	if Input.is_action_just_pressed(player+'_dash'):
		speed_multiplier = 3
		
	# fire
	if Input.is_action_just_pressed(player+'_fire'):
		fire()
		
	var collision = move_and_collide(velocity * speed_multiplier)
	
	# check collision with deadly entities
	if collision != null and collision.collider.get('deadly'):
		emit_signal("died", player)
		queue_free()
	
	# wrap
	if position.x > width:
		position.x -= width
	elif position.x <= 0:
		position.x += width
		
	if position.y > height:
		position.y -= height
	elif position.y <= 0:
		position.y += height
	
	# dash recover
	speed_multiplier = max(1, speed_multiplier - 0.1)
	
# Steer the ship _rad_ radians clockwise.
func steer(rad):
	velocity = velocity.rotated(rad)
	rotate(rad)
	
# Fire a bomb
func fire():
	var bomb = Bomb.instance()
	bomb.velocity = velocity*(-1)
	bomb.position = position + bomb.velocity*6 # this moves the bomb away from the ship
	get_node('/root/Arena/Battlefield').add_child(bomb)
	