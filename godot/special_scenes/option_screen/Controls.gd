extends VBoxContainer

onready var device = $Element.value
onready var joypad = $Controller

func _ready():
	for child in get_children():
		if child is CommandRemap:
			child.connect("clear_mapping", self, "clear_mapping")
			child.connect("remap", self, "control_remapped")
	
func _on_Element_value_changed(value):
	device = value
	
	for child in get_children():
		if child is CommandRemap:
			child.visible = true
			child.device = value
		elif child is Controller:
			child.visible = true
			child.device_id = device

func _on_Default_pressed():
	global.set_default_mapping(device)
	_on_Element_value_changed(device)

func control_remapped(action: String, new_control: String):
	if not "joy" in action:
		return
	joypad.map_control(action.split("_")[1], new_control)

func clear_mapping(action: String):
	if not "joy" in action:
		return
	joypad.clear_controls(action)
