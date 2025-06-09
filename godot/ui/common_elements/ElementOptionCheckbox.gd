@tool
extends GenericOption

@onready var value_node = $ElementCheckbox
@onready var description_node = $ElementCheckbox

func setup():
	if not label_description:
		label_description = option_name

	description_node.text = label_description.to_upper()
	value = node_owner.get(option_name)
	value_node.button_pressed = value


func _on_ElementCheckbox_toggled(button_pressed):
	value = button_pressed
	set_value(value)


func _on_MarginContainer_focus_entered():
	set_process_input(true)
	


func _on_MarginContainer_focus_exited():
	set_process_input(false)
	


func _on_focus_entered():
	get_child(0).grab_focus()


func _on_ElementCheckbox_focus_entered():
	value_node.set("theme_override_colors/font_pressed_color",Color(0,0,0))
	

func _on_ElementCheckbox_focus_exited():
	value_node.set("theme_override_colors/font_pressed_color", null)
