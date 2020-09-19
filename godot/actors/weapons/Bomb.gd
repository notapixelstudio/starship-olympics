# script bomb
extends RigidBody2D

class_name Bomb

var Explosion = load('res://actors/weapons/Explosion.tscn')
var Ripple = load('res://actors/weapons/Ripple.tscn')

var ball_texture = preload('res://assets/sprites/weapons/ball_bomb.png')
var type

var entity : Entity
onready var life_time = $LifeTime
onready var trail = $Trail2D
onready var explosion = Explosion.instance()

func initialize(pos : Vector2, bomb_type, impulse, ship, size = 1):
	type = bomb_type
	entity = ECM.E(self)
	
	position = pos
	if impulse:
		apply_impulse(Vector2(0,0), impulse)
	if ship:
		entity.get('Owned').set_owned_by(ship)
		ECM.E($Core).get('Owned').set_owned_by(ship)
		$Sprite.modulate = ship.species.color
	else:
		entity.get('Owned').disable()
		ECM.E($Core).get('Owned').disable()
		
	if type == GameMode.BOMB_TYPE.ball:
		entity.get('Pursuer').disable()
		entity.get('Deadly').enable()
		set_collision_mask_bit(2, true) # bombs colliding with bombs
		$Sprite.scale = Vector2(1,1)
		$CollisionShape2D.shape.radius = size*32 # WAAAARNING this likely alters all collision shapes of all bombs!
		$NearArea/CollisionShape2D.shape.radius = size*32
		$Sprite.texture = ball_texture
		$Sprite.scale = Vector2(size, size)
		$Sprite/AnimationPlayer.stop()
	else:
		$CollisionShape2D.shape.radius = size*16
		$NearArea/CollisionShape2D.shape.radius = size*16
		$Sprite.scale = Vector2(size*0.5, size*0.5)
		
	$Core/CollisionShape2D.shape.radius = size*8
	
func _physics_process(delta):
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
	if type == GameMode.BOMB_TYPE.ball:
		return
		
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
		if entity.has('Owned'):
			entity.get('Owned').get_owned_by()._on_bomb_freed()
		yield(get_tree().create_timer(1), "timeout")
		call_deferred("queue_free")


func process_life_time():
	# pause lifetime if we are pursuing a target
	if entity.has('Pursuer') and entity.get('Pursuer').get_target() != null:
		life_time.paused = true
		return
	
	life_time.paused = false
	

# FIXME ? is this heavy? each bomb needs contact monitoring
func _on_Bomb_body_entered(body):
	if body is Brick:
		body.break(entity.get('Owned').get_owned_by())
	
	if type == GameMode.BOMB_TYPE.ball:
		life_time.start() # enable ricochet combos
		apply_central_impulse(linear_velocity.normalized()*1000)
		
		# ripple effect
		
		var ripple = Ripple.instance()
		ripple.position = position
		get_parent().call_deferred("add_child", ripple)
