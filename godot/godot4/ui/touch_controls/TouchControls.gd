extends CanvasLayer

@export var controls_prefix := "rm1"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for child in %Controls.get_children():
		if "controls_prefix" in child:
			child.controls_prefix = controls_prefix
	hide_controls()

func show_controls() -> void:
	if not (DisplayServer.is_touchscreen_available() or OS.has_feature("mobile")):
		return
	visible = true
	set_process_input(true)

func hide_controls() -> void:
	visible = false
	set_process_input(false)
	_release_all_inputs()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		Utils.notify_screen_touch()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED:
		_release_all_inputs()

func _release_all_inputs() -> void:
	for suffix in ["_left", "_right", "_up", "_down"]:
		Utils.inject_input_action(false, 0.0, controls_prefix + suffix)
	Utils.inject_input_fire("0", controls_prefix + "_fire")
