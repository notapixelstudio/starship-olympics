# script bomb
extends RigidBody2D

#export var velocity = Vector2(6, 0)
#export var acceleration = Vector2(-0.06, 0)

var origin_ship
var player_id

var Explosion = preload('res://actors/Explosion.tscn')
var width
var height
const CLEANUP_DISTANCE = 100

var target = null
var timeout = 0

signal detonate

func _ready():
	# load battlefield size
	width = get_node('/root/Arena').width
	height = get_node('/root/Arena').height
	
	# bombs life
	timeout = 1.5
	
func _physics_process(delta):
	if target != null and target.get_ref() != null:
		apply_impulse(Vector2(0,0), (target.get_ref().position - position).normalized()*50) # need a meaningful way to do this
	else:
		# destroy bomb after timeout
		if timeout > 0:
			timeout -= delta
		else:
			queue_free()
		
	# remove bomb if far outside the screen
	if position.x > width+CLEANUP_DISTANCE or position.x <= -CLEANUP_DISTANCE or position.y > height+CLEANUP_DISTANCE or position.y <= -CLEANUP_DISTANCE:
		queue_free()
	
func detonate():
	queue_free()
	var explosion = Explosion.instance()
	get_parent().add_child(explosion)
	explosion.player_id = player_id
	explosion.position = position

func try_acquire_target(ship):
	if ship != origin_ship: # avoid pursuing the ship of origin
		target = weakref(ship)
	
func _on_Bomb_area_entered(area):
	# bombs always explode when they touch objects with the Trigger component
	if area.has_node('TriggerComponent'):
		emit_signal("detonate")
		detonate()
		