tool
extends MarginContainer

class_name CommandRemap

onready var buttons = $Container/ScrollContainer
# this needs always to be on screen

export var remapScene: PackedScene
export var remapButton: PackedScene
export var action: String
export var device: String setget _set_device
export var button_scene : PackedScene
signal clear_mapping
signal remap

onready var add = $Container/AddMapping


# TODO: maybe put it in ShowedButton ???
func get_metadata_from_event(event:InputEvent) :
	if event is InputEventKey:
		return {"device_type": "kb", "device": event.device, "button": global.event_to_text(event)}
	elif event is InputEventJoypadButton:
		return {"device_type": Input.get_joy_name(event.device), "device": event.device, "button": global.event_to_text(event)}
	elif event is InputEventJoypadMotion:
		return {"device_type": Input.get_joy_name(event.device), "device": event.device, "button": global.event_to_text(event)}
	

func _process(delta):
	$Container/Description.text = action

func _ready():
	var i = 0
	for event in InputMap.get_action_list(self.device + "_" + self.action):
		add_mapping_to_screen(event)
	
func _set_device(value_):
	device = value_
	if not is_inside_tree():
		yield(self, "ready")


func _on_Button_remapped(action: String, new_control: String):
	emit_signal("remapped", action, new_control)


func _on_Button_try_remap(action):
	emit_signal("try_remap", action)
	
func on_remap(event, device, action):
	"""
	Add new mapping for the device and action
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
	var new_control_key = global.remap_action_to(device + "_" + action, event)
	emit_signal("remap", action, new_control_key)
	add_mapping_to_screen(event)
	add.disabled = true
	yield(get_tree().create_timer(0.1), "timeout")
	add.disabled = false
	# save
	persistance.save_game()


func add_mapping_to_screen(new_event: InputEvent):
	var button: ShowedButton = button_scene.instance()
	var metadata = get_metadata_from_event(new_event)
	button.set_button(metadata['device_type'], metadata['button'], metadata['device'])
	buttons.add_button(button)
	
func _on_Button_pressed():
	var remap : MapButtonScene = remapScene.instance()
	add_child(remap)
	remap.connect("remap", self, "on_remap", [device, action])


func _on_RemoveMapping_pressed():
	print("clear mapping")
	
