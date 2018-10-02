# script bomb
extends Area2D

export var velocity = Vector2(6, 0)
export var acceleration = Vector2(-0.06, 0)

var player_id

var Explosion = preload('res://actors/Explosion.tscn')
var width
var height
const CLEANUP_DISTANCE = 100

var stopped = false
var timeout = 0

signal detonate

func _ready():
	# load battlefield size
	width = get_node('/root/Arena').width
	height = get_node('/root/Arena').height

func stop():
	acceleration = Vector2(0, 0)
	velocity = Vector2(0, 0)
	stopped = true
	timeout = 0.5
	
func _physics_process(delta):
	position += velocity
	
	var old_velocity = velocity.length()
	velocity += acceleration
	
	# stop if velocity crossed zero
	if not stopped and (old_velocity-velocity.length()) <= 0:
		stop()
		
	# disable bomb after timeout
	if stopped:
		if timeout > 0:
			timeout -= delta
		else:
			queue_free()
		
	# bomb rotate by default
	#rotation += 0.05
	
	# remove bomb if far outside the screen
	if position.x > width+CLEANUP_DISTANCE or position.x <= -CLEANUP_DISTANCE or position.y > height+CLEANUP_DISTANCE or position.y <= -CLEANUP_DISTANCE:
		queue_free()
	
func detonate():
	queue_free()
	var explosion = Explosion.instance()
	get_parent().add_child(explosion)
	explosion.player_id = player_id
	explosion.position = position

func _on_Bomb_area_entered(area):
	# bombs always explode when they touch objects with the Trigger component
	if area.has_node('TriggerComponent'):
		emit_signal("detonate")
		detonate()