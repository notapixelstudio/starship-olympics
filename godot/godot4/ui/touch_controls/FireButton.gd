extends Control

@export var controls_prefix := "rm1"
@export var button_radius := 50.0

var _pressed := false
var _shown := false

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(button_radius * 2.0 + 16.0, button_radius * 2.0 + 16.0)
	size = custom_minimum_size

func place_at_center(center: Vector2) -> void:
	position = center - size * 0.5

func show_hint() -> void:
	_shown = true
	_pressed = false
	visible = true
	queue_redraw()

func hide_hint() -> void:
	if _pressed:
		_set_pressed(false)
	_shown = false
	visible = false
	queue_redraw()

func set_held(held: bool) -> void:
	_set_pressed(held)

func _set_pressed(value: bool) -> void:
	if _pressed == value:
		return
	_pressed = value
	Utils.inject_input_fire("1" if value else "0", controls_prefix + "_fire")
	Utils.inject_input_action(value, 1.0 if value else 0.0, "ui_accept")
	Utils.notify_touch_fire(controls_prefix, value)
	queue_redraw()

func _draw() -> void:
	if not _shown:
		return
	var center := size * 0.5
	var fill_alpha := 0.32 if _pressed else 0.12
	var ring_alpha := 0.48 if _pressed else 0.22
	draw_circle(center, button_radius, Color(1, 0.45, 0.2, fill_alpha))
	draw_arc(center, button_radius, 0.0, TAU, 64, Color(1, 0.65, 0.35, ring_alpha), 2.0)
