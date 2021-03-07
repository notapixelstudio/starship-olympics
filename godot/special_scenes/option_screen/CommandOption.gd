tool
extends MarginContainer

class_name CommandRemap

onready var buttons = $Container/Buttons
# this needs always to be on screen
onready var add = $Container/Add

export var remapButton: PackedScene
export var action: String
export var device: String setget _set_device

signal clear_mapping
signal remap



func _process(delta):
	$Container/Description.text = action

func _ready():
	var i = 0
	for event in InputMap.get_action_list(self.device + "_" + self.action):
		var button: RemapButton = remapButton.instance()
		buttons.add_child(button)
		buttons.move_child(button, 0)
		button.setup(self.device + "_" + self.action, i)
		button.connect("remap", self, "_on_Button_remap", [button])
		i+=1
	add_button()
	
func _set_device(value_):
	device = value_
	if not is_inside_tree():
		yield(self, "ready")


func _on_Button_remapped(action: String, new_control: String):
	emit_signal("remapped", action, new_control)


func _on_Button_try_remap(action):
	emit_signal("try_remap", action)

func add_button():
	# This is needed everytime we add a new button, that will be replaced
	var add_button : RemapButton = remapButton.instance()
	buttons.add_child(add_button)
	add_button.setup(self.device + "_" + self.action, -1)
	add_button.connect("remap", self, "_on_Button_remap", [add_button])
	
func _on_Button_remap(action, event, button:RemapButton):
	"""
	Called from the button itself
	"""
	var found = false
	var text = global.event_to_text(event)
	for action in global.input_mapping:
		if device in action:
			for command in global.input_mapping[action]:
				if text == command:
					found = true
	if found:
		print("I can't sorry, because someone else uses it")
		return
	var new_control_key = global.remap_action_to(action, event, button.current_event)
	var text_to_button = new_control_key
	if new_control_key in global.joy_input_map:
		text_to_button = global.joy_input_map[new_control_key]
	if button.is_add_button():
		add_button()
	emit_signal("remap", action, new_control_key)
	button.disabled = true
	yield(get_tree().create_timer(0.4), "timeout")
	button.disabled = false
	# save
	persistance.save_game()
