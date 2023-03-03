tool
extends RigidBody2D
"""
Node for the RigidBody and Ship physics
it will get as export variable the battle template (containing the species values)
and its keyboard control
"""
class_name Ship

export var debug_enabled = false
export (String, 'kb1', 'kb2', 'joy1', 'joy2', 'joy3', 'joy4') var controls = "kb1"
export var absolute_controls : bool= true
export var species : Resource

export var forward_bullet_scene : PackedScene
export var atom_texture : Texture

var controls_enabled = false

var spawner
var trail

var cpu = false
var velocity := Vector2(0,0)
var previous_velocity := Vector2(0,0)
var last_contact_normal = null
var steer_force = 0
var drift := Vector2(0,0)
var drifting := false

var THRUST = 6500
var auto_thrust := false
var thrust_multiplier := 1.0

var deadly_trail = false
var deadly_trail_powerup = false

var golf = false
var phasing_in_prevented := false

var charge = 0
var actual_charge = 0
const max_steer_force = 2500
const MAX_CHARGE = 0.6
const MAX_OVERCHARGE = 1.8
const MIN_CHARGE = 0.2
const MAX_TAP_CHARGE = 0.3
const CHARGE_BASE = 250
const CHARGE_MULTIPLIER = 7000
const DASH_BASE = -400
const DASH_MULTIPLIER = 2.6 # was 2.7, decreased to lessen the chance of tunneling
const BOMB_OFFSET = 50
const BOMB_BOOST = 1600
const BALL_BOOST = 2300
const BOMB_CHARGE_MULTIPLIER = 1.65
const BALL_CHARGE_MULTIPLIER = 2.2
const BULLET_BOOST = 1600
const BULLET_CHARGE_MULTIPLIER = 1.65
const BUBBLE_BOOST = 1200
const FIRE_COOLDOWN = 0.03
const OUTSIDE_COUNTUP = 3.0
const ARKABALL_OFFSET = 200
const ARKABALL_MULTIPLIER = 1.5
const MAGNETIC_OFFSET = 200
const MAGNETIC_MULTIPLIER = 1.5
const ON_ICE_MAX_THRUST = 2200
const ON_ICE_MAX_DASH = 2500
const ON_ICE_CHARGE_BRAKE = 0.99
const MIN_DRIFT := 400.0

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
var charging_too_much_for_tap = false
var fire_cooldown = FIRE_COOLDOWN
var dash_cooldown = 0
var phasing_cooldown = 0

var game_mode : GameMode

var teleport_to = null

onready var player = name
onready var skin = $Graphics
onready var charging_sfx = $charging
onready var target_dest = $TargetDest


const dead_ship_scene = preload("res://actors/battlers/DeadShip.tscn")

var dead_ship_instance

const arkaball_scene = preload('res://actors/environments/ArkaBall.tscn')

signal dead
signal stop_invincible
signal spawn_bomb

signal dash_started
signal dash_ended

signal drift_started
signal drift_ended

signal bump
signal collect

var invincible : bool
var start_invincible := true

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
	update_weapon_indicator()
	
func set_default_bomb_type(value):
	default_bomb_type = value
	set_bomb_type(value)
	
func set_bomb_type(value):
	bomb_type = value
	update_weapon_indicator()
	if bomb_type != GameMode.BOMB_TYPE.bubble:
		$Graphics/ChargeBar/BombPreview/BombType.modulate = species.color
	else:
		next_symbol()
	
func set_start_invincible(v: bool) -> void:
	start_invincible = v
	
func set_ammo(value):
	$'%Ammo'.set_max_ammo(value)
	$'%Ammo'.replenish()
	
func set_reload_time(value):
	$'%Ammo'.set_reload_time(value)
	
func set_lives(value: int):
	info_player.lives = value
	
func set_max_health(value: int):
	max_health = value
	reset_health()
	
func reset_health():
	$PlayerInfo.reset_health(max_health)
	self.set_health(max_health)

func _enter_tree():
	alive = true
	outside_countup = 0
	empty_loaded_shot()
	unhide()
	
	reset_health()
	
	update_weapon_indicator()
	
	# shields always start off
	$Shields.switch_off()
	
	emit_signal('spawned', self)
	dash_init_appearance()
	if controls_enabled and start_invincible:
		make_invincible()
		
	$AutoTrail.starting_color = Color(species.color.r, species.color.g, species.color.b, 0.35)
	$AutoTrail.ending_color = Color(species.color.r, species.color.g, species.color.b, 0.0)
	$FlameAutoTrail.starting_color = Color(species.color.r, species.color.g, species.color.b, 0.5)
	$FlameAutoTrail.ending_color = Color(species.color.r, species.color.g, species.color.b, 0.0)
	
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
	
	reset_charge()
	
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
	steer_force = max_steer_force * get_rotation_request()
	
	var thrusting = not is_in_gel() and not golf and entity.has('Thrusters') and not charging_enough and not stunned # and not entity.has('Dashing') # thrusters switch off when charging enough (and during dashes)
	
	# check if we need to limit thrust
	var thrust = THRUST
	if is_on_ice():
		thrust = min(thrust, ON_ICE_MAX_THRUST)
		
	if not absolute_controls:
		add_central_force(Vector2(thrust, steer_force).rotated(rotation)*int(thrusting))
		# rotation = atan2(target_velocity.y, target_velocity.x)
	else:
		#rotation = state.linear_velocity.angle()
		#apply_impulse(Vector2(),target_velocity*thrust)
		add_central_force(get_target_velocity()*thrust*int(thrusting))
		
	if entity.has('Flowing'):
		apply_impulse(Vector2(), entity.get_node('Flowing').get_flow().get_flow_vector(position))
		
	# setting a maximum torque should prevent ship oscillation
	set_applied_torque(min(PI/2, get_rotation_request()) * ROTATION_TORQUE) # * int(not entity.has('Dashing'))) # can't steer while dashing
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
	
	if is_on_ice():
		# brake if charging on ice
		if charging:
			state.linear_velocity *= ON_ICE_CHARGE_BRAKE
			
		# compute drift velocity (only when piloting)
		if get_target_velocity().length() > 1.0:
			drift = state.linear_velocity.project(Vector2.DOWN.rotated(global_rotation))
		else:
			drift = Vector2(0,0)
			
		if not drifting and drift.length() > MIN_DRIFT:
			start_drift()
			
	if drifting and drift.length() <= MIN_DRIFT or not is_on_ice():
		end_drift()
		
#	if charging:
#		set_size(min(1.0+2.0*charge, 5.0))
#	else:
#		set_size(1.0)
	
	# store velocity as a readable var
	previous_velocity = velocity
	velocity = state.linear_velocity
	
	traits.get_trait(self, 'Tracked').tick()
	
	# store last contact normal as a readable var
	if state.get_contact_count() > 0:
		last_contact_normal = state.get_contact_local_normal(0)
	
	state.set_transform(xform)
	
	if velocity.length() > 0.01:
		unhide()
	elif is_hiding():
		modulate.a = modulate.a*0.99
	
var overcharging := false
signal overcharging_started
func update_charge_bar():
	if not charging_enough:
		$Graphics/ChargeBar/Charge.visible = false
		$"%ShootingLine".visible = false
		$"%ShootingLine".enabled = false
		overcharging = false
		return
		
	$Graphics/ChargeBar/Charge.visible = true
	$Graphics/ChargeBar/Charge.modulate = Color(1,1,1,1)
	
	# charge feedback
	var v = $Graphics/ChargeBar/ChargeAxis.points[1] * min(charge,MAX_CHARGE)/MAX_CHARGE
	$Graphics/ChargeBar/Charge.set_point_position(1, v)
	$Graphics/ChargeBar/ChargeBackground.set_point_position(1, Vector2(v.x+4, v.y))
	if bombs_enabled or golf:
		$"%ArrowTip".position.x = v.x+26
	else:
		$"%ArrowTip".position.x = $Graphics/ChargeBar/ChargeAxis.points[0].x+50
	
	# shooting line visible only when charging enough enough
	$"%ShootingLine".visible = charge > MIN_CHARGE*2
	$"%ShootingLine".enabled = charge > MIN_CHARGE*2
	
	# overcharge feedback
	if charge > MAX_CHARGE:
		if golf:
			var visible = int(floor(charge * 15)) % 2
			$Graphics/ChargeBar/Charge.modulate = Color(1,1,1,1) if visible else Color(0,0,0,1)
		if not overcharging:
			overcharging = true
			emit_signal("overcharging_started")
			
	if charge > MAX_OVERCHARGE and golf:
		# golf wait in overcharge for a bit, then fires
		fire()

signal detection
func _physics_process(delta):
	# let the brain read the player's input or compute its move
	do_brain_tick()
	
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
		
	# charge
	if charging:
		charge = charge+delta
	else:
		charge = 0
		
	# overcharge
	#if charge > MAX_OVERCHARGE:
	#	fire()
	
	update_charge_bar()
	
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
		phase_in()
	
	if dash_cooldown <= 0 and entity.get('Dashing').enabled:
		#dash_restore_appearance()
		entity.get('Dashing').disable()
		
	if charging and not charging_enough and charge > MIN_CHARGE:
		charging_enough = true
		#$GravitonField.enabled = true
		charging_sfx.play()
		dash_fat_appearance()
		
	if charging and not charging_too_much_for_tap and charge > MAX_TAP_CHARGE:
		charging_too_much_for_tap = true
		
signal charging_started
func charge():
	charging = true
	emit_signal("charging_started")
	
	# check if we catch anything with a magnetic field
	for area in $NearArea.get_overlapping_areas():
		if traits.has_trait(area, 'Magnetic'):
			load_shot(area.get_body())
			break # just one
	
	if get_bombs_enabled() and not $'%Ammo'.is_empty():
		$'%BombPreview/BombType'.self_modulate = Color(1,1,1,1)
	
signal charging_ended
func fire(override_charge = -1, dash_only = false):
	"""
	Fire a bomb
	"""
	actual_charge = override_charge if override_charge > 0 else charge
	var charge_impulse = CHARGE_BASE + CHARGE_MULTIPLIER * clamp(actual_charge - MIN_CHARGE, 0, MAX_CHARGE)
	var will_dash = charging_enough and is_aiming_away_gel()
	
	if will_dash:
		var recoil = max(0,DASH_BASE+charge_impulse*DASH_MULTIPLIER)
		# check if we need to limit dash
		if is_on_ice():
			recoil = min(recoil, ON_ICE_MAX_DASH)
		apply_impulse(Vector2(0,0), Vector2(recoil, 0).rotated(rotation)) # recoil only if dashing
	
	if golf:
		var impulse = charge_impulse*ARKABALL_MULTIPLIER
		var arkaball = arkaball_scene.instance()
		arkaball.position = position + Vector2(-ARKABALL_OFFSET,0).rotated(rotation)
		arkaball.apply_central_impulse(Vector2(-impulse,0).rotated(rotation))
		get_parent().add_child(arkaball)
		arkaball.set_ship(self)
		arkaball.start()
		golf = false
		update_weapon_indicator()
	elif get_bombs_enabled() and not dash_only:
		if get_bombs_enabled() and not $'%Ammo'.is_empty():
			$'%Ammo'.shot()
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
	elif loaded_shot != null:
		var impulse = charge_impulse*MAGNETIC_MULTIPLIER
		loaded_shot.position = position + Vector2(-MAGNETIC_OFFSET,0).rotated(rotation)
		loaded_shot.linear_velocity = Vector2.ZERO
		loaded_shot.apply_central_impulse(Vector2(-impulse,0).rotated(rotation))
		get_parent().add_child(loaded_shot)
		empty_loaded_shot()
	
	# repeal
	#$GravitonField.repeal(charge_impulse)
	#$GravitonField.enabled = false
	
	if not charging_too_much_for_tap:
		tap()
	
	reset_charge()
	emit_signal("charging_ended")
	
	fire_cooldown = FIRE_COOLDOWN
	charging_sfx.stop()
	$Tween.remove_all()
	$Graphics/Sprite.scale = DASH_RESTORED
	
	if will_dash:
		entity.get('Dashing').enable()
		dash_cooldown = (min(actual_charge, MAX_CHARGE) - MIN_CHARGE)*0.6
		phasing_cooldown = 0.2 # wait a bit to be lenient with phase-through checks
		
func reset_charge():
	charge = 0
	charging = false
	charging_enough = false
	charging_too_much_for_tap = false
	
	$Graphics/ChargeBar/Charge.visible = false
	$Graphics/ChargeBar/ChargeAxis.visible = false
	$Graphics/ChargeBar/Charge.set_point_position(1, Vector2(0,0))
	$Graphics/ChargeBar/ChargeBackground.set_point_position(1, Vector2(0,0))
	$Graphics/ChargeBar/BombPreview/BombType.self_modulate = Color(1,1,1,0.5)
	$"%ShootingLine".visible = false
	$"%ShootingLine".enabled = false
	
func set_health(amount : int) -> void:
	health = amount
	$PlayerInfo.update_health(amount)
	
func damage(hazard, damager : Ship, damager_team : String = ''):
	if invincible or not alive or damager_team == get_team(): # self or teammates hits have no effect
		return
		
	# always rebound on hit
	if(hazard.get('linear_velocity') == null):
		rebound((global_position-hazard.global_position).normalized(), 2500.0)
	else:
		rebound(Vector2(1,0).rotated(hazard.linear_velocity.angle()), 2500.0)
	
	if has_method('vibration_feedback'):
		call('vibration_feedback', false)
		
	# check if we lose cargo instead
	if get_cargo().has_holdable():
		get_cargo().drop_holdable(hazard)
		return
	
	self.set_health(health - 1)
	
	if health < -1:
		self.set_health(-1)
		
	if health == 0:
		die(damager)
	else:
		$'%AnimationPlayer'.play('hit')
		
		Events.emit_signal("ship_damaged", self, hazard, damager)
		
		# slight, invisible invincibility
		invincible = true
		yield(get_tree().create_timer(0.1), "timeout")
		invincible = false
	
func die(killer : Ship, for_good = false):
	if alive and not invincible:
		alive = false
		
		reset_charge()
		
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
	if body.has_method('on_ship_near_area_hit'):
		body.on_ship_near_area_hit(self)
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
	phase_out()
	
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


signal thrusters_on
signal thrusters_off

func _on_Thrusters_disabled():
	emit_signal('thrusters_off')
	$FlameAutoTrail.drop_trail()
	$InnerFlameAutoTrail.drop_trail()

func _on_Thrusters_enabled():
	emit_signal('thrusters_on')
	$FlameAutoTrail.create_trail()
	$InnerFlameAutoTrail.create_trail()

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
	if bomb_type == GameMode.BOMB_TYPE.fw_pew:
		# show fw weapon indicator
		return
	$Graphics/ChargeBar/BombPreview/BombType.texture = weapon_textures[bomb_type] if bomb_type != null else null
	$"%BombPreview".visible = get_bombs_enabled() or golf
	$"%BombPreview/BombType".visible = get_bombs_enabled() or golf
	$"%ArrowTip".flip_v = not (get_bombs_enabled() or golf)
	if golf:
		$"%BombPreview/BombType".texture = atom_texture
		$"%BombPreview/BombType".scale = Vector2(1.1,1.1)
		$'%BombPreview/BombType'.self_modulate = Color(1,1,1,1)
	else:
		$"%BombPreview/BombType".scale = Vector2(0.7,0.7) # WARNING hardcoded default
	
func tap():
	Events.emit_signal('tap', self)
	#switch_emersion_state()
	trigger_all_my_stuff()
	
	if bomb_type == GameMode.BOMB_TYPE.fw_pew and not $'%Ammo'.is_empty():# and not is_hiding():
		$'%Ammo'.shot()
		var aperture = PI/4
		var amount = 1
		var aim_correction = 0.65
		for i in range(amount):
			var aim_angle = (aim_correction*get_target_velocity().normalized() + (1-aim_correction)*Vector2.RIGHT.rotated(global_rotation)).angle() if get_target_velocity().length() > 0.6 else global_rotation
			var angle = aim_angle + ( -aperture/2 + i*aperture/(amount-1) if amount > 1 else 0)
			var bullet = forward_bullet_scene.instance()
			get_parent().add_child(bullet)
			bullet.global_position = global_position + Vector2(120, 0).rotated(angle)
			bullet.linear_velocity = Vector2(2500, 0).rotated(angle)
			bullet.set_ship(self)
	
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
	call_deferred('set_collision_layer_bit', 0, false)
	call_deferred('set_collision_layer_bit', 18, true)
	
func emerge():
	under = false
	z_as_relative = true
	z_index = 0
	call_deferred('set_collision_layer_bit', 0, true)
	call_deferred('set_collision_layer_bit', 18, false)
	
signal frozen
func freeze():
	if alive and not invincible:
		emit_signal("frozen", self)
		
func _on_Ship_near_area_entered(sth, this):
	if sth is ArkaBall and sth.is_pickable():
		sth.queue_free()
		start_golf()

func start_golf():
	golf = true
	update_weapon_indicator()
	yield(get_tree().create_timer(0.5), "timeout")
	charge()

func get_player():
	return info_player
	
func is_in_gel():
	for area in $NearArea.get_overlapping_areas():
		if traits.has_trait(area, 'Gel'):
			return true
	return false
	
func is_on_ice():
	for area in $NearArea.get_overlapping_areas():
		if area is Ice:
			return true
	return false
	
func is_hiding():
	for area in $NearArea.get_overlapping_areas():
		if area.is_in_group('hiding_spot'):
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
	if start_invincible:
		make_invincible()
	yield(get_tree(), "idle_frame")
	emit_signal('done')

func disable_controls():
	controls_enabled = false
	
func enable_controls():
	controls_enabled = true
	
func are_controls_enabled():
	return controls_enabled
	
func is_auto_thrust() -> bool:
	return auto_thrust
	
func set_auto_thrust(v: bool) -> void:
	auto_thrust = v

func is_piercing() -> bool:
	return $Sword.get_active()
	
func get_cargo():
	return $Cargo
	
func has_cargo() -> bool:
	return $Cargo.has_holdable()

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
	
func get_species():
	return info_player.species
	
func get_color():
	return get_species().color

func start_drift():
	drifting = true
	$IceAutoTrail.create_trail()
	emit_signal("drift_started")
	
func end_drift():
	drifting = false
	$IceAutoTrail.drop_trail()
	emit_signal("drift_ended")

#func set_size(size):
#	scale = Vector2(size, size)
#	$CollisionShape2D.shape.radius = 48*size*sqrt(size)
	
func set_holder(v: bool) -> void:
	call_deferred('set_collision_layer_bit', 21, v)

func is_holder() -> bool:
	return get_collision_layer_bit(21)
	
func phase_in() -> void:
	if phasing_in_prevented:
		return
		
	thrust_multiplier = 1.0
	set_auto_thrust(false)
	#enable_controls()
	call_deferred('set_collision_layer_bit', 22, true)
	
func phase_out() -> void:
	thrust_multiplier = 3.0
	set_auto_thrust(true)
	#disable_controls()
	call_deferred('set_collision_layer_bit', 22, false)
	
func set_phasing_in_prevented(v: bool) -> void:
	phasing_in_prevented = v

func get_thrust_multiplier() -> float:
	return thrust_multiplier
	
func get_brain() -> Brain:
	if not has_node('Brain'):
		return null
	return ($Brain as Brain)

func set_brain(new_brain: Brain) -> void:
	var old_brain = get_brain()
	if old_brain != null:
		old_brain.disconnect('charge', self, '_on_charge_requested')
		old_brain.disconnect('release', self, '_on_release_requested')
		old_brain.free()
	new_brain.set_name('Brain')
	new_brain.connect('charge', self, '_on_charge_requested')
	new_brain.connect('release', self, '_on_release_requested')
	add_child(new_brain)

func get_rotation_request() -> float:
	var brain = get_brain()
	if brain == null:
		return 0.0
		
	return brain.get_rotation_request()
	
func get_target_velocity() -> Vector2:
	var brain = get_brain()
	if brain == null:
		return Vector2(0,0)
		
	return brain.get_target_velocity()

func do_brain_tick() -> void:
	var brain = get_brain()
	if brain == null:
		return
	brain.tick()
	
func _on_charge_requested() -> void:
	charge()
	
func _on_release_requested() -> void:
	fire()
	
var loaded_shot = null
func load_shot(body: RigidBody2D) -> void:
	loaded_shot = body
	body.get_parent().remove_child(body)
	$LoadedShot.texture = body.get_texture()
	$LoadedShot.modulate = body.get_color()
	
	
func empty_loaded_shot() -> void:
	loaded_shot = null
	$LoadedShot.texture = null
	
func unhide():
	modulate = Color(1,1,1,1)
