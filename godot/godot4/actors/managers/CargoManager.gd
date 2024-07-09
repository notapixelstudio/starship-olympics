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
	_current_cargo.place_and_push(source, source.linear_velocity + Vector2(3000,0).rotated(source.global_rotation))
	source.get_parent().add_child(_current_cargo)
	_empty_cargo()
