tool
extends Control

class_name RemapAction

onready var scroll_container = $Container/ScrollContainer
# this needs always to be on screen
onready var panel = $Panel
onready var description_node = $Container/Description

export var action: String
export var device: String setget _set_device
export var button_scene : PackedScene
signal clear_mapping

func _ready():
	# Events.connect("remap_event", self, "on_remap")
	set_process_input(false)
	
func _process(delta):
	$Container/Description.text = tr(action.to_upper())

func clear():
	scroll_container.clear()
	
func fill_mapping():
	for event in InputMap.get_action_list(self.device + "_" + self.action):
		var event_text = Controls.event_to_text(event)
		var event_device = event_text["device"]
		var event_device_id = event_text["device_id"]
		if event_device in device or device == "ui":
			add_mapping_to_screen(event)
		
func setup():
	clear()
	fill_mapping()
	
func _set_device(value_):
	device = value_
	if not is_inside_tree():
		yield(self, "ready")
	setup()
	
func on_remap(event: InputEvent, complete_action: String):
	# self.check_if_already_exist(Controls.event_to_text(), Controls.input_mapping)
	for action in Controls.input_mapping:
		if not self.device in action:
			continue
		for command_dict in Controls.input_mapping[action]:
			if Controls.event_to_text(event).hash() == command_dict.hash():
				print("This exists already in " + action)
	var new_control_key = Controls.remap_action_to(complete_action, event)
	# just to be sure, will refill everything
	self.setup()
	# save
	persistance.save_game()
	Events.emit_signal("remap_done", self)
	grab_focus()
	
func add_mapping_to_screen(new_event: InputEvent):
	scroll_container.add_event(new_event)
	
func remove_mapping(event):
	for button in scroll_container.get_elements():
		var event_text = Controls.event_to_text(event)
		var this_event_text = Controls.event_to_text(button.get_event())
		if this_event_text["key"] == event_text["key"] and this_event_text["device_id"] == event_text["device_id"]:
			Controls.clear_mapping(self.device + "_" + self.action, event)
			button.queue_free()
	

func _on_RemoveMapping_pressed():
	Controls.clear_all_mapping(self.device + "_" + self.action)
	scroll_container.clear()
	
func _input(event):
	if event.is_action_pressed("ui_accept"):
		Events.emit_signal("ask_mapping_action", self.device + "_" + self.action, self)
		_on_focus_exited()


func _on_focus_entered():
	# WARNING: I had to manually set to the "self" node the FocusMode=All in 
	# order to this to work
	# will ask the event bus to show the info
	Events.emit_signal("show_info", "controls")
	panel.add_stylebox_override("panel", load("res://interface/themes/olympic/focus.tres"))
	description_node.set("custom_colors/font_color",Color(0,0,0))
	set_process_input(true)

func _on_focus_exited():
	# WARNING: I had to manually set to the "self" node the FocusMode=All in 
	# order to this to work
	# will ask the event bus to hide the info
	Events.emit_signal("hide_info") 
	panel.add_stylebox_override("panel", load("res://interface/themes/olympic/normal.tres"))
	description_node.set("custom_colors/font_color", null)
	set_process_input(false)
