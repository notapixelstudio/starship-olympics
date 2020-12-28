extends Sprite

class_name Controller

export var device: String setget _set_device
onready var device_id: int = int(device.replace("joy", ""))

func _set_device(value):
	if not "joy" in value:
		return
	device = value
	device_id = int(device.replace("joy", ""))
	var mapping = {}
	for key in global.input_mapping:
		if device in key:
			mapping[key] = global.input_mapping[key]
	setup_controls({device:mapping})
	if not is_inside_tree():
		yield(self, "ready")
	$Label.text = device

var command_list = ["up", "down", "left", "right", "fire"]

func toggle(value):
	visible = value
	set_process_input(value)
		
	
func clear_controls(action: String):
	for input_event in InputMap.get_action_list(action):
		var btn = global.event_to_text(action, input_event).to_upper()
		clear_button(get_node(str(btn)))
		
			
			
func clear_button(button:Node2D):
		button.get_node("Sprite").modulate.a = 0
		button.get_node("Line2D").visible =false

func empty_controls():
	for button in get_children():
		if button is Sprite:
			clear_button(button)

func _ready():
	# let's hide them all 
	empty_controls()
	toggle(false)
	

func setup_controls(controls: Dictionary):
	print(" controls: " + str(controls))
	empty_controls()
	if not device in controls:
		return
	
	for complete_control in controls[device]:
		var commands = controls[device][complete_control]
		for command in commands:
			var action = complete_control.replace(str(device)+"_", "")
			map_control(action, command)
			var button = get_node(command.to_upper())
			button.visible = true
			button.get_node("Line2D").visible =true
			button.get_node("Line2D/Label").text = action
		
	
func handle_button(joy_event: InputEventJoypadButton):
	get_node(str(joy_event.button_index)).show_button(joy_event)
			
func _input(event):
	
	if event.device != self.device_id:
		return
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
		
	if event is InputEventJoypadButton:
		handle_button(event)

func map_control(action:String , mapped_control: String):
	var button = get_node(mapped_control.strip_edges().to_upper())
	button.text = action.to_upper()
	button.visible = true
	button.get_node("Line2D").visible =true
