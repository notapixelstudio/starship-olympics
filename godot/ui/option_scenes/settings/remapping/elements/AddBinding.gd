extends ColorRect

class_name AddingBindingControls

export var action: String
signal remap

func _ready():
	set_process_input(false)
	yield(get_tree().create_timer(1), "timeout")
	set_process_input(true)
	
func check_input_event(event:InputEvent):
	if "kb" in self.action:
		return event is InputEventKey
	elif "joy" in self.action:
		var device = int(self.action.split("_")[0].replace("joy", ""))-1
		# event.axis equal to 6 and 7 are the anaolog axis. from Godot 3.2.4
		return (event is InputEventJoypadButton or (event is InputEventJoypadMotion and event.axis != 7 and event.axis != 6))


func _input(event):
	# Note that you can use the _input callback instead, especially if
	# you want to work with gamepads.
	if check_input_event(event) and event.is_pressed():
		# DO NOTHING if less than DEADZONE
		if event is InputEventJoypadMotion:
			if abs(event.axis_value) < 0.5:
				return
		Events.emit_signal("remap_event", event)
		set_process_input(false)
		queue_free()
