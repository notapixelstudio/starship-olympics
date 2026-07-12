extends Control

@export var controls_prefix := "rm1"
@export var joystick_radius := 65.0
@export var knob_radius := 28.0
@export var deadzone := 0.15

var _vector := Vector2.ZERO
var _knob_offset := Vector2.ZERO
var _shown := false
var _active := false
var _home_center := Vector2.ZERO

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(joystick_radius * 2.0 + 20.0, joystick_radius * 2.0 + 20.0)
	size = custom_minimum_size

func set_home_center(center: Vector2) -> void:
	_home_center = center
	if not _active:
		place_at_center(center)

func place_at_center(center: Vector2) -> void:
	position = center - size * 0.5

func show_hint() -> void:
	_shown = true
	_active = false
	_vector = Vector2.ZERO
	_knob_offset = Vector2.ZERO
	place_at_center(_home_center)
	visible = true
	set_process(false)
	queue_redraw()

func hide_hint() -> void:
	_shown = false
	_active = false
	visible = false
	_vector = Vector2.ZERO
	_knob_offset = Vector2.ZERO
	_release_directions()
	set_process(false)
	queue_redraw()

func activate_at(screen_pos: Vector2) -> void:
	if not _shown:
		return
	place_at_center(screen_pos)
	_active = true
	set_process(true)
	update_at_screen_pos(screen_pos)

func deactivate_to_home() -> void:
	if not _active:
		return
	_active = false
	_vector = Vector2.ZERO
	_knob_offset = Vector2.ZERO
	_release_directions()
	place_at_center(_home_center)
	set_process(false)
	queue_redraw()

func update_at_screen_pos(screen_pos: Vector2) -> void:
	if not _active:
		return
	var center := global_position + size * 0.5
	var offset := screen_pos - center
	if offset.length() > joystick_radius:
		offset = offset.normalized() * joystick_radius
	_knob_offset = offset
	_vector = offset / joystick_radius
	queue_redraw()

func _process(_delta: float) -> void:
	if _active:
		_emit_directions()

func _emit_directions() -> void:
	var x := _vector.x
	var y := _vector.y
	if _vector.length() < deadzone:
		x = 0.0
		y = 0.0

	if x >= 0.0:
		Utils.inject_input_action(true, x, controls_prefix + "_right")
		Utils.inject_input_action(false, x, controls_prefix + "_left")
	else:
		Utils.inject_input_action(true, abs(x), controls_prefix + "_left")
		Utils.inject_input_action(false, abs(x), controls_prefix + "_right")

	if y >= 0.0:
		Utils.inject_input_action(true, y, controls_prefix + "_down")
		Utils.inject_input_action(false, y, controls_prefix + "_up")
	else:
		Utils.inject_input_action(true, abs(y), controls_prefix + "_up")
		Utils.inject_input_action(false, abs(y), controls_prefix + "_down")

func _release_directions() -> void:
	for suffix in ["_left", "_right", "_up", "_down"]:
		Utils.inject_input_action(false, 0.0, controls_prefix + suffix)

func _draw() -> void:
	if not _shown:
		return
	var center := size * 0.5
	var base_fill := 0.1 if _active else 0.06
	var base_ring := 0.28 if _active else 0.18
	draw_circle(center, joystick_radius, Color(1, 1, 1, base_fill))
	draw_arc(center, joystick_radius, 0.0, TAU, 64, Color(1, 1, 1, base_ring), 1.5)
	if _active:
		draw_circle(center + _knob_offset, knob_radius, Color(1, 1, 1, 0.28))
		draw_arc(center + _knob_offset, knob_radius, 0.0, TAU, 48, Color(1, 1, 1, 0.42), 1.5)
	else:
		draw_circle(center, knob_radius * 0.55, Color(1, 1, 1, 0.12))
