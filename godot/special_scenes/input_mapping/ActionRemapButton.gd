extends Button

export var action: String = "ui_up" setget _set_action

signal remap

func check_input_event(event:InputEvent):
	if "kb" in self.action:
		return event is InputEventKey
	elif "joy" in self.action:
		var device = int(self.action.split("_")[0].replace("joy", ""))-1
		# event.axis equal to 6 and 7 are the anaolog axis. from Godot 3.2.4
		return (event is InputEventJoypadButton or (event is InputEventJoypadMotion and event.axis != 7 and event.axis != 6)) and event.device == int(device)
	
func _set_action(value_):
	action = value_
	display_current_key()

func _ready():
	assert(InputMap.has_action(action))
	set_process_input(false)
	display_current_key()


func _toggled(button_pressed):
	set_process_input(button_pressed)
	if button_pressed:
		text = "..."
	else:
		display_current_key()
		
		
func _input(event):
	# Note that you can use the _input callback instead, especially if
	# you want to work with gamepads.
	if check_input_event(event):
		# DO NOTHING if less than DEADZONE
		if event is InputEventJoypadMotion:
			if abs(event.axis_value) < 0.5:
				return
		emit_signal("remap", self.action, event)
		pressed=false
		

func joy_remap_action_to(event):
	pass

func display_current_key():
	var current_key = "..."
	var keys = []
	for event in InputMap.get_action_list(self.action):
		if check_input_event(event):
			current_key = global.event_to_text(self.action, event)
			keys.append(current_key)
	# JUST FOR MAPPING JOY
	var text_to_button = current_key
	if "joy" in action:
		text_to_button = global.joy_input_map[current_key]
	text = "%s " % text_to_button.to_upper()


