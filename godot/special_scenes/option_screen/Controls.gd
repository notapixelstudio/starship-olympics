extends VBoxContainer

onready var device = $Element.value


func _on_Element_value_changed(value):
	device = value
	
	for child in get_children():
		if child is CommandRemap:
			if "kb" in value:
				child.visible = true
				child.device = value
			elif "joy" in value:
				child.visible=false

func _on_Default_pressed():
	global.set_default_mapping(device)
	_on_Element_value_changed(device)

