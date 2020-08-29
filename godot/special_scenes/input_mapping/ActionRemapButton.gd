extends Button

export var action: String = "ui_up" setget _set_action
export var input_type_str: String = "key"

func check_type(type_str: String, event:InputEvent):
	if type_str == "key":
		return event is InputEventKey
	elif type_str == "joy":
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
	remap_action_to(event)
	pressed = false


func remap_action_to(event):
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	print(InputMap.get_action_list(action)[0].as_text())
	text = "%s " % event.as_text().to_upper()


func display_current_key():
	var current_key = "..."
	for event in InputMap.get_action_list(action):
		if check_type(input_type_str, event):
			current_key = event.as_text()
			break
	text = "%s " % current_key.to_upper()
