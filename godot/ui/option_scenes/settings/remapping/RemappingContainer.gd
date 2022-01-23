extends Control

var device
export (String, "keyboard", "joypad", "custom") var device_type = "keyboard"
onready var device_node = $Device

func setup_device(new_device_type: String):
	device_type = new_device_type
	var path = device_type + "_device"
	device_node.element_path = path
	device_node.setup()
	
func _ready():
	var path = device_type + "_device"
	device_node.element_path = path
	device_node.setup()
	for child in get_children():
		if child is CommandRemap:
			child.connect("clear_mapping", self, "clear_mapping")
			child.connect("remap", self, "control_remapped")
			
	
func _on_Element_value_changed(value):
	device = value
	if device == null:
		return
	if not is_inside_tree():
		yield(self, "ready")
	# we need to wait a frame in order to wait that everything will be available
	yield(get_tree(), "idle_frame")
	for child in $UIButtonsContainer.get_children():
		if child is CommandRemap:
			child.visible = true
			child.device = value
			child.setup()
			
func _on_Default_pressed():
	var mapping = global.set_default_mapping(device)
	_on_Element_value_changed(device)

func control_remapped(action: String, event: InputEvent, substitute: bool):
	for child in get_children():
		if child is CommandRemap:
			child.remove_mapping(event)
	if not "joy" in action:
		return

func clear_mapping(action: String):
	if not "joy" in action:
		return
