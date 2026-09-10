extends CanvasLayer

@export var controls_prefix := "rm1"
@export var edge_margin := Vector2(72, 72)
@export var fire_hit_padding := 28.0
@export var gear_hit_padding := 10.0

var _joy_touch_index := -1
var _fire_touch_index := -1

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	%Joystick.controls_prefix = controls_prefix
	%FireButton.controls_prefix = controls_prefix
	hide_controls()

func show_controls() -> void:
	if not (DisplayServer.is_touchscreen_available() or OS.has_feature("mobile")):
		return
	visible = true
	set_process_input(true)
	_place_hints()

func hide_controls() -> void:
	visible = false
	set_process_input(false)
	_stop_joystick()
	_stop_fire()
	%Joystick.hide_hint()
	%FireButton.hide_hint()
	%PauseGear.hide_hint()
	_release_all_inputs()

func _place_hints() -> void:
	var vp := get_viewport().get_visible_rect().size
	var joy := %Joystick
	var fire := %FireButton
	var gear := %PauseGear
	joy.place_at_center(Vector2(edge_margin.x + joy.size.x * 0.5, vp.y - edge_margin.y - joy.size.y * 0.5))
	joy.set_home_center(Vector2(edge_margin.x + joy.size.x * 0.5, vp.y - edge_margin.y - joy.size.y * 0.5))
	fire.place_at_center(Vector2(vp.x - edge_margin.x - fire.size.x * 0.5, vp.y - edge_margin.y - fire.size.y * 0.5))
	var gear_size: Vector2 = gear.size
	gear.position = Vector2(vp.x - gear_size.x - 16.0, 16.0)
	joy.show_hint()
	fire.show_hint()
	gear.show_hint()

func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventScreenTouch:
		_handle_screen_touch(event)
	elif event is InputEventScreenDrag:
		_handle_screen_drag(event)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion and _joy_touch_index == 0:
		%Joystick.update_at_screen_pos(event.position)

func _handle_screen_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if _is_on_gear(event.position):
			_trigger_pause()
			return
		if _is_joy_zone(event.position):
			_start_joystick(event.index, event.position)
		elif _is_on_fire_zone(event.position):
			_start_fire(event.index)
	else:
		if event.index == _joy_touch_index:
			_stop_joystick()
		elif event.index == _fire_touch_index:
			_stop_fire()

func _handle_screen_drag(event: InputEventScreenDrag) -> void:
	if event.index == _joy_touch_index:
		%Joystick.update_at_screen_pos(event.position)

func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.pressed:
		if _is_on_gear(event.position):
			_trigger_pause()
			return
		if _is_joy_zone(event.position):
			_start_joystick(0, event.position)
		elif _is_on_fire_zone(event.position):
			_start_fire(0)
	elif _joy_touch_index == 0:
		_stop_joystick()
	elif _fire_touch_index == 0:
		_stop_fire()

func _gear_rect() -> Rect2:
	return %PauseGear.get_global_rect().grow(gear_hit_padding)

func _fire_rect() -> Rect2:
	return %FireButton.get_global_rect().grow(fire_hit_padding)

func _is_on_gear(screen_pos: Vector2) -> bool:
	return %PauseGear.visible and _gear_rect().has_point(screen_pos)

func _is_on_fire_zone(screen_pos: Vector2) -> bool:
	return _fire_rect().has_point(screen_pos)

func _is_joy_zone(screen_pos: Vector2) -> bool:
	return screen_pos.x < get_viewport().get_visible_rect().size.x * 0.5

func _trigger_pause() -> void:
	for overlay in get_tree().get_nodes_in_group("pause_overlay"):
		if overlay.has_method("pause") and not overlay.paused:
			overlay.pause()

func _start_joystick(index: int, screen_pos: Vector2) -> void:
	if _joy_touch_index != -1:
		return
	_joy_touch_index = index
	%Joystick.activate_at(screen_pos)

func _stop_joystick() -> void:
	_joy_touch_index = -1
	%Joystick.deactivate_to_home()

func _start_fire(index: int) -> void:
	if _fire_touch_index != -1:
		return
	_fire_touch_index = index
	%FireButton.set_held(true)

func _stop_fire() -> void:
	_fire_touch_index = -1
	%FireButton.set_held(false)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED:
		_stop_joystick()
		_stop_fire()
		_release_all_inputs()
		%PauseGear.hide_hint()
	elif what == NOTIFICATION_UNPAUSED and visible:
		%PauseGear.show_hint()

func _release_all_inputs() -> void:
	for suffix in ["_left", "_right", "_up", "_down"]:
		Utils.inject_input_action(false, 0.0, controls_prefix + suffix)
	Utils.inject_input_fire("0", controls_prefix + "_fire")
