extends Control

@export var controls_prefix := "rm1"
@export var joystick_radius := 70.0
@export var knob_radius := 30.0
@export var deadzone := 0.15

var _touch_index := -1
var _vector := Vector2.ZERO
var _knob_offset := Vector2.ZERO
var _using_mouse := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func _process(_delta: float) -> void:
	if not is_visible_in_tree():
		return
	_emit_directions()
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and _touch_index == -1 and _is_local(event.position):
			_using_mouse = true
			_touch_index = 0
			_update_vector(event.position)
		elif not event.pressed and _using_mouse:
			_reset()
	elif event is InputEventMouseMotion and _using_mouse:
		_update_vector(event.position)

func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed and _touch_index == -1 and _is_local(event.position):
		_touch_index = event.index
		_update_vector(event.position)
	elif not event.pressed and event.index == _touch_index:
		_reset()

func _handle_drag(event: InputEventScreenDrag) -> void:
	if event.index == _touch_index:
		_update_vector(event.position)

func _is_local(position: Vector2) -> bool:
	return Rect2(Vector2.ZERO, size).has_point(position)

func _update_vector(local_position: Vector2) -> void:
	var center := size * 0.5
	var offset := local_position - center
	if offset.length() > joystick_radius:
		offset = offset.normalized() * joystick_radius
	_knob_offset = offset
	_vector = offset / joystick_radius

func _reset() -> void:
	_touch_index = -1
	_using_mouse = false
	_vector = Vector2.ZERO
	_knob_offset = Vector2.ZERO

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

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and not is_visible_in_tree():
		_reset()

func _draw() -> void:
	var center := size * 0.5
	draw_circle(center, joystick_radius, Color(1, 1, 1, 0.12))
	draw_arc(center, joystick_radius, 0.0, TAU, 64, Color(1, 1, 1, 0.35), 2.0)
	draw_circle(center + _knob_offset, knob_radius, Color(1, 1, 1, 0.45))
	draw_arc(center + _knob_offset, knob_radius, 0.0, TAU, 48, Color(1, 1, 1, 0.7), 2.0)
