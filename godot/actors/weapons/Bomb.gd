# script bomb
extends RigidBody2D

# export var velocity = Vector2(6, 0)
# export var acceleration = Vector2(-0.06, 0)
class_name Bomb

var origin_ship: RigidBody2D
var player_id

const Explosion = preload('res://actors/weapons/Explosion.tscn')
var width
var height
const CLEANUP_DISTANCE = 100

var target = null
var timeout = 0
const LOCKING_TIMEOUT = 1
var locking_timeout = LOCKING_TIMEOUT
const TARGET_TIMEOUT = 1
var target_timeout = TARGET_TIMEOUT

var standalone = false
const LIFETIME = 1.5


var explosion
func _ready():
	
	# bombs life
	timeout = LIFETIME
	explosion = Explosion.instance()
	
	# sound
	get_node("sound").play()
	
func initialize(pos : Vector2, impulse, ship):
	position = pos
	if impulse:
		apply_impulse(Vector2(0,0), impulse)
	if ship:
		origin_ship = ship
		player_id = ship.player
	else:
		standalone = true
	
func _physics_process(delta):
	locking_timeout -= delta
	
	if target != null and target.get_ref() != null:
		apply_impulse(Vector2(0,0), (target.get_ref().position - position).normalized()*50) # need a meaningful way to do this
		
		if target_timeout > 0:
			target_timeout -= delta
		else:
			lose_target()
	else:
		# destroy bomb after timeout
		if timeout > 0:
			timeout -= delta
		elif not standalone:
			call_deferred("queue_free")
		
signal detonate
func detonate():
	explosion.player_id = player_id
	explosion.position = position
	emit_signal("detonate")
	get_parent().call_deferred("add_child", explosion)
	call_deferred("queue_free")

func try_acquire_target(ship):
	# Do not lock if already locked onto the same target, but keep the target time
	if target != null and target.get_ref() != null and target.get_ref() == ship:
		target_timeout = TARGET_TIMEOUT
		return
		
	# Do not lock if invincible
	if ship.invincible:
		return
		
	# If there's a queen ship, avoid locking on partners
	if not standalone and ship.arena.game_mode.is_there_a_queen() and not ECM.E(ship).has('Royal') and not ECM.E(origin_ship).has('Royal'):
		return
	
	if locking_timeout <= 0 or ship != origin_ship: # avoid pursuing the ship of origin right after shooting
		acquire_target(ship)
		
func acquire_target(ship):
	get_node("lock-sound").play()
	target = weakref(ship)
	# print("target acquired: ", ship.species_template.species_name)
	$AnimatedSprite.play('locked_'+str(ship.species_template.id))
	
	# avoid changing target too often
	locking_timeout = LOCKING_TIMEOUT
	
	target_timeout = TARGET_TIMEOUT
	
func lose_target():
	target = null
	$AnimatedSprite.play('default')
	timeout = LIFETIME
	
signal near_area_entered
func _on_NearArea_area_entered(area):
	emit_signal("near_area_entered", area, self)
	