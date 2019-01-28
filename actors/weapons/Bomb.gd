# script bomb
extends RigidBody2D

# export var velocity = Vector2(6, 0)
# export var acceleration = Vector2(-0.06, 0)
class_name Bomb

var origin_ship
var player_id

const Explosion = preload('res://actors/weapons/Explosion.tscn')
var width
var height
const CLEANUP_DISTANCE = 100

var targets = []

var target = null
var timeout = 0
var autolocking_timeout = 0.1

const LIFETIME = 1.5

signal detonate
var explosion
func _ready():
	
	# bombs life
	timeout = LIFETIME
	explosion = Explosion.instance()
	
	# sound
	get_node("sound").play()
	
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
		
	
func detonate():
	queue_free()
	explosion.player_id = player_id
	explosion.position = position
	get_parent().add_child(explosion)

func try_acquire_target(ship):
	# Do not lock if invincible
	if ship.invincible:
		return
		
	# If there's a queen ship, avoid locking on partners
	if ship.arena.game_mode.is_there_a_queen() and not origin_ship.queen and not ship.queen:
		return
	 
	if autolocking_timeout <= 0 or ship != origin_ship: # avoid pursuing the ship of origin right after shooting
		acquire_target(ship)
		
func acquire_target(ship):
	get_node("lock-sound").play()
	target = weakref(ship)
	print(ship.species_template.species_name)
	$AnimatedSprite.play('locked_'+ship.species_template.species_name)
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
		