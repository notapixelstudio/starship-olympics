extends Button

class_name RemapButton

export var action: String = "ui_up" setget _set_action
export var index: int = 1 # if index is -1 it's the add button
var current_event: InputEvent

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
	set_process_input(false)

func setup(action_, index_):
	"Called by its parent whenever action and index is ready"
	self.action = action_
	self.index = index_
	if self.index >= 0:
		self.current_event = InputMap.get_action_list(action)[index]
		display_current_key()
	else:
		text = "   %s   " % "+"


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
		self.current_event = event
		pressed=false
		
func is_add_button():
	return index < 0
	
func display_current_key():
	var current_key = global.event_to_text(self.current_event)
	var keys = []
	# JUST FOR MAPPING JOY
	if "joy" in action:
		current_key = global.joy_input_map[current_key]
	if current_key:
		text = "   %s   " % current_key.to_upper()


