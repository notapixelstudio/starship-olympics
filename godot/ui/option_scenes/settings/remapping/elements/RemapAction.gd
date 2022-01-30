tool
extends Control

class_name CommandRemap

onready var scroll_container = $Container/ScrollContainer
# this needs always to be on screen
onready var panel = $Panel
onready var description_node = $Container/Description

export var remapScene: PackedScene
export var action: String
export var device: String setget _set_device
export var button_scene : PackedScene
signal clear_mapping
signal remap


func _process(delta):
	$Container/Description.text = tr(action.to_upper())

func clear():
	scroll_container.clear()
	
func fill_mapping():
	for event in InputMap.get_action_list(self.device + "_" + self.action):
		add_mapping_to_screen(event)
		
func setup():
	clear()
	fill_mapping()
	
func _set_device(value_):
	device = value_
	if not is_inside_tree():
		yield(self, "ready")
	setup()
	
func _on_Button_try_remap(action):
	emit_signal("try_remap", action)
	
func on_remap(event: InputEvent, device: String, action: String, substitute=true):
	"""
	Add new mapping for the device and< action. Remove the existing mapping, 
	if any
	"""
	var device_type = "kb"
	if "joy" in device:
		device_type = "joy"
	if self.device == "kb" and not event is InputEventKey:
		print("Can't map Input different than keyboard events")
		return
	if self.device == "joy" and not event is InputEventJoypadButton and not event is InputEventJoypadMotion:
		print("Can't map Input different than joypad events")
		return
		 
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
	# save
	persistance.save_game()


func add_mapping_to_screen(new_event: InputEvent):
	scroll_container.add_event(new_event)
	
func _on_Button_pressed():
	var remap : AddingBindingControls = remapScene.instance()
	remap.action = device + "_" + action
	add_child(remap)
	remap.connect("remap", self, "on_remap", [device, action])

func remove_mapping(event):
	for button in scroll_container.get_elements():
		var event_text = global.event_to_text(event)
		var this_event_text = global.event_to_text(button.get_event())
		if this_event_text["key"] == event_text["key"] and this_event_text["device_id"] == event_text["device_id"]:
			global.clear_mapping(self.device + "_" + self.action, event)
			button.queue_free()
	

func _on_RemoveMapping_pressed():
	global.clear_all_mapping(self.device + "_" + self.action)
	scroll_container.clear()
	
func _input(event):
	if event.is_action_pressed("ui_accept"):
		Events.emit_signal("ask_mapping_action", self.device + "_" + self.action)
		_on_focus_exited()


func _on_focus_entered():
	# WARNING: I had to manually set to the "self" node the FocusMode=All in 
	# order to this to work
	# will ask the event bus to show the info
	Events.emit_signal("show_info", "controls")
	set_process_input(true)
	panel.add_stylebox_override("panel", load("res://interface/themes/olympic/focus.tres"))
	description_node.set("custom_colors/font_color",Color(0,0,0))


func _on_focus_exited():
	# WARNING: I had to manually set to the "self" node the FocusMode=All in 
	# order to this to work
	# will ask the event bus to hide the info
	Events.emit_signal("hide_info") 
	panel.add_stylebox_override("panel", load("res://interface/themes/olympic/normal.tres"))
	description_node.set("custom_colors/font_color", null)
	set_process_input(false)
