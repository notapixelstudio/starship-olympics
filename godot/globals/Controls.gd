extends Node

const PERSIST_GROUP = "persist_controls"
func _ready():
	add_to_group(PERSIST_GROUP)

# INPUT MAPPING
const INPUT_ACTIONS = ["kb1", "kb2", "joy1", "joy2", "joy3", "joy4","rm1","rm2","rm3","rm4"]
var input_mapping : Dictionary setget _set_input_mapping, _get_input_mapping

var joy_input_map = {
	"analog_0_1"  : ["Left_Stick_Right"],
	"analog_0_-1" : ["Left_Stick_Left"],
	"analog_1_1"  : ["Left_Stick_Down"],
	"analog_1_-1" : ["Left_Stick_Up"],
	"analog_2_1"  : ["Right_Stick_Right"],
	"analog_2_-1" : ["Right_Stick_Left"],
	"analog_3_1"  : ["Right_Stick_Down"],
	"analog_3_-1" : ["Right_Stick_Up"],
	"0": ["Cross", "A"],
	"1": ["Circle", "B"],
	"2": ["Square", "X"],
	"3": ["Triangle", "Y"],
	"4": ["L1", "LB"],
	"5": ["R1", "RB"],
	"6": ["L2", "LT"],
	"7": ["R2", "RT"],
	"8": ["Left_Stick_Click"],
	"9": ["Right_Stick_Click"],
	"10": ["Select", "Windows"],
	"11": ["Start", "Menu"],
	"12": ["Dpad_Up"],
	"13": ["Dpad_Down"],
	"14": ["Dpad_Left"],
	"15": ["Dpad_Right"]
}

var map_input_joy := {
	"ps": {
		"Cross": "0",
		"Square": "1",
		"Circle": "2",
		"Triangle": "3",
		"L1": "4",
		"R1": "5",
		"L2": "6",
		"R2": "7",
		"Dpad_Right": "15",
		"Left_Stick_Right": "analog_0_1",
		"Dpad_Left": "14",
		"Left_Stick_Left": "analog_0_-1",
		"Dpad_Down": "13",
		"Left_Stick_Down": "analog_1_1",
		"Dpad_Up": "12",
		"Left_Stick_Up": "analog_1_-1"
	}
}

func human_readable_button(joypad_type: String, button_key: String) -> String:
	var button_can_be:Array = Controls.joy_input_map[button_key]
	for button in button_can_be:
		if button in Controls.map_input_joy[joypad_type].keys():
			return button
	return ""
	
var keyboard_input_map = {
	"Up": "Arrow_Up",
	"Down": "Arrow_Down",
	"Left": "Arrow_Left",
	"Right": "Arrow_Right",
	"BackSpace": "Backspace_Alt",
	"*": "Asterisk",
	"Escape": "Esc",
	"Kp Enter": "Enter_Tall"
}


func event_to_text(event: InputEvent) -> Dictionary:
	"""
	event: @type InputEvent
	return the event in a human readable form. For reference `joy_input_map`
	"""
	if event is InputEventKey:
		var key = event.as_text()
		if key in keyboard_input_map:
			key = keyboard_input_map[key]
		return {"key": key, "device_id": event.device, "device": "kb"}
	elif event is InputEventJoypadButton:
		return {"key": str(event.button_index), "device_id": event.device, "device": "joy"}
	elif event is InputEventJoypadMotion:
		if event.axis_value > 0:
			event.axis_value = 1
		else:
			event.axis_value = -1
		var command = "analog_"+str((event as InputEventJoypadMotion).axis) + "_" + str((event as InputEventJoypadMotion).axis_value)
		return {"key": command, "device_id": event.device, "device": "joy"}
	return {"key": null, "device_id": null, "device": null}
	
	
func event_from_text(device: String, command: String, device_id: int = 0) -> InputEvent:
	"""
	device: e.g. kb1, kb2, joy1, joy2
	command: e.g. 0, 1, 2 , analog_1_-1, M, N 
	device_id: device_id (for keyboard it's only 0)
	"""
	var e : InputEvent
	if "kb" in device:
		var inverted_input_map = global.invert_map(keyboard_input_map)
		var command_text = command
		if command_text in inverted_input_map:
			command_text = inverted_input_map[command_text]
		command_text = OS.find_scancode_from_string(command_text)
		e = InputEventKey.new()
		e.scancode = command_text
	elif "joy" in device:
		if "analog" in command:
			e = InputEventJoypadMotion.new()
			e.axis = int(command.split("_")[1])
			e.axis_value = int(command.split("_")[2])
		else:
			e = InputEventJoypadButton.new()
			e.button_index = int(command)
		e.device = device_id
	return e

func _set_input_mapping(value_):
	"""
	will add the entire input dictionary to the game
	"""
	input_mapping=value_
	for device in INPUT_ACTIONS:
		for action in input_mapping:
			if device in action:
				var commands = input_mapping[action]
				var events = []
				for command in commands:
					var event = event_from_text(device, command["key"], command["device_id"])
					events.append(event)
				remap_multiple_actions_to(action, events)
	
func _get_input_mapping():
	var ret = {}
	for device in INPUT_ACTIONS:
		for action in InputMap.get_actions():
			if device in action:
				ret[action] = []
				for event in InputMap.get_action_list(action):
					ret[action].append(event_to_text(event))
	return ret

var default_input_joy := {
	"fire": ["Cross", "Square", "Circle", "Triangle", "L1", "R1", "L2", "R2"], 
	"right": ["Dpad_Right", "Left_Stick_Right"],
	"left": ["Dpad_Left", "Left_Stick_Left"], 
	"down": ["Dpad_Down", "Left_Stick_Down"],
	"up":["Dpad_Up", "Left_Stick_Up"]
}

var presets_path := {
	"kb_default": "res://assets/config/mapping_presets/keyboard_default.json",
	"kb_minimal": "res://assets/config/mapping_presets/keyboard_minimal.json",
	"joy_default": "res://assets/config/mapping_presets/joypad_default.json",
	"joy_minimal": "res://assets/config/mapping_presets/joypad_minimal.json"
}

var default_input :=  {
	"kb1": {
		"fire":["M"], "down":["Down"], "left":["Left"], "right":["Right"], "up":["Up"]
	},
	"kb2": { 
		"down":["S"], "fire":["1"], "left":["A"], "right":["D"], "up":["W"]
	},
	"joy1": default_input_joy,
	"joy2": default_input_joy,
	"joy3": default_input_joy,
	"joy4": default_input_joy
}

var input_mapping_joy := {
	"joy1": default_input_joy,
	"joy2": default_input_joy,
	"joy3": default_input_joy,
	"joy4": default_input_joy
}

var array_joylayout = ["default", "setup1", "setup2", "setup3", "custom"]
onready var joylayout: String = array_joylayout[0] setget _set_joylayout, _get_joylayout

func _set_joylayout(value):
	joylayout = value

func _get_joylayout():
	return joylayout


func set_presets(action_device: String, preset_value: String) -> Dictionary:
	"""
	params:
	 action_device: String - the device we want to use the presets of. (e.g.: kb1|kb2|joy1|joy2|etc.)
	 preset: String - preset value we want to change to (e.g.: minimal|complete|etc.) - same content of the files you can find in presets_path
	return:
	 will set the 'presets' mapping and return its dictionary
	"""
	var ret_mapping = {}
	var device_category = action_device.substr(0, len(action_device)-1)
	var device_name = action_device
	if "joy" in action_device:
		device_name = "joy"
	
	var file = presets_path["{device}_{preset_value}".format({"device":device_category, "preset_value": preset_value})]
	var preset_dictionary = parse_json(global.read_file(file))
	
	var this_mapping = preset_dictionary[device_name]
	for action_name in this_mapping:
		var complete_action = action_device + "_" + action_name
		var events = []
		for command_object in this_mapping[action_name]:
			var button = command_object["key"]
			var device = command_object["device"]
			var device_id = command_object["id"]
			if device_id < 0:
				device_id = int(action_device.right(len(action_device)-1))-1
			
			var event = event_from_text(device, button, device_id)
			events.append(event)
		remap_multiple_actions_to(complete_action, events)
		ret_mapping[complete_action] = this_mapping[action_name]
	persistance.save_game()
	return ret_mapping
	
func check_input_event(action_: String, event:InputEvent):
	return event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion

func clear_mapping(action:String, event: InputEvent):
	InputMap.action_erase_event(action, event)
	var alert_scene = load("res://interface/OverlayMessage.tscn").instance()
	alert_scene.message = "ACTION BINDING FOR [color=red]{action}[/color] OVERRIDDEN".format({"action": action.to_upper()})
	add_child(alert_scene)
	alert_scene.raise()
	
func clear_all_mapping(action: String):
	InputMap.action_erase_events(action)
	
func remap_multiple_actions_to(action: String, new_events: Array, ui_flag=true) -> String:
	"""
	new_events: Array[InputEvent]
	Will delete the events from the actions in order to put the new ones
	"""
	var current_key = ""
	
	if ui_flag:
		var acts = action.split("_")
		var id = acts[len(acts)-1]
		if id == "fire":
			id = "accept"
		var ui_action = "ui_"+id
		#TODO: remove only the existing control for that player
		for event in InputMap.get_action_list(action):
			InputMap.action_erase_event(ui_action, event)
		for new_event in new_events:
			InputMap.action_add_event("ui_"+id, new_event)
	InputMap.action_erase_events(action)
	for new_event in new_events:
		InputMap.action_add_event(action, new_event)
	return action

func remap_action_to(action: String, new_event: InputEvent) -> Dictionary:
	"""
	Given an action, and an InputEvent will set an event.
	You might pass the previous event if it's a substitution
	return event to text
	param: 
		action: e.g. kb1_fire
	"""
	var current_key = ""
	var acts = action.split("_")
	var id = acts[len(acts)-1]
	InputMap.action_add_event(action, new_event)
	return Controls.event_to_text(new_event)



# utils
func get_state():
	"""
	get_state will return everything we need to be persistent in the game
	"""
	return {
		input_mapping=self.input_mapping
	}
	

func load_state(data:Dictionary):
	"""
	Set back everything we need to load
	"""
	for attribute in data:
		set(attribute, data[attribute])
