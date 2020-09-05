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

var species_name: String
var scores


var cpu = false
var velocity = Vector2(0,0)
var target_velocity = Vector2(0,0)
var steer_force = 0
var rotation_dir = 0

var THRUST = 2000

var charge = 0
const max_steer_force = 2500
const MAX_CHARGE = 0.6
const MIN_DASHING_CHARGE = 0.12
const MAX_OVERCHARGE = 1.3
const CHARGE_BASE = 200
const ANTI_RECOIL_OFFSET = 260
const CHARGE_MULTIPLIER = 4500
const BOMB_OFFSET = 50
const BOMB_BOOST = 200
const BALL_BOOST = 500
const BALL_CHARGE_MULTIPLIER = 1.4
const FIRE_COOLDOWN = 0.03

const THRESHOLD_DIR = 0.3
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


var screen_size = Vector2()
var width = 0
var height = 0

var charging = false
var fire_cooldown = FIRE_COOLDOWN
var dash_cooldown = 0
var reload_time

var bomb_count = 0

var teleport_to = null

onready var player = name
onready var skin = $Graphics
onready var charging_sfx = $charging
onready var ammo = $PlayerInfo.ammo

const dead_ship_scene = preload("res://actors/battlers/DeadShip.tscn")

var dead_ship_instance

signal dead
signal stop_invincible
signal spawn_bomb
var invincible : bool

var entity : Entity
var camera

var weapon_textures = {
	GameMode.BOMB_TYPE.classic: preload('res://assets/sprites/interface/charge_bomb.png'),
	GameMode.BOMB_TYPE.ball: preload('res://assets/sprites/interface/charge_ball.png')
}

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
	emit_signal('spawned', self)
	dash_init_appearance()
	
	# Invincible for the firs MAX seconds
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
	
	
static func magnitude(a:Vector2):
	return sqrt(a.x*a.x+a.y*a.y)
	
func _integrate_forces(state):
	if not responsive:
		return
	set_applied_force(Vector2())
	steer_force = max_steer_force * rotation_dir
	
	if not absolute_controls:
		add_central_force(Vector2(THRUST, steer_force).rotated(rotation)*int(not charging and not stunned)) # thrusters switch off when charging
		# rotation = atan2(target_velocity.y, target_velocity.x)
	else:
		#rotation = state.linear_velocity.angle()
		#apply_impulse(Vector2(),target_velocity*THRUST)	
		add_central_force(target_velocity*THRUST*int(not charging and not stunned))
		
	if entity.has('Flowing'):
		apply_impulse(Vector2(), entity.get_node('Flowing').get_flow().get_flow_vector(position))
		
	set_applied_torque(rotation_dir * 30000)
	
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
	velocity = state.linear_velocity
	state.set_transform(xform)

func control(_delta):
	update_charge_bar()
	
func update_charge_bar():
	if not charging:
		$Graphics/ChargeBar.visible = false
		return
		
	$Graphics/ChargeBar.visible = true
	
	# charge feedback
	var v = $Graphics/ChargeBar/ChargeAxis.points[1] * min(charge,MAX_CHARGE)/MAX_CHARGE
	$Graphics/ChargeBar/Charge.set_point_position(1, v)
	$Graphics/ChargeBar/ChargeBackground.set_point_position(1, v)
	$Graphics/ChargeBar/ArrowTip.position.x = v.x
	
	# overcharge feedback
	if charge > MAX_CHARGE + (MAX_OVERCHARGE-MAX_CHARGE)/2:
		$Graphics/ChargeBar.visible = int(floor(charge * 15)) % 2

signal detection
func _physics_process(delta):
	if not alive:
		return
	
	control(delta)
	
	stun_countdown -= delta
	if stun_countdown <= 0:
		unstun()
		
	dash_cooldown -= delta
	if dash_cooldown <= 0 and entity.get('Dashing').enabled:
		entity.get('Dashing').disable()
		dash_restore_appearance()
		
	for body in $DetectionArea.get_overlapping_bodies():
		emit_signal("detection", body, self)
		
var will_fire
func charge():
	charging = true
	#$GravitonField.enabled = true
	charging_sfx.play()
	dash_fat_appearance()
	will_fire = ammo.max_ammo == -1 or ammo.current_ammo > 0
	if will_fire:
		$Graphics/ChargeBar/BombPreview.texture = weapon_textures[bomb_type]
	else:
		$Graphics/ChargeBar/BombPreview.texture = null
	
func fire():
	"""
	Fire a bomb
	"""
	var should_reload = false
	
	var charge_impulse = CHARGE_BASE + CHARGE_MULTIPLIER * min(charge, MAX_CHARGE)
	
	# - (CHARGE_BASE + ANTI_RECOIL_OFFSET) is to avoid too much acceleration when repeatedly firing bombs
	apply_impulse(Vector2(0,0), Vector2(max(0, charge_impulse - (CHARGE_BASE + ANTI_RECOIL_OFFSET)), 0).rotated(rotation)) # recoil
	
	if bombs_enabled:
		bomb_count += 1
		if will_fire:
			ammo.shot()
			should_reload = true
			var impulse
			if bomb_type == GameMode.BOMB_TYPE.ball:
				impulse = charge_impulse*BALL_CHARGE_MULTIPLIER+BALL_BOOST
			else:
				impulse = charge_impulse+BOMB_BOOST
			
			emit_signal("spawn_bomb", bomb_type, position + Vector2(-BOMB_OFFSET,0).rotated(rotation),
				Vector2(-impulse,0).rotated(rotation))
	
	# repeal
	#$GravitonField.repeal(charge_impulse)
	#$GravitonField.enabled = false
	
	charging = false
	$Graphics/ChargeBar.visible = false
	fire_cooldown = FIRE_COOLDOWN
	charging_sfx.stop()
	$Tween.stop_all()
	$Graphics/Sprite.scale = DASH_RESTORED
	
	if charge > MIN_DASHING_CHARGE:
		entity.get('Dashing').enable()
		dash_cooldown = (charge - MIN_DASHING_CHARGE)*0.3
		
	if should_reload:
		yield(get_tree().create_timer(reload_time), "timeout")
		ammo.reload()
		
func die(killer : Ship):
	if alive and not invincible:
		alive = false
		# skin.play_death()
		# deactivate controls and whatnot and wait for the sound to finish
		yield(get_tree(), "idle_frame")
		if info_player.lives >= 0:
			info_player.lives -= 1
		emit_signal("dead", self, killer)
		
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
	
static func find_side(a: Vector2, b: Vector2, check: Vector2) -> int:
	"""
	Given two points a, b will return the side check is on.
 	@return integer code for which side of the line ab c is on.  
	1 means left turn, -1 means right turn.  Returns
 	0 if all three are on a line (THRESHOLD will adjust the wiggle in movements)
	"""
	var possible_dirs : Array = [-1,1]
	var cross = (b.x - a.x)*(check.y-a.y) - (b.y - a.y)*(check.x-a.x)
	if check == -b:
		cross = possible_dirs[randi()%len(possible_dirs)]

	if cross > -THRESHOLD_DIR and cross < THRESHOLD_DIR :
		if sign(check.y)==sign(b.y) or sign(b.x) == sign(check.x) :
			return 0
	
	return int(sign(cross))

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
		Tween.TRANS_CUBIC, Tween.EASE_OUT, 0)
	$Tween.start()
	
func dash_thin_appearance():
	$Graphics/Sprite.scale = DASH_THIN
	$DashParticles.emitting = true
	$DashParticles.visible = true
	$DashFxTimer.stop()
	
func _on_Dashing_enabled():
	dash_thin_appearance()
	
func _on_Dashing_disabled():
	dash_restore_appearance()
	
func _on_bomb_freed():
	bomb_count -= 1
