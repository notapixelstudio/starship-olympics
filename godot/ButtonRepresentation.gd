extends TextureRect

class_name ShowedButton

var path_buttons: String = "res://assets/UI/Xelu_Free_Controller&Key_Prompts/"
var keyboard_path: String = "Keyboard & Mouse/Dark/"
var keyboard_suffix: String = "_Key_Dark"
var extension: String = ".png"
var ps_path = "PS4/PS4_"
var xbox_path = "Xbox One/XboxOne_"
var default_joy_device = ps_path
var connected_event: InputEvent

func get_event():
	return connected_event
	
func get_metadata_from_event(event:InputEvent) -> String:
	if event is InputEventKey:
		return "kb"
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		return Input.get_joy_name(event.device)
	else:
		return "not recognised"
	

func set_button(event: InputEvent):
	connected_event = event
	var device_type = get_metadata_from_event(event)
	var button = global.event_to_text(event)
	var button_path = keyboard_path
	if "kb" in device_type:
		button_path = keyboard_path + button + keyboard_suffix + extension
	if "ps" in device_type:
		button_path = ps_path + button + extension
	if "xbox" in device_type:
		button_path = xbox_path + button + extension
	if "default_joy" in device_type:
		button_path = default_joy_device + button + extension
	texture = load(path_buttons + button_path)
	
	
