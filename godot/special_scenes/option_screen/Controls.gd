extends VBoxContainer

onready var device = $Element.value

func _on_Element_value_changed(value):
	device = value
	for child in get_children():
		if child is CommandRemap:
			child.device = value
	
