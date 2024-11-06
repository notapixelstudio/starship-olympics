extends Node

var _current_cargo : Cargo

func _ready():
	Events.sth_loaded.connect(_on_sth_loaded)
	Events.tap.connect(_on_tap)

func _on_tap(tapper) -> void:
	if has_cargo() and _current_cargo is Ball and get_parent() == tapper:
		kick(tapper)

func _on_sth_loaded(loader, loadee) -> void:
	if get_parent() != loader:
		return
		
	_load_cargo(loadee)
	
func _load_cargo(v: Cargo) -> void:
	_current_cargo = v.clone_as_new()
	if _current_cargo is Hat:
		%HatSprite.texture = _current_cargo.get_texture()
	elif _current_cargo is Ball:
		%BallSprite.texture = _current_cargo.get_texture()
		
func _empty_cargo() -> void:
	_current_cargo = null
	%HatSprite.texture = null
	%BallSprite.texture = null

func has_cargo() -> bool:
	return _current_cargo != null

func kick(source) -> void:
	# TBD when https://github.com/godotengine/godot/pull/92218 will be merged, check if the first line
	# needs to be done now, before place_and_push, to avoid seeing the Shadow node temporarily elsewhere
	source.get_parent().add_child(_current_cargo)
	_current_cargo.set_temp_untouchable_by(source)
	_current_cargo.place_and_push(source.global_position, source.linear_velocity + Vector2(3000,0).rotated(source.global_rotation), source.global_rotation)
	_empty_cargo()

func rebound_cargo(source, collision_point: Vector2, collision_normal: Vector2) -> void:
	# TBD when https://github.com/godotengine/godot/pull/92218 will be merged, check if the first line
	# needs to be done now, before place_and_push, to avoid seeing the Shadow node temporarily elsewhere
	source.get_parent().add_child(_current_cargo)
	_current_cargo.set_temp_untouchable_by(source)
	var alpha = source.linear_velocity.bounce(collision_normal).angle()
	_current_cargo.place_and_push(collision_point, Vector2(source.linear_velocity.length()+500,0).rotated(alpha), alpha)
	_empty_cargo()
