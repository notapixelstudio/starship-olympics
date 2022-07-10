tool
extends RigidBody2D
"""
Node for the RigidBody and Ship physics
it will get as export variable the battle template (containing the species values)
and its keyboard control
"""
class_name Ship

export var debug_enabled = false
export (String) var controls = "kb1"
export var absolute_controls : bool= true
export (Resource) var species

var controls_enabled = false

var spawner
var trail

var cpu = false
var velocity = Vector2(0,0)
var previous_velocity = Vector2(0,0)
var last_contact_normal = null
var target_velocity = Vector2(0,0)
var steer_force = 0
var rotation_request = 0

var THRUST = 6500
var auto_thrust := false

var deadly_trail = false
var deadly_trail_powerup = false

var golf = false

var charge = 0
var actual_charge = 0
const max_steer_force = 2500
const MAX_CHARGE = 0.6
const MIN_CHARGE = 0.2
const CHARGE_BASE = 250
const CHARGE_MULTIPLIER = 7000
const DASH_BASE = -400
const DASH_MULTIPLIER = 2.5 # was 2.7, decreased to lessen the chanche of tunneling
const BOMB_OFFSET = 50
const BOMB_BOOST = 1600
const BALL_BOOST = 2300
const BOMB_CHARGE_MULTIPLIER = 1.65
const BALL_CHARGE_MULTIPLIER = 2.2
const BULLET_BOOST = 1500
const BULLET_CHARGE_MULTIPLIER = 1.3
const BUBBLE_BOOST = 1200
const FIRE_COOLDOWN = 0.03
const OUTSIDE_COUNTUP = 3.0
const ARKABALL_OFFSET = 250
const ARKABALL_MULTIPLIER = 3

const ROTATION_TORQUE = 49000*9 # 9 because we enlarged the radius of the ship's collision shape by 3

var responsive = false setget change_engine
var info_player setget set_info_player

func set_info_player(value):
	info_player = value
	species = info_player.species
	

var count = 0
var alive = true
var stunned = false
var stun_countdown = 0
var outside_countup = 0

var max_health := 1
var health := max_health

var screen_size = Vector2()
var width = 0
var height = 0

var charging = false
var charging_enough = false
var fire_cooldown = FIRE_COOLDOWN
var dash_cooldown = 0
var phasing_cooldown = 0
var reload_time : float

var game_mode : GameMode

var bomb_count = 0

var teleport_to = null

onready var player = name
onready var skin = $Graphics
onready var charging_sfx = $charging
onready var ammo = $PlayerInfo.ammo
onready var target_dest = $TargetDest


const dead_ship_scene = preload("res://actors/battlers/DeadShip.tscn")

var dead_ship_instance

const arkaball_scene = preload('res://actors/environments/ArkaBall.tscn')

signal dead
signal stop_invincible
signal spawn_bomb

signal dash_started
signal dash_ended

signal bump
signal collect

var invincible : bool

var entity : Entity
var camera

var weapon_textures = {
	GameMode.BOMB_TYPE.classic: preload('res://assets/sprites/interface/charge_rocket.png'),
	GameMode.BOMB_TYPE.ball: preload('res://assets/sprites/interface/charge_ball.png'),
	GameMode.BOMB_TYPE.bullet: preload('res://assets/sprites/interface/charge_bullet.png'),
	GameMode.BOMB_TYPE.bubble: preload('res://assets/sprites/interface/charge_bubble.png'),
	GameMode.BOMB_TYPE.mine: preload('res://assets/sprites/interface/charge_ball.png'),
	GameMode.BOMB_TYPE.ice: preload('res://assets/sprites/interface/charge_ice.png'),
	GameMode.BOMB_TYPE.wave: preload('res://assets/sprites/interface/charge_ball.png')
}

var symbol

func initialize():
	pass

signal spawned

var bombs_enabled : bool = true setget set_bombs_enabled
var bomb_type
var default_bomb_type

func set_bombs_enabled(value: bool):
	bombs_enabled = value
	
func set_default_bomb_type(value):
	default_bomb_type = value
	set_bomb_type(value)
	
func set_bomb_type(value):
	bomb_type = value
	ammo.type = bomb_type
	$Graphics/ChargeBar/BombPreview.texture = weapon_textures[bomb_type]
	if bomb_type != GameMode.BOMB_TYPE.bubble:
		$Graphics/ChargeBar/BombPreview.modulate = species.color
	else:
		next_symbol()
	
func set_ammo(value):
	ammo.set_max_ammo(value)
	ammo.replenish()
	
func set_reload_time(value):
	reload_time = value
	
func set_lives(value: int):
	info_player.lives = value
	
func set_max_health(value: int):
	max_health = value
	reset_health()
	
func reset_health():
	$PlayerInfo.reset_health(max_health)
	self.set_health(max_health)

func _enter_tree():
	charging = false
	charging_enough = false
	charge = 0
	alive = true
	outside_countup = 0
	
	reset_health()
	
	update_weapon_indicator()
	
	# shields always start off
	$Shields.switch_off()
	
	emit_signal('spawned', self)
	dash_init_appearance()
	if controls_enabled:
		make_invincible()
		
	$AutoTrail.starting_color = Color(species.color.r, species.color.g, species.color.b, 0.4)
	$AutoTrail.ending_color = Color(species.color.r, species.color.g, species.color.b, 0.0)
	
func make_invincible():
	invincible = true
	if skin:
		skin.invincible()
	yield(get_tree().create_timer(0.1), "timeout")
	yield(skin, "stop_invincible")
	invincible = false
	
func _ready():
	disable_controls()
	dead_ship_instance = dead_ship_scene.instance()
	dead_ship_instance.ship = self
	skin.ship_texture = species.ship
	# skin.invincible(1.0)
	entity = ECM.E(self)
	
	entity.get('Conqueror').set_species(self)
	self.responsive = true
	
	var dash_process_material = $DashParticles.process_material.duplicate(true)
	var transparent_color = Color(species.color_2)
	transparent_color.a = 0
	dash_process_material.color_ramp.gradient.set_color(0, species.color)
	dash_process_material.color_ramp.gradient.set_color(1, transparent_color)
	$DashParticles.process_material = dash_process_material
	$Graphics/ChargeBar/Crosshair.modulate = species.color
	
	# if we are on a proper team, switch on the outline
	if info_player.has_proper_team():
		$Graphics/Sprite.material.set_shader_param('active', true)
		var color = info_player.get_team_color()
		$Graphics/Sprite.material.set_shader_param('color', color)
	
func change_engine(value: bool):
	responsive = value
	set_physics_process(responsive)
	
func _process(_delta):
	if bomb_type == GameMode.BOMB_TYPE.bubble:
		$Graphics/ChargeBar/BombPreview.rotation = -global_rotation
	continuous_collision_check()
	
static func magnitude(a:Vector2):
	return sqrt(a.x*a.x+a.y*a.y)
	
func _integrate_forces(state):
	if not responsive:
		return
	set_applied_force(Vector2())
	steer_force = max_steer_force * rotation_request
	
	var thrusers_on = not is_in_gel() and not golf and entity.has('Thrusters') and not charging_enough and not stunned # and not entity.has('Dashing') # thrusters switch off when charging enough (and during dashes)
	
	if not absolute_controls:
		add_central_force(Vector2(THRUST, steer_force).rotated(rotation)*int(thrusers_on))
		# rotation = atan2(target_velocity.y, target_velocity.x)
	else:
		#rotation = state.linear_velocity.angle()
		#apply_impulse(Vector2(),target_velocity*THRUST)
		add_central_force(target_velocity*THRUST*int(thrusers_on))
		
	if entity.has('Flowing'):
		apply_impulse(Vector2(), entity.get_node('Flowing').get_flow().get_flow_vector(position))
		
	# setting a maximum torque should prevent ship oscillation
	set_applied_torque(min(PI/2, rotation_request) * ROTATION_TORQUE) # * int(not entity.has('Dashing'))) # can't steer while dashing
	#rotation = atan2(target_velocity.y, target_velocity.x)
	
	# force the physics engine
	var xform = state.get_transform()
	
	# teleport
	if entity.could_have('Teleportable') and entity.get('Teleportable').is_teleporting():
		emit_signal('spawned', self)
		xform.origin = entity.get('Teleportable').get_destination()
		entity.get('Teleportable').teleport_done()
		
	#if xform.origin.x > width:
	#	xform.origin.x = 0
	#if xform.origin.x < 0:
	#	xform.origin.x = width
	#if xform.origin.y > height:
	#	xform.origin.y = 0
	#if xform.origin.y < 0:
	#	xform.origin.y = height

	# clamp velocity
	#state.linear_velocity = state.linear_velocity.clamped(max_velocity)
	
	# store velocity as a readable var
	previous_velocity = velocity
	velocity = state.linear_velocity
	
	# store last contact normal as a readable var
	if state.get_contact_count() > 0:
		last_contact_normal = state.get_contact_local_normal(0)
	
	state.set_transform(xform)

func control(_delta):
	update_charge_bar()
	
var overcharging := false
signal overcharging_started
func update_charge_bar():
	if not charging:
		$Graphics/ChargeBar/Charge.visible = false
		$Graphics/ChargeBar/ShootingLine.visible = false
		$Graphics/ChargeBar/ShootingLine.enabled = false
		overcharging = false
		return
		
	$Graphics/ChargeBar/Charge.visible = true
	
	# charge feedback
	var v = $Graphics/ChargeBar/ChargeAxis.points[1] * min(charge,MAX_CHARGE)/MAX_CHARGE
	$Graphics/ChargeBar/Charge.set_point_position(1, v)
	$Graphics/ChargeBar/ChargeBackground.set_point_position(1, v)
	$Graphics/ChargeBar/Charge/ArrowTip.position.x = v.x+26
	
	# shooting line visible only when charging enough enough
	$Graphics/ChargeBar/ShootingLine.visible = charge > MIN_CHARGE*2
	$Graphics/ChargeBar/ShootingLine.enabled = charge > MIN_CHARGE*2
	
	# overcharge feedback
	if charge > MAX_CHARGE:
		var visible = int(floor(charge * 15)) % 2
		$Graphics/ChargeBar/Charge.visible = visible
		if not overcharging:
			overcharging = true
			emit_signal("overcharging_started")

signal detection
func _physics_process(delta):
	if not alive:
		return
		
	if not invincible:
		var on_platform = false
		for area in $NearArea.get_overlapping_areas():
			if area.is_in_group('platform'):
				on_platform = true
				break
		if on_platform:
			outside_countup = 0
		else:
			outside_countup += delta
			
		if outside_countup > OUTSIDE_COUNTUP:
			fall()
		
	control(delta)
	
	stun_countdown -= delta
	if stun_countdown <= 0:
		unstun()

	for body in $DetectionArea.get_overlapping_bodies():
		emit_signal("detection", body, self)
		
	dash_cooldown -= delta
	phasing_cooldown -= delta
	
	if phasing_cooldown <= 0 and entity.get('Phasing').enabled:
		#yield(get_tree().create_timer(0.2), 'timeout') # wait a bit to be lenient with phase-through checks
		entity.get('Phasing').disable()
	
	if dash_cooldown <= 0 and entity.get('Dashing').enabled:
		#dash_restore_appearance()
		entity.get('Dashing').disable()
		
	if charging and not charging_enough and charge > MIN_CHARGE:
		charging_enough = true
		#$GravitonField.enabled = true
		charging_sfx.play()
		dash_fat_appearance()
		
var will_fire
signal charging_started
func charge():
	charging = true
	emit_signal("charging_started")
	
	will_fire = get_bombs_enabled() and (ammo.max_ammo == -1 or ammo.current_ammo > 0)
	if will_fire:
		$Graphics/ChargeBar/Charge.modulate = Color(1, 0.376471, 0)
		$Graphics/ChargeBar/ShootingLine.modulate = Color(1, 0.376471, 0)
		if bomb_type != GameMode.BOMB_TYPE.bubble:
			$Graphics/ChargeBar/BombPreview.modulate = Color(1, 0.376471, 0)
		$Graphics/ChargeBar/BombPreview.self_modulate = Color(1,1,1,1)
	else:
		$Graphics/ChargeBar/Charge.modulate = Color(1,1,0)
	
signal charging_ended
func fire(override_charge = -1, dash_only = false):
	"""
	Fire a bomb
	"""
	var should_reload = false
	
	actual_charge = override_charge if override_charge > 0 else charge
	var charge_impulse = CHARGE_BASE + CHARGE_MULTIPLIER * clamp(actual_charge - MIN_CHARGE, 0, MAX_CHARGE)
	var will_dash = charging_enough and is_aiming_away_gel()
	
	if will_dash:
		apply_impulse(Vector2(0,0), Vector2(max(0,DASH_BASE+charge_impulse*DASH_MULTIPLIER), 0).rotated(rotation)) # recoil only if dashing
	
	if golf:
		var impulse = charge_impulse*ARKABALL_MULTIPLIER
		var arkaball = arkaball_scene.instance()
		arkaball.position = position + Vector2(-ARKABALL_OFFSET,0).rotated(rotation)
		arkaball.apply_central_impulse(Vector2(-impulse,0).rotated(rotation))
		get_parent().add_child(arkaball)
		arkaball.set_player(get_player())
		arkaball.start()
		golf = false
	elif get_bombs_enabled() and not dash_only:
		bomb_count += 1
		will_fire = get_bombs_enabled() and (ammo.max_ammo == -1 or ammo.current_ammo > 0) # FIXME this is repeated twice, should also be reflected by visual feedback
		if will_fire:
			ammo.shot()
			should_reload = true
			var impulse
			if bomb_type == GameMode.BOMB_TYPE.ball:
				impulse = charge_impulse*BALL_CHARGE_MULTIPLIER+BALL_BOOST
			elif bomb_type == GameMode.BOMB_TYPE.bullet:
				impulse = charge_impulse*BULLET_CHARGE_MULTIPLIER+BULLET_BOOST
			elif bomb_type == GameMode.BOMB_TYPE.bubble:
				impulse = charge_impulse+BUBBLE_BOOST
			else:
				impulse = charge_impulse*BOMB_CHARGE_MULTIPLIER+BOMB_BOOST
				
			if bomb_type != GameMode.BOMB_TYPE.mine or actual_charge > 0.2:
				emit_signal("spawn_bomb", bomb_type, symbol, position + Vector2(-BOMB_OFFSET,0).rotated(rotation),
					Vector2(-impulse,0).rotated(rotation))
					
			if bomb_type == GameMode.BOMB_TYPE.bubble:
				next_symbol()
	
	# repeal
	#$GravitonField.repeal(charge_impulse)
	#$GravitonField.enabled = false
	
	charging = false
	charging_enough = false
	emit_signal("charging_ended")
	
	$Graphics/ChargeBar/ChargeAxis.visible = false
	$Graphics/ChargeBar/Charge.set_point_position(1, Vector2(0,0))
	$Graphics/ChargeBar/ChargeBackground.set_point_position(1, Vector2(0,0))
	if bomb_type != GameMode.BOMB_TYPE.bubble:
		$Graphics/ChargeBar/BombPreview.modulate = species.color
	$Graphics/ChargeBar/BombPreview.self_modulate = Color(1,1,1,0.5)
	
	fire_cooldown = FIRE_COOLDOWN
	charging_sfx.stop()
	$Tween.remove_all()
	$Graphics/Sprite.scale = DASH_RESTORED
	
	if will_dash:
		entity.get('Dashing').enable()
		dash_cooldown = (min(actual_charge, MAX_CHARGE) - MIN_CHARGE)*0.6
		phasing_cooldown = 0.2 # wait a bit to be lenient with phase-through checks
	else:
		tap()
		
	if should_reload and reload_time > 0: # negative == no automatic reload
		yield(get_tree().create_timer(reload_time), "timeout")
		ammo.reload()
		
func set_health(amount : int) -> void:
	health = amount
	$PlayerInfo.update_health(amount)
	
func damage(hazard, damager : Ship):
	if invincible or not alive:
		return
		
	self.set_health(health - 1)
	if health <= 0:
		die(damager)
	else:
		rebound((global_position-hazard.global_position).normalized(), 2500.0)
		
		if has_method('vibration_feedback'):
			call('vibration_feedback', false)
		
		Events.emit_signal("ship_damaged", self, hazard, damager)
		
		# slight, invisible invincibility
		invincible = true
		yield(get_tree().create_timer(0.1), "timeout")
		invincible = false
	
func die(killer : Ship, for_good = false):
	if alive and not invincible:
		alive = false
		
		# skin.play_death()
		# deactivate controls and whatnot and wait for the sound to finish
		yield(get_tree(), "idle_frame")
		if info_player.lives >= 0:
			info_player.lives -= 1
		emit_signal("dead", self, killer, for_good)
		Events.emit_signal("ship_died", self, killer, for_good)
		
func stun():
	stunned = true
	stun_countdown = 0.3
	
func unstun():
	stunned = false
	stun_countdown = 0
	
signal near_area_entered
func _on_NearArea_area_entered(area):
	emit_signal("near_area_entered", area, self)
	Events.emit_signal('sth_collided_with_ship', area, self)
	
func _on_NearArea_body_entered(body):
	emit_signal("near_area_entered", body, self)
	Events.emit_signal('sth_collided_with_ship', body, self)
	
signal near_area_exited
func _on_NearArea_area_exited(area):
	emit_signal("near_area_exited", area, self)
func _on_NearArea_body_exited(body):
	emit_signal("near_area_exited", body, self)
	
func _on_Ship_body_entered(body):
	Events.emit_signal('sth_collided_with_ship', body, self)
	
func is_alive():
	return alive

func update_score(_species: Species, score, pos):
	$PlayerInfo.update_score(score)
	

func get_id():
	return info_player.id

func recheck_colliding():
	for body in $NearArea.get_overlapping_bodies():
		_on_NearArea_body_entered(body)
	for area in $NearArea.get_overlapping_areas():
		_on_NearArea_area_entered(area)
		if traits.has_trait(area, 'Tappable'):
			Events.emit_signal("tappable_entered", area, self)

const DASH_RESTORED = Vector2(1,1)
const DASH_THIN = Vector2(1.5,0.5)
const DASH_FAT = Vector2(0.8,1.2)

func dash_init_appearance():
	$Tween.remove_all()
	$Graphics/Sprite.scale = DASH_RESTORED
	$DashParticles.restart()
	$DashParticles.emitting = false
	$DashParticles.visible = false
	
func dash_restore_appearance():
	$Tween.remove_all()
	$Tween.interpolate_property($Graphics/Sprite, "scale", $Graphics/Sprite.scale, DASH_RESTORED, 0.5,
		Tween.TRANS_CUBIC, Tween.EASE_OUT, 0)
	$Tween.start()
	$DashFxTimer.start(0.1)
	yield($DashFxTimer, 'timeout')
	$DashParticles.emitting = false
	
func dash_fat_appearance():
	$Tween.remove_all()
	$Tween.interpolate_property($Graphics/Sprite, "scale", $Graphics/Sprite.scale, DASH_FAT, MAX_CHARGE,
		Tween.TRANS_QUAD, Tween.EASE_OUT, 0)
	$Tween.start()
	
func dash_thin_appearance():
	$DashFxTimer.stop()
	$Graphics/Sprite.scale = DASH_THIN
	$DashParticles.emitting = true
	$DashParticles.visible = true
	
func _on_Dashing_enabled():
	# dashing always enables phasing
	entity.get('Phasing').enable()
	
	dash_thin_appearance()
	emit_signal('dash_started', self)
	
func _on_Dashing_disabled():
	dash_restore_appearance()
	emit_signal('dash_ended', self)
	
#func _on_Phasing_enabled():
#	modulate = Color(1,0,1)
#	global.arena.show_msg(species, 'PHASE', position)

#func _on_Phasing_disabled():
#	modulate = Color(1,1,1)
#	global.arena.show_msg(species, 'END', position)
	
func _on_bomb_freed():
	bomb_count -= 1


signal thrusters_on
signal thrusters_off

func _on_Thrusters_disabled():
	emit_signal('thrusters_off')

func _on_Thrusters_enabled():
	emit_signal('thrusters_on')

signal fallen
func fall():
	emit_signal('fallen', self, spawner)
	
func next_symbol():
	symbol = Bubble.symbols[randi()%len(Bubble.symbols)]
	if randf() < 0.08:
		symbol = 'none' # slight chance of no-symbol bubble
	$Graphics/ChargeBar/BombPreview.modulate = Bubble.symbol_colors[symbol]
	$Graphics/ChargeBar/BombPreview/Symbol.texture = load('res://assets/sprites/alchemy/'+symbol+'.png')

func _on_Shields_hit(by):
	rebound((global_position-by.global_position).normalized(), 1500.0)
	if has_method('vibration_feedback'):
		call('vibration_feedback', false)

func wield_sword():
	$Sword.set_active(true)
	
func unwield_sword():
	$Sword.set_active(false)
	
func wield_magnet():
	$Magnet.set_active(true)
	
func unwield_magnet():
	$Magnet.set_active(false)
	
func wield_scythe():
	if $RightScythe.active:
		$LeftScythe.set_active(true)
	else:
		$RightScythe.set_active(true)
	
func unwield_scythe():
	if $LeftScythe.active:
		$LeftScythe.set_active(false)
	else:
		$RightScythe.set_active(false)
	
const Flail = preload('res://actors/weapons/Flail.tscn')
var the_flail = null
func wield_flail():
	the_flail = Flail.instance()
	the_flail.position = global_position
	the_flail.rotation = global_rotation
	get_parent().add_child(the_flail)
	the_flail.hook_to = get_path()
	
func unwield_flail():
	if the_flail != null:
		the_flail.queue_free()
		the_flail = null
		
func wield_drill():
	$Drill.set_active(true)
	set_bombs_enabled(false)
	update_weapon_indicator()
	
func unwield_drill():
	$Drill.set_active(false)
	
const PowerupScene = preload("res://combat/collectables/PowerUp.tscn")

func drop_powerup(type):
	var powerup = PowerupScene.instance()
	powerup.type = type
	powerup.appear = false
	var behind = Vector2(-1,0).rotated(global_rotation)
	powerup.position = global_position + 150*behind
	powerup.linear_velocity = 300*behind
	# ugly
	get_parent().get_parent().add_child(powerup)

var current_exclusive_powerup_type := ''
func apply_powerup(powerup):
	if current_exclusive_powerup_type != '' and PowerUp.is_exclusive(current_exclusive_powerup_type) and PowerUp.is_exclusive(powerup.type):
		# drop the old powerup
		drop_powerup(current_exclusive_powerup_type)
		
	if PowerUp.is_exclusive(powerup.type):
		current_exclusive_powerup_type = powerup.type
		
		# FIXME
		if powerup.type != 'drill':
			set_bombs_enabled(true)
			unwield_drill()
	
	var success = true
	if powerup.type in ['shield', 'shields', 'plate', 'skin']:
		success = $Shields.up(powerup.type)
		if not success:
			# drop unused powerup
			drop_powerup(powerup.type)
			
	elif powerup.type == 'magnet':
		wield_magnet()
	elif powerup.type == 'snake':
		entity.get('Thrusters').disable()
		deadly_trail_powerup = true
		update_weapon_indicator()
		entity.get('Thrusters').enable()
		# FIXME? should water disable the tail?
	elif powerup.type == 'kamikaze':
		auto_thrust = true
	elif powerup.type == 'sword':
		wield_sword()
	elif powerup.type == 'scythe':
		wield_scythe()
	elif powerup.type == 'flail':
		wield_flail()
	elif powerup.type == 'drill':
		wield_drill()
	elif powerup.type == 'rocket_gun':
		set_bomb_type(GameMode.BOMB_TYPE.classic)
		update_weapon_indicator()
	elif powerup.type == 'miniball_gun':
		set_bomb_type(GameMode.BOMB_TYPE.ball)
		update_weapon_indicator()
	elif powerup.type == 'spike_gun':
		set_bomb_type(GameMode.BOMB_TYPE.bullet)
		update_weapon_indicator()
	elif powerup.type == 'bomb':
		set_bomb_type(GameMode.BOMB_TYPE.mine)
		update_weapon_indicator()
	elif powerup.type == 'wave_gun':
		set_bomb_type(GameMode.BOMB_TYPE.wave)
		update_weapon_indicator()
	elif powerup.type == 'bubble_gun':
		set_bomb_type(GameMode.BOMB_TYPE.bubble)
		update_weapon_indicator()
		
	if powerup.has_category('weapon'):
		$WeaponSlot.wield(powerup.type)
		
	if success:
		global.arena.show_msg(species, powerup.type.to_upper().replace('_',' '), global_position)
		
func rebound(direction = null, strength := 2000.0):
	if direction == null:
		direction = Vector2(-1,0).rotated(rotation)
	apply_central_impulse(strength*direction)
	
func get_deadly_trail():
	return deadly_trail_powerup or deadly_trail
	
func get_bombs_enabled():
	return bombs_enabled and not get_deadly_trail()
	
func update_weapon_indicator():
	$Graphics/ChargeBar/BombPreview.visible = get_bombs_enabled()
	
	
func tap():
	Events.emit_signal('tap', self)
	#switch_emersion_state()
	trigger_all_my_stuff()
	
var under = false

func switch_emersion_state():
	if under:
		emerge()
	else:
		submerge()
	
func submerge():
	under = true
	z_as_relative = false
	z_index = -50
	set_collision_layer_bit(0, false)
	set_collision_layer_bit(18, true)
	
func emerge():
	under = false
	z_as_relative = true
	z_index = 0
	set_collision_layer_bit(0, true)
	set_collision_layer_bit(18, false)
	
signal frozen
func freeze():
	if alive and not invincible:
		emit_signal("frozen", self)
		
func _on_bomb_expired(bomb_position):
	# if no autoreload, reload after bomb expired
	if reload_time < 0:
		ammo.reload()
		

func _on_Ship_near_area_entered(sth, this):
	if sth is ArkaBall:
		sth.queue_free()
		start_golf()

func start_golf():
	golf = true
	yield(get_tree().create_timer(0.5), "timeout")
	charge()

func get_player():
	return info_player
	
func is_in_gel():
	for area in $NearArea.get_overlapping_areas():
		if traits.has_trait(area, 'Gel'):
			return true
	return false
	
func is_aiming_away_gel():
	for area in $NearArea.get_overlapping_areas():
		if traits.has_trait(area, 'Gel'):
			if not area.is_escapable():
				return false
			return abs(wrapf(area.rotation-rotation,-PI,PI)) < area.get_half_angle()
	return true

signal done
func intro():
	enable_controls()
	make_invincible()
	yield(get_tree(), "idle_frame")
	emit_signal('done')

func disable_controls():
	controls_enabled = false
	
func enable_controls():
	controls_enabled = true
	
func is_auto_thrust() -> bool:
	return auto_thrust or deadly_trail_powerup

func is_piercing() -> bool:
	return $Sword.get_active()
	
func get_cargo():
	return $Cargo

# some collisions must be checked every frame
func continuous_collision_check():
	var overlappers = $NearArea.get_overlapping_bodies() + $NearArea.get_overlapping_areas()
	for sth in overlappers:
		if traits.has_trait(sth, 'Holdable') or traits.has_trait(sth, 'Dropper'):
			Events.emit_signal('sth_is_overlapping_with_ship', sth, self)

func trigger_all_my_stuff():
	for triggerable in traits.get_all_with('RemoteTriggerable'):
		if triggerable.get_owner_ship() == self:
			triggerable.detonate()
			
func get_target_destination():
	return $TargetDest.global_position

const CAMERA_RECT_SIZE := 800.0
func get_camera_rect() -> Rect2:
	return Rect2(global_position - Vector2(CAMERA_RECT_SIZE,CAMERA_RECT_SIZE)/2, Vector2(CAMERA_RECT_SIZE,CAMERA_RECT_SIZE))

func get_team() -> String:
	return info_player.team
	
