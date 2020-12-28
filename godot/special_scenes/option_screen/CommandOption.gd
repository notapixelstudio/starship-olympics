tool
extends MarginContainer

class_name CommandRemap

onready var button = $Container/Button

export var action: String
export var device: String setget _set_device

signal clear_mapping
signal remap

func _process(delta):
	$Container/Description.text = action
	
	
func _set_device(value_):
	device = value_
	if not is_inside_tree():
		yield(self, "ready")
	$Container/Button.action = device+"_"+action


func _on_Button_remapped(action: String, new_control: String):
	emit_signal("remapped", action, new_control)


func _on_Button_try_remap(action):
	emit_signal("try_remap", action)


func _on_Button_toggled(button_pressed):
	pass # Replace with function body.


func _on_Button_remap(action, event):
	var found = false
	var text = global.event_to_text(action, event)
	for action in global.input_mapping:
		if device in action:
			for command in global.input_mapping[action]:
				if text == command:
					found = true
	if found:
		print("I can't sorry, because someone else uses it")
		return
	emit_signal("clear_mapping", action)
	var new_control_key = global.remap_action_to(action, event)
	var text_to_button = new_control_key
	if new_control_key in global.joy_input_map:
		text_to_button = global.joy_input_map[new_control_key]
	button.text = "%s " % text_to_button.to_upper()
	emit_signal("remap", action, new_control_key)
	button.disabled = true
	yield(get_tree().create_timer(0.4), "timeout")
	button.disabled = false
	# save
	persistance.save_game()
