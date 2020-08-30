extends Button

export var action: String = "ui_up" setget _set_action

func check_input_event(action_: String, event:InputEvent):
	if "kb" in action_:
		return event is InputEventKey
	elif "joy" in action_:
		return event is InputEventJoypadButton 

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
	if event is InputEventKey:
		remap_action_to(self.action, event)


func remap_action_to(action, event, ui_flag=true):
	var current_key = global.remap_action_to(action, event)
	text = "%s " % current_key.to_upper()


func display_current_key():
	var current_key = "..."
	for event in InputMap.get_action_list(self.action):
		if check_input_event(self.action, event):
			current_key = event.as_text()
			break
	text = "%s " % current_key.to_upper()
