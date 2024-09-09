extends Panel

class_name RemappingScene

@export var action: String
@export var device_category: String

signal remap_event

func _ready():
	grab_focus()
	$Action.text = tr(action)
	set_process_input(false)
	await get_tree().create_timer(1).timeout
	set_process_input(true)
	
func check_input_event(event:InputEvent):
	return event is InputEventKey or  (event is InputEventJoypadButton or 
		(event is InputEventJoypadMotion and event.axis != 7 and event.axis != 6))
	if "keyboard" in self.device_category:
		return event is InputEventKey
	elif "joypad" in self.device_category:
		return (event is InputEventJoypadButton or (event is InputEventJoypadMotion and event.axis != 7 and event.axis != 6))


func _input(event):
	# Note that you can use the _input callback instead, especially if
	# you want to work with gamepads.
	if check_input_event(event):
		# DO NOTHING if less than DEADZONE
		if event is InputEventJoypadMotion:
			if abs(event.axis_value) < 0.5:
				return
		print("Asking to remap: {action} with event {event}".format({"action": action, 
			"event": event}))
		set_process_input(false)
		$ButtonRepresentation.set_button(event)
		$ButtonRepresentation.visible = true
		await get_tree().create_timer(1).timeout
		emit_signal("remap_event", event, action)
		queue_free()
