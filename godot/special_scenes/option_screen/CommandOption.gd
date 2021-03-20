tool
extends MarginContainer

class_name CommandRemap

onready var scroll_container = $Container/ScrollContainer
# this needs always to be on screen

export var remapScene: PackedScene
export var action: String
export var device: String setget _set_device
export var button_scene : PackedScene
signal clear_mapping
signal remap

onready var add = $Container/AddMapping


func _process(delta):
	$Container/Description.text = action

func clear():
	scroll_container.clear()
	
func fill_mapping():
	for event in InputMap.get_action_list(self.device + "_" + self.action):
		add_mapping_to_screen(event)
		
func _ready():
	var i = 0
	setup()

func setup():
	clear()
	fill_mapping()
	
func _set_device(value_):
	device = value_
	if not is_inside_tree():
		yield(self, "ready")
	
	


func _on_Button_try_remap(action):
	emit_signal("try_remap", action)
	
func on_remap(event: InputEvent, device: String, action: String, substitute=true):
	"""
	Add new mapping for the device and action. Remove the existing mapping, 
	if any
	"""
	var device_type = "kb"
	if "joy" in device:
		device_type = "joy"
	var device_action = device + "_" + action
	for action in global.input_mapping:
		if not device_type in action:
			continue
		for command in global.input_mapping[action]:
			if global.event_to_text(event) == command:
				if action == device_action:
					print("This exists already in " + action)
					return
				if substitute:
					print("found in " + action)
					global.clear_mapping(action, event)
					
	
	var new_control_key = global.remap_action_to(device_action, event)
	emit_signal("remap", action, event, substitute)
	add_mapping_to_screen(event)
	add.disabled = true
	yield(get_tree().create_timer(0.1), "timeout")
	add.disabled = false
	# save
	persistance.save_game()


func add_mapping_to_screen(new_event: InputEvent):
	var button: ShowedButton = button_scene.instance()
	button.set_button(new_event)
	scroll_container.add_element(button)
	
func _on_Button_pressed():
	var remap : MapButtonScene = remapScene.instance()
	remap.action = device + "_" + action
	add_child(remap)
	remap.connect("remap", self, "on_remap", [device, action])

func remove_mapping(event):
	for button in scroll_container.get_elements():
		if global.event_to_text(button.get_event()) == global.event_to_text(event):
			global.clear_mapping(self.device + "_" + self.action, event)
			button.queue_free()
	
	
func _on_RemoveMapping_pressed():
	global.clear_all_mapping(self.device + "_" + self.action)
	scroll_container.clear()
	
