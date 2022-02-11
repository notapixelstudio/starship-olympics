extends Control

var device
export (String, "keyboard", "joypad", "custom") var device_type = "keyboard"
onready var device_node = $VBoxContainer/Device
onready var actions_container = $VBoxContainer/UIButtonsContainer

func setup_device(new_device_type: String):
	device_type = new_device_type
	var path = device_type + "_device"
	device_node.element_path = path
	device_node.setup()
	
func _ready():
	var path = device_type + "_device"
	device_node.element_path = path
	device_node.setup()
	for child in get_tree().get_nodes_in_group("remapping_actions"):
		child.connect("clear_mapping", self, "clear_mapping")
		child.connect("remap", self, "control_remapped")
			
	
func _on_Device_value_changed(value):
	device = value
	if device == null:
		return
	if not is_inside_tree():
		yield(self, "ready")
	# we need to wait a frame in order to wait that everything will be available
	yield(get_tree(), "idle_frame")
	for child in get_tree().get_nodes_in_group("remapping_actions"):
			child.visible = true
			child.device = value
			child.setup()
			
func _on_Default_pressed():
	var mapping = global.set_presets(device, device.substr(0, len(device)-1) +"_default")
	_on_Device_value_changed(device)

func control_remapped(action: String, event: InputEvent, substitute: bool):
	for child in get_children():
		if child is RemapAction:
			child.remove_mapping(event)
	if not "joy" in action:
		return

func clear_mapping(action: String):
	if not "joy" in action:
		return


func _on_Preset_value_changed(value):
	if value == null:
		return
	var device_name = device
	if "joy" in device:
		device_name = "joy"
	var mapping = global.set_presets(device_name, device.substr(0, len(device)-1) +"_" + value)
	_on_Device_value_changed(device)
