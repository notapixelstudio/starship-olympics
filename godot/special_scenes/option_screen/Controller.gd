extends Sprite

class_name Controller

export var device_id: int

onready var controls = "joy"+str(device_id)
	
var command_list = ["up, down, left, right, fire"]

func clear_button(button:Node2D):
		button.get_node("Sprite").modulate.a = 0
		button.get_node("Line2D").visible =false

func _ready():
	# let's hide them all 
	for button in get_children():
		clear_button(button)
	

func setup_controls(controls: Dictionary):
	for key in controls:
		for c in controls[key]:
			var control = global.invert_map(global.joy_input_map)[c]
			map_control(self.controls+"_"+key, control)
			var button = get_node(control.to_upper())
			button.visible = true
			button.get_node("Line2D").visible =true
			button.get_node("Line2D/Label").text = key
	
	
func handle_button(joy_event: InputEventJoypadButton):
	get_node(str(joy_event.button_index)).show_button(joy_event)
			
func _input(event):
	
	if event.device != self.device_id -1 :
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
	for input_event in InputMap.get_action_list(action):
		if input_event is InputEventJoypadButton:
			var btn = (input_event as InputEventJoypadButton).button_index
			clear_button(get_node(str(btn)))
			print("Shutting down: ", str(btn))
	var button = get_node(mapped_control.strip_edges().to_upper())
	button.text = action.to_upper()
	button.visible = true
	button.get_node("Line2D").visible =true
