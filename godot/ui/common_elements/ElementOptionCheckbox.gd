@tool
extends GenericOption

@onready var value_node = $ElementCheckbox
@onready var description_node = $ElementCheckbox
	
func setup():
	if not label_description:
		label_description = element_path

	description_node.text = label_description.to_upper()
	value = node_owner.get(element_path)
	value_node.button_pressed = value


func _on_ElementCheckbox_toggled(button_pressed):
	value = button_pressed
	node_owner.set(element_path, value)


func _on_MarginContainer_focus_entered():
	set_process_input(true)
	


func _on_MarginContainer_focus_exited():
	set_process_input(false)
	


func focus():
	get_child(0).grab_focus()


func _on_ElementCheckbox_focus_entered():
	value_node.set("theme_override_colors/font_pressed_color",Color(0,0,0))
	

func _on_ElementCheckbox_focus_exited():
	value_node.set("theme_override_colors/font_pressed_color", null)

