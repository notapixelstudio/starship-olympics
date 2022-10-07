# script bomb
extends RigidBody2D

class_name Bomb

export var Explosion : PackedScene
export var Ripple : PackedScene
export var BubbleScene : PackedScene
export var PfftScene : PackedScene

var ball_texture = preload('res://assets/sprites/weapons/ball_bomb.png')
var bullet_texture = preload('res://assets/sprites/weapons/bullet.png')
var ice_texture = preload('res://assets/sprites/weapons/ice.png')
var bubble_texture = preload('res://assets/sprites/weapons/bubble.png')
var type
var symbol = null

var entity : Entity
onready var explosion = Explosion.instance()

var species : Species

func _ready():
	if type == GameMode.BOMB_TYPE.classic:
		$Sprite/AnimationPlayer.play('rotate')
	elif type == GameMode.BOMB_TYPE.bubble:
		$Sprite/AnimationPlayer.play("wobble")
	else:
		$Sprite/AnimationPlayer.stop()
		
	if symbol:
		$Symbol.texture = load('res://assets/sprites/alchemy/'+symbol+'.png')
		$Symbol.modulate = Bubble.symbol_colors[symbol]
		$Sprite.modulate = Bubble.symbol_colors[symbol]
	
func initialize(bomb_type, pos : Vector2, impulse, ship, size = 1):
	type = bomb_type
	entity = ECM.E(self)
	
	position = pos
	if impulse:
		apply_impulse(Vector2(0,0), impulse)
	if ship:
		species = ship.species
		
		entity.get('Owned').set_owned_by(ship)
		ECM.E($Core).get('Owned').set_owned_by(ship)
		if type == GameMode.BOMB_TYPE.ice:
			$Sprite.modulate = Color(0.9,1,1,1)
		else:
			$Sprite.modulate = ship.species.color
	else:
		entity.get('Owned').disable()
		ECM.E($Core).get('Owned').disable()
		
	if type == GameMode.BOMB_TYPE.ball:
		entity.get('Pursuer').disable()
		entity.get('Deadly').enable()
		#set_collision_mask_bit(2, true) # bombs colliding with bombs
		$Sprite.scale = Vector2(1,1)
		$CollisionShape2D.shape.radius = size*80
		$NearArea/CollisionShape2D.shape.radius = size*80
		$Sprite.texture = ball_texture
		$Sprite.scale = Vector2(size*1.1, size*1.1)
		
	elif type == GameMode.BOMB_TYPE.bullet:
		entity.get('Pursuer').disable()
		entity.get('Deadly').enable()
		#set_collision_mask_bit(2, true) # bombs colliding with bombs
		$CollisionShape2D.shape.radius = size*80
		$NearArea/CollisionShape2D.shape.radius = size*80
		$Sprite.texture = bullet_texture
		$Sprite.scale = Vector2(size*0.6, size*0.6)
		mode = MODE_CHARACTER
		
	elif type == GameMode.BOMB_TYPE.bubble:
		entity.get('Pursuer').disable()
		entity.get('Deadly').disable()
		$CollisionShape2D.shape.radius = size*90
		$NearArea/CollisionShape2D.shape.radius = size*90
		$Sprite.texture = bubble_texture
		$Sprite.scale = Vector2(size*1.4, size*1.4)
		mode = MODE_CHARACTER
		linear_damp = 0
		ECM.E($Core).get('Deadly').disable()
		
	elif type == GameMode.BOMB_TYPE.ice:
		entity.get('Pursuer').disable()
		entity.get('Deadly').disable()
		$CollisionShape2D.shape.radius = size*80
		$NearArea/CollisionShape2D.shape.radius = size*80
		$Sprite.texture = ice_texture
		$Sprite.scale = Vector2(size*1.1, size*1.1)
		mode = MODE_CHARACTER
		
	else:
		$CollisionShape2D.shape.radius = size*22
		$NearArea/CollisionShape2D.shape.radius = size*22
		$Sprite.scale = Vector2(size*0.6, size*0.6)
		
		# rockets need to be charged at least a little to pursue
		if impulse and impulse.length() < 2500:
			entity.get('Pursuer').disable()
		
	$Core/CollisionShape2D.shape.radius = size*8
	
func _process(delta):
	if type == GameMode.BOMB_TYPE.ice:
		$Sprite.rotation += delta
	elif type != GameMode.BOMB_TYPE.bubble:
		$Sprite.rotation = linear_velocity.angle()
	
func _physics_process(_delta):
	process_life_time()
	if entity.has('Flowing'):
		apply_impulse(Vector2(), entity.get_node('Flowing').get_flow().get_flow_vector(position))


func _integrate_forces(state):
	# force the physics engine
	var xform = state.get_transform()
	
	# teleport
	if entity.could_have('Teleportable') and entity.get('Teleportable').is_teleporting():
		xform.origin = entity.get('Teleportable').get_destination()
		entity.get('Teleportable').teleport_done()
		
	state.set_transform(xform)


signal detonate
func detonate():
	if type != GameMode.BOMB_TYPE.classic:
		return
		
	if entity.has('Owned'):
		ECM.E(explosion).get('Owned').set_owned_by(entity.get('Owned').get_owned_by())
	else:
		ECM.E(explosion).get('Owned').disable()
		
	explosion.position = position
	emit_signal("detonate")
	if get_parent():
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
	if not entity.has('StandAlone') and type != GameMode.BOMB_TYPE.bubble:
		dissolve()
		call_deferred("queue_free")

func dissolve() -> void:
	var pfft = PfftScene.instance()
	pfft.set_color(species.get_color())
	get_parent().add_child(pfft)
	pfft.global_position = global_position

func process_life_time():
	# pause lifetime if we are pursuing a target
	if entity.has('Pursuer') and entity.get('Pursuer').get_target() != null:
		$LifeTime.paused = true
		return
	
	$LifeTime.paused = false
	
var hit_count = 0
# FIXME ? is this heavy? each bomb needs contact monitoring
func _on_Bomb_body_entered(body):
	if body is Brick:
		body.break(entity.get('Owned').get_owned_by())
	
	if type == GameMode.BOMB_TYPE.ball or body is Paddle:
		$RicochetAudio.pitch_scale = 0.5 + hit_count*0.1
		hit_count = min(hit_count+1, 1000)
		$RicochetAudio.play()
		$LifeTime.start() # enable ricochet combos
		apply_central_impulse(linear_velocity.normalized()*800)
		
		# ripple effect
		
		var ripple = Ripple.instance()
		ripple.position = position
		get_parent().call_deferred("add_child", ripple)
	
	if body is RemoteBomb:
		detonate()

var bubble_already_spawned = false
func create_bubble():
	if bubble_already_spawned:
		return
		
	var bubble = BubbleScene.instance()
	#bubble.set_species(entity.get('Owned').get_owned_by().species)
	bubble.symbol = symbol
	bubble.position = position
	bubble.linear_velocity = linear_velocity
	get_parent().call_deferred("add_child", bubble) # ugly
	get_parent().get_parent().get_parent().call_deferred("connect_killable", bubble) # uglier
	bubble.call_deferred("attempt_binding", entity.get('Owned').get_owned_by())
	bubble_already_spawned = true

func _on_NearArea_body_entered(body):
	if body is Bubble:
		if type == GameMode.BOMB_TYPE.bubble:
			create_bubble()
			queue_free()
		else:
			body.pop(true)
	elif type == GameMode.BOMB_TYPE.ice and body != self and body.has_method('freeze'):
		if not body is Ship:
			body.freeze()
			queue_free()
		elif entity.get('Owned').get_owned_by() != body:
			body.freeze()
			queue_free()
		
func get_owner_ship():
	return entity.get('Owned').get_owned_by()

#signal frozen
#func freeze():
#	emit_signal("frozen", self)
