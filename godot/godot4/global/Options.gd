extends Node

var fullscreen : bool = true

func _ready() -> void:
	Events.option_changed.connect(_on_option_changed)
	
func _on_option_changed(option_name:String, new_value) -> void:
	get('_set_'+option_name).call(new_value)

func _set_fullscreen(value: bool):
	fullscreen = value
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (fullscreen) else Window.MODE_WINDOWED
	get_window().move_to_foreground()
	if fullscreen:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
