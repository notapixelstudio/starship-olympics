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

var spawner
var trail
var species_name: String
var scores

var cpu = false
var velocity = Vector2(0,0)
var previous_velocity = Vector2(0,0)
var target_velocity = Vector2(0,0)
var steer_force = 0
var rotation_dir = 0

var THRUST = 3100

var shields = 0
var max_shields = 1
var deadly_trail = false
var deadly_trail_powerup = false

var charge = 0
var actual_charge = 0
const max_steer_force = 2500
const MAX_CHARGE = 0.6
const MIN_DASHING_CHARGE = 0.13
const DASH_INTERCOOLDOWN = 0.5
const MAX_OVERCHARGE = 1.3
const CHARGE_BASE = 250
const ANTI_RECOIL_OFFSET = 1000
const CHARGE_MULTIPLIER = 4500
const DASH_MULTIPLIER = 1.5
const BOMB_OFFSET = 50
const BOMB_BOOST = 200
const BALL_BOOST = 750
const BALL_CHARGE_MULTIPLIER = 1.4
const BULLET_BOOST = 750
const BULLET_CHARGE_MULTIPLIER = 1.2
const FIRE_COOLDOWN = 0.03
const OUTSIDE_COUNTUP = 3.0

var supercharge = 0

const THRESHOLD_DIR = 0.3
const ROTATION_TORQUE = 20000

var responsive = false setget change_engine
var info_player setget set_info_player

func set_info_player(value):
	info_player = value
	species = info_player.species
	species_name = info_player.species_name

var count = 0
var alive = true
var stunned = false
var stun_countdown = 0
var outside_countup = 0


var screen_size = Vector2()
var width = 0
var height = 0

var charging = false
var fire_cooldown = FIRE_COOLDOWN
var dash_cooldown = 0
var dash_intercooldown = 0
var reload_time

var bomb_count = 0

var teleport_to = null

onready var player = name
onready var skin = $Graphics
onready var charging_sfx = $charging
onready var ammo = $PlayerInfo.ammo
onready var target_dest = $TargetDest


const dead_ship_scene = preload("res://actors/battlers/DeadShip.tscn")

var dead_ship_instance

signal dead
signal stop_invincible
signal spawn_bomb
var invincible : bool

var entity : Entity
var camera

var weapon_textures = {
	GameMode.BOMB_TYPE.classic: preload('res://assets/sprites/interface/charge_rocket.png'),
	GameMode.BOMB_TYPE.ball: preload('res://assets/sprites/interface/charge_ball.png'),
	GameMode.BOMB_TYPE.bullet: preload('res://assets/sprites/interface/charge_bullet.png'),
	GameMode.BOMB_TYPE.bubble: preload('res://assets/sprites/interface/charge_bubble.png'),
	GameMode.BOMB_TYPE.dasher: preload('res://assets/sprites/interface/charge_ball.png')
}

var symbol

func initialize():
	pass

signal spawned
var bombs_enabled : bool = true setget set_bombs_enabled
var bomb_type

func set_bombs_enabled(value: bool):
	bombs_enabled = value
	
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

func _enter_tree():
	charging = false
	charge = 0
	alive = true
	outside_countup = 0
	
	update_weapon_indicator()
	
	emit_signal('spawned', self)
	dash_init_appearance()
	make_invincible()
	
func make_invincible():
	invincible = true
	if skin:
		skin.invincible()
	yield(get_tree().create_timer(0.1), "timeout")
	yield(skin, "stop_invincible")
	invincible = false
	
func _ready():
	dead_ship_instance = dead_ship_scene.instance()
	dead_ship_instance.ship = self
	skin.ship_texture = species.ship
	skin.invincible(1.0)
	entity = ECM.E(self)
	species_name = species.species_name
	
	entity.get('Conqueror').set_species(self)
	self.responsive = true
	
	var dash_process_material = $DashParticles.process_material.duplicate(true)
	var transparent_color = Color(species.color_2)
	transparent_color.a = 0
	dash_process_material.color_ramp.gradient.set_color(0, species.color)
	dash_process_material.color_ramp.gradient.set_color(1, transparent_color)
	$DashParticles.process_material = dash_process_material
	
func change_engine(value: bool):
	responsive = value
	set_physics_process(responsive)
	
func _process(delta):
	if bomb_type == GameMode.BOMB_TYPE.bubble:
		$Graphics/ChargeBar/BombPreview.rotation = -global_rotation
	
static func magnitude(a:Vector2):
	return sqrt(a.x*a.x+a.y*a.y)
	
func _integrate_forces(state):
	if not responsive:
		return
	set_applied_force(Vector2())
	steer_force = max_steer_force * rotation_dir
	
	if not absolute_controls:
		add_central_force(Vector2(THRUST, steer_force).rotated(rotation)*int(entity.has('Thrusters') and not charging and not stunned)) # thrusters switch off when charging
		# rotation = atan2(target_velocity.y, target_velocity.x)
	else:
		#rotation = state.linear_velocity.angle()
		#apply_impulse(Vector2(),target_velocity*THRUST)	
		add_central_force(target_velocity*THRUST*int(entity.has('Thrusters') and not charging and not stunned))
		
	if entity.has('Flowing'):
		apply_impulse(Vector2(), entity.get_node('Flowing').get_flow().get_flow_vector(position))
		
	set_applied_torque(rotation_dir * ROTATION_TORQUE)
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
	state.set_transform(xform)

func control(_delta):
	update_charge_bar()
	
func update_charge_bar():
	if not charging:
		$Graphics/ChargeBar/Charge.visible = false
		return
		
	$Graphics/ChargeBar/Charge.visible = true
	
	# charge feedback
	var v = $Graphics/ChargeBar/ChargeAxis.points[1] * min(charge,MAX_CHARGE)/MAX_CHARGE
	$Graphics/ChargeBar/Charge.set_point_position(1, v)
	$Graphics/ChargeBar/ChargeBackground.set_point_position(1, v)
	$Graphics/ChargeBar/Charge/ArrowTip.position.x = v.x+26
	
	# overcharge feedback
	if charge > MAX_CHARGE + (MAX_OVERCHARGE-MAX_CHARGE)/2:
		var visible = int(floor(charge * 15)) % 2
		$Graphics/ChargeBar/Charge.visible = visible

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
	dash_intercooldown -= delta
	if dash_cooldown <= 0 and entity.get('Dashing').enabled:
		dash_restore_appearance()
		yield(get_tree().create_timer(0.08), 'timeout') # wait a bit to be lenient with dash-through checks
		entity.get('Dashing').disable()
		
var will_fire
func charge():
	charging = true
	#$GravitonField.enabled = true
	charging_sfx.play()
	dash_fat_appearance()
	will_fire = get_bombs_enabled() and (ammo.max_ammo == -1 or ammo.current_ammo > 0)
	if will_fire:
		$Graphics/ChargeBar/Charge.modulate = Color(1, 0.376471, 0)
		if bomb_type != GameMode.BOMB_TYPE.bubble:
			$Graphics/ChargeBar/BombPreview.modulate = Color(1, 0.376471, 0)
		$Graphics/ChargeBar/BombPreview.self_modulate = Color(1,1,1,1)
	else:
		$Graphics/ChargeBar/Charge.modulate = Color(1,1,0)
	
func fire(override_charge = -1, dash_only = false):
	"""
	Fire a bomb
	"""
	var should_reload = false
	
	actual_charge = override_charge if override_charge > 0 else charge
	var charge_impulse = supercharge + CHARGE_BASE + CHARGE_MULTIPLIER * min(actual_charge, MAX_CHARGE)
	
	# - (CHARGE_BASE + ANTI_RECOIL_OFFSET) is to avoid too much acceleration when repeatedly firing bombs
	apply_impulse(Vector2(0,0), Vector2(max(0, charge_impulse*DASH_MULTIPLIER - (CHARGE_BASE + ANTI_RECOIL_OFFSET)), 0).rotated(rotation)) # recoil
	
	if get_bombs_enabled() and not dash_only:
		bomb_count += 1
		if will_fire:
			ammo.shot()
			should_reload = true
			var impulse
			if bomb_type == GameMode.BOMB_TYPE.ball:
				impulse = charge_impulse*BALL_CHARGE_MULTIPLIER+BALL_BOOST
			elif bomb_type == GameMode.BOMB_TYPE.bullet:
				impulse = charge_impulse*BULLET_CHARGE_MULTIPLIER+BULLET_BOOST
			elif bomb_type == GameMode.BOMB_TYPE.bubble:
				impulse = charge_impulse
			else:
				impulse = charge_impulse+BOMB_BOOST
				
			if bomb_type != GameMode.BOMB_TYPE.dasher or actual_charge > 0.2:
				emit_signal("spawn_bomb", bomb_type, symbol, position + Vector2(-BOMB_OFFSET,0).rotated(rotation),
					Vector2(-impulse,0).rotated(rotation))
					
			if bomb_type == GameMode.BOMB_TYPE.bubble:
				next_symbol()
	
	# repeal
	#$GravitonField.repeal(charge_impulse)
	#$GravitonField.enabled = false
	
	charging = false
	$Graphics/ChargeBar/ChargeAxis.visible = false
	$Graphics/ChargeBar/Charge.set_point_position(1, Vector2(0,0))
	$Graphics/ChargeBar/ChargeBackground.set_point_position(1, Vector2(0,0))
	if bomb_type != GameMode.BOMB_TYPE.bubble:
		$Graphics/ChargeBar/BombPreview.modulate = species.color
	$Graphics/ChargeBar/BombPreview.self_modulate = Color(1,1,1,0.5)
	
	fire_cooldown = FIRE_COOLDOWN
	charging_sfx.stop()
	$Tween.stop_all()
	$Graphics/Sprite.scale = DASH_RESTORED
	
	if actual_charge > MIN_DASHING_CHARGE and dash_intercooldown <= 0:
		entity.get('Dashing').enable()
		dash_cooldown = (actual_charge - MIN_DASHING_CHARGE)*0.6
		dash_intercooldown = DASH_INTERCOOLDOWN
	else:
		tap()
		
	if should_reload:
		yield(get_tree().create_timer(reload_time), "timeout")
		ammo.reload()
		
func die(killer : Ship, for_good = false):
	if alive and not invincible:
		if shields > 0:
			lower_shield()
			make_invincible()
			rebound()
			if has_method('vibration_feedback'):
				call('vibration_feedback', false)
			return
			
		alive = false
		
		# powerups wear off
		deadly_trail_powerup = false
		
		# skin.play_death()
		# deactivate controls and whatnot and wait for the sound to finish
		yield(get_tree(), "idle_frame")
		if info_player.lives >= 0:
			info_player.lives -= 1
		emit_signal("dead", self, killer, for_good)
		
func stun():
	stunned = true
	stun_countdown = 0.3
	
func unstun():
	stunned = false
	stun_countdown = 0
	
signal near_area_entered
func _on_NearArea_area_entered(area):
	emit_signal("near_area_entered", area, self)
func _on_NearArea_body_entered(body):
	emit_signal("near_area_entered", body, self)
	
signal near_area_exited
func _on_NearArea_area_exited(area):
	emit_signal("near_area_exited", area, self)
func _on_NearArea_body_exited(body):
	emit_signal("near_area_exited", body, self)
	
func is_alive():
	return alive

func update_score(species_template, score, pos):
	$PlayerInfo.update_score(score)
	
static func find_side(a: Vector2, b: Vector2, check: Vector2) -> float:
	"""
	Given two points a, b will return the side check is on.
 	@return integer code for which side of the line ab c is on.  
	1 means left turn, -1 means right turn.  Returns
 	0 if all three are on a line (THRESHOLD will adjust the wiggle in movements)
	"""
	var possible_dirs : Array = [-1,1]
	var cross = (b.x - a.x)*(check.y-a.y) - (b.y - a.y)*(check.x-a.x)
	if (check + b).length() < 0.1: # FIXME const
	#if check == -b:
		cross = possible_dirs[randi()%len(possible_dirs)]

	if cross > -THRESHOLD_DIR and cross < THRESHOLD_DIR:
		if sign(check.y)==sign(b.y) or sign(b.x) == sign(check.x) :
			return cross # smooth adjustment
	
	#return cross
	return sign(cross) # coarse adjustment

func get_id():
	return info_player.id

func recheck_colliding():
	for body in $NearArea.get_overlapping_bodies():
		_on_NearArea_body_entered(body)
	for area in $NearArea.get_overlapping_areas():
		_on_NearArea_area_entered(area)

const DASH_RESTORED = Vector2(1,1)
const DASH_THIN = Vector2(1.5,0.5)
const DASH_FAT = Vector2(0.8,1.2)

func dash_init_appearance():
	$Tween.stop_all()
	$Graphics/Sprite.scale = DASH_RESTORED
	$DashParticles.restart()
	$DashParticles.emitting = false
	$DashParticles.visible = false
	
func dash_restore_appearance():
	$Tween.stop_all()
	$Tween.interpolate_property($Graphics/Sprite, "scale", $Graphics/Sprite.scale, DASH_RESTORED, 0.5,
		Tween.TRANS_CUBIC, Tween.EASE_OUT, 0)
	$Tween.start()
	$DashFxTimer.start(0.1)
	yield($DashFxTimer, 'timeout')
	$DashParticles.emitting = false
	
func dash_fat_appearance():
	$Tween.stop_all()
	$Tween.interpolate_property($Graphics/Sprite, "scale", $Graphics/Sprite.scale, DASH_FAT, MAX_CHARGE,
		Tween.TRANS_QUAD, Tween.EASE_OUT, 0)
	$Tween.start()
	
func dash_thin_appearance():
	$DashFxTimer.stop()
	# don't show particles if dash is small (useful to have a more lenient dash)
	if actual_charge > 0.25:
		$Graphics/Sprite.scale = DASH_THIN
		$DashParticles.emitting = true
		$DashParticles.visible = true
	
func _on_Dashing_enabled():
	dash_thin_appearance()
	
func _on_Dashing_disabled():
	dash_restore_appearance()
	
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

func raise_shield(amount = 1):
	shields = min(max_shields, amount)
	$PlayerInfo.update_shields(shields)
	$Graphics/Sprite.material.set_shader_param('active', true)
	$Graphics/Sprite/AnimationPlayer.play('appear')
	yield($Graphics/Sprite/AnimationPlayer, 'animation_finished')
	$Graphics/Sprite/AnimationPlayer.play('blink')
	
func lower_shield(amount = 1):
	shields = max(0, shields - amount)
	$PlayerInfo.update_shields(shields)
	if shields == 0:
		$Graphics/Sprite/AnimationPlayer.play('cancel')
		yield($Graphics/Sprite/AnimationPlayer, 'animation_finished')
		$Graphics/Sprite.material.set_shader_param('active', false)
		$Graphics/Sprite/AnimationPlayer.stop()
	
func apply_powerup(powerup):
	if powerup.type == 'shield':
		raise_shield()
	elif powerup.type == 'snake':
		entity.get('Thrusters').disable()
		deadly_trail_powerup = true
		update_weapon_indicator()
		entity.get('Thrusters').enable()
		recheck_colliding()
		
func rebound():
	apply_central_impulse(Vector2(-2000,0).rotated(rotation))
	
func get_deadly_trail():
	return deadly_trail_powerup or deadly_trail
	
func get_bombs_enabled():
	return bombs_enabled and not get_deadly_trail()
	
func update_weapon_indicator():
	$Graphics/ChargeBar/BombPreview.visible = get_bombs_enabled()
	
	
func tap():
	pass
	#switch_emersion_state()
	
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
	
