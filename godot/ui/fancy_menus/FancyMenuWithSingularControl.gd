extends FancyMenu

@export_enum("any", "kb1", "kb2", "joy1", "joy2", "joy3", "joy4") var controls:= "any"

var current_focused_element : Control


func _input(event):
	if not current_focused_element:
		current_focused_element = get_child(0)
		return
	if event.is_action_pressed(controls+"_down"):
		if current_focused_element:
			current_focused_element.blur()
			current_focused_element = get_node(current_focused_element.focus_neighbor_bottom)
		current_focused_element.focus()
	elif event.is_action_pressed(controls+"_up"):
		if current_focused_element:
			current_focused_element.blur()
			current_focused_element = get_node(current_focused_element.focus_neighbor_top)
		current_focused_element.focus()
