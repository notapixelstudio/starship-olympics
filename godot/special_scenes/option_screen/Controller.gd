extends Sprite

export var device = 1

onready var controls = "joy"+str(device)

func _ready():
	# let's hide them all 
	for button in get_children():
		button.visible = false

func setup_controls(controls: Dictionary):
	for key in controls:
		var button = get_node(key)
		button.visible = true
		button.get_node("Line2D/Label").text = controls[key]
	
	
func handle_button(event, event_name: String):
	for joy_event in InputMap.get_action_list(event_name):
		if joy_event is InputEventJoypadButton:
			get_node(str(joy_event.button_index)).visible = event.is_action_pressed(event_name)

func show_input(event):
	#if event is InputEventJoypadButton:
	#	get_node(str(event.button_index)).visible = event.pressed
	if event is InputEventJoypadMotion:
		if event.axis==0:
			$AnalogLeft/Sprite.position.x = event.axis_value*10
		if event.axis==1:
			$AnalogLeft/Sprite.position.y = event.axis_value*10
		if event.axis==2:
			$AnalogRight/Sprite.position.x = event.axis_value*10
		if event.axis==3:
			$AnalogRight/Sprite.position.y = event.axis_value*10
		#$AnalogLeft.modulate.a = abs($AnalogLeft/Sprite.position.normalized())
		#$AnalogRight.modulate.a = abs($AnalogRight/Sprite.position.normalized())
		print(event.get_action_strength(controls+"_left"))
		
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
	
