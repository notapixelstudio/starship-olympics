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

var targets = []

var target = null
var timeout = 0
var autolocking_timeout = 0.1

const LIFETIME = 1.5

signal detonate

func _ready():
	# load battlefield size
	width = get_node('/root/Arena').width
	height = get_node('/root/Arena').height
	
	# bombs life
	timeout = LIFETIME
	
func _physics_process(delta):
	autolocking_timeout -= delta
	
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
	if autolocking_timeout <= 0 or ship != origin_ship: # avoid pursuing the ship of origin right after shooting
		acquire_target(ship)
		
func acquire_target(ship):
	target = weakref(ship)
	$AnimatedSprite.play('locked')
	targets.push_front(weakref(ship))
	
func try_lose_target(ship):
	for t in targets:
		if t.get_ref() == ship:
			targets.erase(t)
			break
	
	# clean up targets from lost refs in front
	while len(targets) > 0 and targets[0].get_ref() == null:
		targets.pop_front()
	
	if len(targets) > 0:
		target = targets.pop_front()
	else:
		target = null
		$AnimatedSprite.play('default')
		timeout = LIFETIME
	
func _on_Bomb_area_entered(area):
	# bombs always explode when they touch objects with the Trigger component
	if area.has_node('TriggerComponent'):
		emit_signal("detonate")
		detonate()
		