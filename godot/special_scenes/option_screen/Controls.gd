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
	if not is_inside_tree():
		yield(self, "ready")
	yield(get_tree(), "idle_frame")
	for child in get_children():
		if child is CommandRemap:
			child.visible = true
			child.device = value
			child.setup()
		elif child is Controller:
			child.device = value
			child.toggle("joy" in device)
			
func _on_Default_pressed():
	var mapping = global.set_default_mapping(device)
	joypad.setup_controls(mapping)
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
	joypad.clear_controls(action)
