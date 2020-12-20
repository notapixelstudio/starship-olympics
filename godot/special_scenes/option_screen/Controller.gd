extends Sprite

class_name Controller

export var device: String setget _set_device
onready var device_id: int = int(device.replace("joy", ""))

func _set_device(value):
	if not "joy" in value:
		return
	device = value
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
		if input_event is InputEventJoypadButton:
			var btn = (input_event as InputEventJoypadButton).button_index
			clear_button(get_node(str(btn)))
			
			
func clear_button(button:Node2D):
		button.get_node("Sprite").modulate.a = 0
		button.get_node("Line2D").visible =false

func _ready():
	# let's hide them all 
	for button in get_children():
		if button is Sprite:
			clear_button(button)
	toggle(false)
	

func setup_controls(controls: Dictionary):
	print(" controls: " + str(controls))
	if not device in controls:
		print("MA VEEEROO??")
		return
	
	for c in controls[device]:
		for control in c:
			var control = c
			map_control(self.device+"_"+key, control)
			print(self.device+"_"+key, control)
			var button = get_node(control.to_upper())
			button.visible = true
			button.get_node("Line2D").visible =true
			button.get_node("Line2D/Label").text = key
	
	
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
