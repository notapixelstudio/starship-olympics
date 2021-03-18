extends TextureRect

class_name ShowedButton

var path_buttons: String = "res://assets/UI/Xelu_Free_Controller&Key_Prompts/"
var keyboard_path: String = "Keyboard & Mouse/Dark/"
var keyboard_suffix: String = "_Key_Dark"
var extension: String = ".png"
var ps_path = "PS4/PS4_"
var xbox_path = "Xbox One/XboxOne_"
var default_joy_device = ps_path


func set_button(device_type, button, device = 0):
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
	
	
