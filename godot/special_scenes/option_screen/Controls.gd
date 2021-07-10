extends Control

onready var device = $VBoxContainer/Element.value

func _ready():
	for child in get_children():
		if child is CommandRemap:
			child.connect("clear_mapping", self, "clear_mapping")
			child.connect("remap", self, "control_remapped")
	
func _on_Element_value_changed(value):
	device = value
	if not is_inside_tree():
		yield(self, "ready")
	# we need to wait a frame in order to wait that everything will be available
	yield(get_tree(), "idle_frame")
	for child in get_children():
		if child is CommandRemap:
			child.visible = true
			child.device = value
			
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
