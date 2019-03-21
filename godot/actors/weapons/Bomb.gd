# script bomb
extends RigidBody2D

class_name Bomb

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

const LIFETIME = 1.5

var entity : Entity

var explosion

func _ready():
	# bombs life
	timeout = LIFETIME
	explosion = Explosion.instance()
	
	# sound
	get_node("sound").play()
	
func initialize(pos : Vector2, impulse, ship):
	entity = ECM.E(self)
	
	position = pos
	if impulse:
		apply_impulse(Vector2(0,0), impulse)
	if ship:
		entity.get('Owned').set_owned_by(ship)
	else:
		entity.get('Owned').disable()
	
func _physics_process(delta):
	locking_timeout -= delta
	var thrust: float
	if entity.has('Thrusters'):
		thrust = 50
	else:
		thrust = 20
		
	if target != null and target.get_ref() != null:
		apply_impulse(Vector2(0,0), (target.get_ref().position - position).normalized()*thrust) # need a meaningful way to do this
		
		if target_timeout > 0:
			target_timeout -= delta
		else:
			lose_target()
	else:
		# destroy bomb after timeout
		if timeout > 0:
			timeout -= delta
		elif entity.has('Owned'):
			call_deferred("queue_free")
			
	if entity.has('Flowing'):
		apply_impulse(Vector2(), entity.get_node('Flowing').get_flow_vector())
		
signal detonate
func detonate():
	ECM.E(explosion).get('Owned').set_owned_by(entity.get('Owned').get_owned_by())
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
	if entity.has('Owned') and len(ECM.entities_with('Royal')) > 0 and not ECM.E(ship).has('Royal') and not ECM.E(entity.get('Owned').get_owned_by()).has('Royal'):
		return
		
	if locking_timeout <= 0 or ship != entity.get('Owned').get_owned_by(): # avoid pursuing the ship of origin right after shooting
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
	
signal near_area_exited
func _on_NearArea_area_exited(area):
	emit_signal("near_area_exited", area, self)
	