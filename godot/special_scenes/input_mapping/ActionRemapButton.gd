extends Button

export var action: String = "ui_up" setget _set_action

signal remapped 
func check_input_event(event:InputEvent):
	if "kb" in self.action:
		return event is InputEventKey
	elif "joy" in self.action:
		var device = int(self.action.split("_")[0].replace("joy", ""))-1
		return (event is InputEventJoypadButton or event is InputEventJoypadMotion) and event.device == int(device)
	
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
		remap_action_to(self.action, event)
		pressed=false
		

func joy_remap_action_to(event):
	pass
	
func remap_action_to(action, event, ui_flag=true):
	var current_key = global.remap_action_to(action, event)
	text = "%s " % current_key.to_upper()
	disabled = true
	emit_signal("remapped", action, text)
	yield(get_tree().create_timer(0.4), "timeout")
	disabled = false


func display_current_key():
	var current_key = "..."
	for event in InputMap.get_action_list(self.action):
		if check_input_event(event):
			current_key = global.event_to_text(self.action, event)
			break
	text = "%s " % current_key.to_upper()


