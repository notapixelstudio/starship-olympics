# script bomb
extends RigidBody2D

class_name Bomb

var Explosion = load('res://actors/weapons/Explosion.tscn')

var entity : Entity
onready var life_time = $LifeTime
onready var trail = $Trail2D
onready var explosion = Explosion.instance()

func initialize(pos : Vector2, impulse, ship):
	entity = ECM.E(self)
	
	position = pos
	if impulse:
		apply_impulse(Vector2(0,0), impulse)
	if ship:
		entity.get('Owned').set_owned_by(ship)
		ECM.E($Core).get('Owned').set_owned_by(ship)
		$Sprite.modulate = ship.species_template.color
	else:
		entity.get('Owned').disable()
		ECM.E($Core).get('Owned').disable()
		
func _physics_process(delta):
	entity.get('Thrusters').apply_damp(self)
	
	process_life_time()
	if entity.has('Flowing'):
		apply_impulse(Vector2(), entity.get_node('Flowing').get_flow().get_flow_vector(position))


func _integrate_forces(state):
	# force the physics engine
	var xform = state.get_transform()
	
	# teleport
	if entity.could_have('Teleportable') and entity.get('Teleportable').is_teleporting():
		trail.erase_trail()
		xform.origin = entity.get('Teleportable').get_destination()
		entity.get('Teleportable').teleport_done()
		
	state.set_transform(xform)


signal detonate
func detonate():
	if entity.has('Owned'):
		ECM.E(explosion).get('Owned').set_owned_by(entity.get('Owned').get_owned_by())
	else:
		ECM.E(explosion).get('Owned').disable()
		
	explosion.position = position
	emit_signal("detonate")
	get_parent().call_deferred("add_child", explosion)
	get_parent().call_deferred("remove_child", self)
	yield(get_tree().create_timer(1), "timeout")
	call_deferred("queue_free")


signal near_area_entered
func _on_NearArea_area_entered(area):
	emit_signal("near_area_entered", area, self)


signal near_area_exited
func _on_NearArea_area_exited(area):
	emit_signal("near_area_exited", area, self)
	

func _on_LifeTime_timeout():
	if not entity.has('StandAlone'):
		get_parent().call_deferred("remove_child", self)
		yield(get_tree().create_timer(1), "timeout")
		call_deferred("queue_free")


func process_life_time():
	# pause lifetime if we are pursuing a target
	if entity.has('Pursuer') and entity.get('Pursuer').get_target() != null:
		life_time.paused = true
		return
	
	life_time.paused = false
	