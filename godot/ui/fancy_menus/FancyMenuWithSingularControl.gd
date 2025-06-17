extends FancyMenu

@export_enum("none", "ui", "kb1", "kb2", "joy1", "joy2", "joy3", "joy4") var controls := "none" : set = set_controls
@export var tint := Color(1,1,1,1) : set = set_tint

var current_focused_element : Control

func set_tint(value: Color) -> void:
	tint = value
	
	# a bit heavy handed
	for child in get_fancy_button_children():
		child.self_modulate = tint

var ignore := true
func _process(delta):
	if controls == 'none':
		return
		
	if not ignore and Utils.is_action_strong(controls+"_down"):
		ignore = true
		give_focus_to(get_node(current_focused_element.focus_neighbor_bottom))
	elif not ignore and Utils.is_action_strong(controls+"_up"):
		ignore = true
		give_focus_to(get_node(current_focused_element.focus_neighbor_top))
	elif Utils.are_controls_at_rest(controls):
		ignore = false
		
func give_focus_to(what : Control) -> void:
	if current_focused_element:
		current_focused_element.blur()
	current_focused_element = what
	current_focused_element.focus()

func set_controls(v: String) -> void:
	controls = v
