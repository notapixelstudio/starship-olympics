extends Control

@export var controls_prefix := "rm1"
@export var button_radius := 55.0

var _touch_index := -1
var _pressed := false
var _using_mouse := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and _touch_index == -1 and _is_local(event.position):
			_using_mouse = true
			_touch_index = 0
			_set_pressed(true)
		elif not event.pressed and _using_mouse:
			_set_pressed(false)
			_touch_index = -1
			_using_mouse = false

func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed and _touch_index == -1 and _is_local(event.position):
		_touch_index = event.index
		_set_pressed(true)
	elif not event.pressed and event.index == _touch_index:
		_set_pressed(false)
		_touch_index = -1

func _is_local(position: Vector2) -> bool:
	return Rect2(Vector2.ZERO, size).has_point(position)

func _set_pressed(value: bool) -> void:
	if _pressed == value:
		return
	_pressed = value
	Utils.inject_input_fire("1" if value else "0", controls_prefix + "_fire")
	Utils.inject_input_action(value, 1.0 if value else 0.0, "ui_accept")
	Utils.notify_touch_fire(controls_prefix, value)
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and not is_visible_in_tree() and _pressed:
		_set_pressed(false)

func _draw() -> void:
	var center := size * 0.5
	var fill_alpha := 0.55 if _pressed else 0.35
	var ring_alpha := 0.85 if _pressed else 0.6
	draw_circle(center, button_radius, Color(1, 0.45, 0.2, fill_alpha))
	draw_arc(center, button_radius, 0.0, TAU, 64, Color(1, 0.65, 0.35, ring_alpha), 3.0)
