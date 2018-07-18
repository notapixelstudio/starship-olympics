# script bomb
extends KinematicBody2D

export var velocity = Vector2(18, 0)

var player_id

var Explosion = preload('res://actors/Explosion.tscn')
var width
var height
const CLEANUP_DISTANCE = 100

	
func _ready():
	width = get_viewport().size.x
	height = get_viewport().size.y

func _physics_process(delta):
	var collision = move_and_collide(velocity)
	if collision != null:
		detonate()
		
	# remove bomb if far outside the screen
	if position.x > width+CLEANUP_DISTANCE or position.x <= -CLEANUP_DISTANCE or position.y > height+CLEANUP_DISTANCE or position.y <= -CLEANUP_DISTANCE:
		queue_free()
	
func detonate():
	queue_free()
	var explosion = Explosion.instance()
	get_node('/root/Arena/Battlefield').add_child(explosion)
	explosion.player_id = player_id
	explosion.position = position
	
func on_explosion_entered(player_id):
	detonate()
	
func on_trail_entered():
	detonate()