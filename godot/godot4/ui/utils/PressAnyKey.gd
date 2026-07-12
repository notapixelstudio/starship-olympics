extends CanvasLayer

signal any_key_pressed

var _active := false

func _ready() -> void:
	visible = false
	layer = 5
	%Catcher.mouse_filter = Control.MOUSE_FILTER_IGNORE

func disable() -> void:
	_active = false
	Utils.unregister_press_any()
	visible = false
	%Catcher.mouse_filter = Control.MOUSE_FILTER_IGNORE

func enable() -> void:
	_active = true
	visible = true
	%Catcher.mouse_filter = Control.MOUSE_FILTER_IGNORE
	Utils.register_press_any(_accept)
	%ContinueAnimationPlayer.play("blink")

func is_active() -> bool:
	return _active

func _accept() -> void:
	if not _active:
		return
	any_key_pressed.emit()
	disable()
