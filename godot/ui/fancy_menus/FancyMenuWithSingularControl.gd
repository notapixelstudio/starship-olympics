extends FancyMenu

@export_enum("none", "ui", "kb1", "kb2", "joy1", "joy2", "joy3", "joy4") var controls := "none" : set = set_controls

var current_focused_element : Control

func _input(event):
	if controls == 'none':
		return
		
	if event.get_action_strength(controls+"_down") > 0.5:
		give_focus_to(get_node(current_focused_element.focus_neighbor_bottom))
	elif event.get_action_strength(controls+"_up") > 0.5:
		give_focus_to(get_node(current_focused_element.focus_neighbor_top))

func give_focus_to(what : Control) -> void:
	if current_focused_element:
		current_focused_element.blur()
	current_focused_element = what
	current_focused_element.focus()

func set_controls(v: String) -> void:
	controls = v
