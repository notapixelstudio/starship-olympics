extends Node

var _current_cargo : Cargo

func _ready():
	get_host().tap.connect(_on_tap)
	
func get_host():
	return get_parent()

func _on_tap() -> void:
	if has_cargo() and _current_cargo is Ball:
		kick_cargo()
	
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
	if _current_cargo is Hat:
		%HatSprite.texture = _current_cargo.get_texture()
		%BallSprite.texture = null
	elif _current_cargo is Ball:
		%HatSprite.texture = null
		%BallSprite.texture = _current_cargo.get_texture()
		
func _empty_cargo() -> void:
	_current_cargo = null
	%HatSprite.texture = null
	%BallSprite.texture = null

func has_cargo() -> bool:
	return _current_cargo != null
	
func get_cargo() -> Cargo:
	return _current_cargo
	
func _launch_cargo(global_pos: Vector2, vel: Vector2, rot: float) -> void:
	Events.spawn_request.emit(_current_cargo, func(cargo):
		cargo.set_temp_untouchable_by(get_host())
		cargo.place_and_push(global_pos, vel, rot)
	)
	_empty_cargo()
	
func kick_cargo() -> void:
	_launch_cargo(get_host().global_position, get_host().linear_velocity + Vector2(3000,0).rotated(get_host().global_rotation), get_host().global_rotation)

func discard_cargo() -> void:
	_launch_cargo(get_host().global_position, Vector2(200.0, 0).rotated(get_host().global_rotation), get_host().global_rotation)

func shoot_cargo(cause: RigidBody2D) -> void:
	_launch_cargo(get_host().global_position, cause.linear_velocity, get_host().global_rotation)

func rebound_cargo(source, collision_point: Vector2, collision_normal: Vector2) -> void:
	Events.spawn_request.emit(_current_cargo)
	_current_cargo.set_temp_untouchable_by.call_deferred(source)
	var alpha = source.linear_velocity.bounce(collision_normal).angle()
	_current_cargo.place_and_push(collision_point, Vector2(source.linear_velocity.length()+500,0).rotated(alpha), alpha)
	_empty_cargo()


func swap_cargo(other) -> void:
	if not has_cargo() and not other.has_cargo():
		# no actual swap has to occur, bail
		return
		
	# ignore swapping if just swapped sth
	if not %JustSwappedTimer.is_stopped():
		return
	%JustSwappedTimer.start()
	
	var swap = get_cargo()
	_new_cargo(other.get_cargo())
	other._new_cargo(swap)
	
