extends Sprite

export var device = 1

onready var controls = "joy"+str(device)

func handle_button(event, event_name: String):
	for joy_event in InputMap.get_action_list(event_name):
		if joy_event is InputEventJoypadButton:
			get_node(str(joy_event.button_index)).visible = event.is_action_pressed(event_name)
	
func _input(event):
	#if event is InputEventJoypadButton:
	#	get_node(str(event.button_index)).visible = event.pressed
	if event.is_action_pressed(controls+"_fire"):
		handle_button(event, controls+"_fire")
	elif event.is_action_released(controls+"_fire"):
		handle_button(event, controls+"_fire")
			
	if event.is_action_pressed(controls+"_left"):
		handle_button(event, controls+"_left")
			
	elif event.is_action_released(controls+"_left"):
		handle_button(event, controls+"_left")
			
	if event.is_action_pressed(controls+"_right"):
		handle_button(event, controls+"_right")
			
	elif event.is_action_released(controls+"_right"):
		handle_button(event, controls+"_right")
			
	if event.is_action_pressed(controls+"_up"):
		handle_button(event, controls+"_up")
	elif event.is_action_released(controls+"_up"):
		handle_button(event, controls+"_up")
			
	if event.is_action_pressed(controls+"_down"):
		handle_button(event, controls+"_down")
		
	elif event.is_action_released(controls+"_down"):
		handle_button(event, controls+"_down")
			
