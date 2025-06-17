extends FancyMenu

@export_enum("none", "ui", "kb1", "kb2", "joy1", "joy2", "joy3", "joy4") var controls := "none" : set = set_controls
@export var tint := Color(1,1,1,1) : set = set_tint

var current_focused_element : Control

func set_tint(value: Color) -> void:
	tint = value
	
	# a bit heavy handed
	for child in get_children():
		child.self_modulate = tint

func _process(delta):
	if controls == 'none':
		return
		
	if Input.is_action_just_pressed(controls+"_down"):# and Input.get_action_strength(controls+"_down") > 0.5:
		give_focus_to(get_node(current_focused_element.focus_neighbor_bottom))
	elif Input.is_action_just_pressed(controls+"_up"):# and Input.get_action_strength(controls+"_up") > 0.5:
		give_focus_to(get_node(current_focused_element.focus_neighbor_top))

func give_focus_to(what : Control) -> void:
	if current_focused_element:
		current_focused_element.blur()
	current_focused_element = what
	current_focused_element.focus()

func set_controls(v: String) -> void:
	controls = v
