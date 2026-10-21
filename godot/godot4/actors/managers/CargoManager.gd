extends Node

@onready var _ctx := ArenaScope.get_scope(self)

var _current_cargo : Cargo
var _baton_pulse_tween : Tween

func _ready():
	%AutoSignals \
		.bind(get_host().tap, _on_tap) \
		.bind(_ctx.player_failed, _on_player_failed)
	# the outline material is shared across every ship by default - duplicate so tinting it is per-ship
	%HatSprite.material = %HatSprite.material.duplicate()

func get_host():
	return get_parent()

func _on_tap(charge:float) -> void:
	if has_cargo() and _current_cargo is Ball:
		kick_cargo(charge)
	
func load_cargo(v: Cargo) -> void:
	# lose cargo first if something is already loaded
	if has_cargo():
		discard_cargo()
		
	_new_cargo(v)
	
func _new_cargo(v: Cargo) -> void:
	if v == null:
		_empty_cargo()
		return

	_current_cargo = v.clone_as_new()
	_stop_baton_pulse()
	if _current_cargo is Hat:
		%HatSprite.texture = _current_cargo.get_texture()
		%HatSprite.material.set_shader_parameter("color", Color.WHITE)
		%BallSprite.texture = null
	elif _current_cargo is Ball:
		%HatSprite.texture = null
		%BallSprite.texture = _current_cargo.get_texture()

	if v.has_item():
		assert(get_host() is Ship)
		_ctx.item_obtained.emit(v.item, get_host().get_player())

const BATON_READY_GLOW := Color(2.2, 1.8, 0.3)
const BATON_PULSE_SCALE := 1.4
const BATON_PULSE_DURATION := 0.35

## Lights up and pulses the carried relay baton's icon (its outline, since its shader ignores modulate) once it's ready to be handed off.
func mark_baton_passable() -> void:
	if _current_cargo is Baton:
		%HatSprite.material.set_shader_parameter("color", BATON_READY_GLOW)
		_baton_pulse_tween = create_tween().set_loops()
		_baton_pulse_tween.tween_property(%HatSprite, "scale", Vector2.ONE * BATON_PULSE_SCALE, BATON_PULSE_DURATION).set_trans(Tween.TRANS_SINE)
		_baton_pulse_tween.tween_property(%HatSprite, "scale", Vector2.ONE, BATON_PULSE_DURATION).set_trans(Tween.TRANS_SINE)

func _stop_baton_pulse() -> void:
	if _baton_pulse_tween:
		_baton_pulse_tween.kill()
		_baton_pulse_tween = null
	%HatSprite.scale = Vector2.ONE

func _empty_cargo() -> void:
	var old_cargo = _current_cargo
	_current_cargo = null
	_stop_baton_pulse()
	%HatSprite.texture = null
	%HatSprite.material.set_shader_parameter("color", Color.WHITE)
	%BallSprite.texture = null
	_ctx.cargo_unloaded.emit(old_cargo, get_host())
	if old_cargo.has_item():
		_ctx.item_lost.emit(old_cargo.item, get_host().get_player())

func has_cargo() -> bool:
	return _current_cargo != null
	
func has_cargo_class(type) -> bool:
	if not has_cargo():
		return false
		
	return is_instance_of(_current_cargo, type)
	
func get_cargo() -> Cargo:
	return _current_cargo
	
func _launch_cargo(global_pos: Vector2, vel: Vector2, rot: float, spin: float = 0.0) -> void:
	_ctx.spawn_request.emit(_current_cargo, func(cargo):
		cargo.set_temp_untouchable_by(get_host())
		cargo.place_and_push(global_pos, vel, rot, spin)
	)
	_empty_cargo()
	
func kick_cargo(charge:float) -> void:
	if _current_cargo is Ball:
		_current_cargo.set_player(get_host().get_player())
		_current_cargo.unrest()
		
	# use intended direction in addition to actual direction
	const COMPENSATION = 0.9
	var host_forward = Vector2.RIGHT.rotated(get_host().global_rotation)
	var host_intended_forward = get_host().get_target_velocity().normalized()
	# no compensation if host is not moving
	if get_host().get_target_velocity().length_squared() < 1.0:
		host_intended_forward = host_forward
		
	var compensated_angle = (host_forward*(1.0-COMPENSATION)+host_intended_forward*COMPENSATION).angle()
	var spin = -0.1*(host_intended_forward.cross(host_forward))
	
	_launch_cargo(get_host().global_position, get_host().linear_velocity + Vector2(500+5500*charge,0).rotated(compensated_angle), compensated_angle, spin)

func discard_cargo() -> void:
	_launch_cargo(get_host().global_position, Vector2(200.0, 0).rotated(get_host().global_rotation), get_host().global_rotation)

func shoot_cargo(cause: RigidBody2D) -> void:
	var velocity : Vector2 = 1000.0*get_host().linear_velocity.normalized()
	if cause:
		velocity += cause.linear_velocity
	_launch_cargo(get_host().global_position, velocity, get_host().global_rotation)

func rebound_cargo(collision_point: Vector2, collision_normal: Vector2) -> void:
	var source = get_host()
	_ctx.spawn_request.emit(_current_cargo)
	_current_cargo.set_temp_untouchable_by.call_deferred(source)
	var alpha = source.linear_velocity.bounce(collision_normal).angle()
	_current_cargo.place_and_push(collision_point, Vector2(source.linear_velocity.length(),0).rotated(alpha), alpha)
	_empty_cargo()


func swap_cargo(other) -> void:
	if not has_cargo() and not other.has_cargo():
		# no actual swap has to occur, bail
		return

	if (has_cargo() and not get_cargo().passable) or (other.has_cargo() and not other.get_cargo().passable):
		return # e.g. a relay baton can't be handed off before its carrier completes a lap

	# ignore swapping if just swapped sth
	if not %JustSwappedTimer.is_stopped():
		return
	%JustSwappedTimer.start()
	
	var swap = get_cargo()
	_new_cargo(other.get_cargo())
	other._new_cargo(swap)
	
func hit_cargo(hitter=null) -> void:
	if not has_cargo():
		return
		
	# shoot the cargo and hit it after the fact
	var _the_cargo = _current_cargo
	shoot_cargo(hitter)
	_the_cargo.hit.call_deferred(hitter)


func _on_player_failed(player:Player) -> void:
	if not has_cargo():
		return
		
	if get_host().get_player() != player:
		return
		
	if get_cargo().has_item() and get_cargo().get_item().is_glass():
		# glass cargos are hit on a fail
		hit_cargo()
