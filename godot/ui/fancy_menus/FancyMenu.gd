extends Control
class_name FancyMenu

export (String, 'horizontal', 'vertical', 'both', 'none') var auto_neighbours = 'none'
export var wrap := true
export var default_focused_element : NodePath
export var focus_default_element_on_ready := true

var saved_focused_element : Control

func _ready():
	if focus_default_element_on_ready and get_node_or_null(default_focused_element):
		get_node(default_focused_element).grab_focus()
	
	var children = get_children()
	
	if auto_neighbours in ['horizontal','both']:
		for i in range(len(children)):
			if not children[i].focus_neighbour_left:
				if i-1 >= 0:
					children[i].focus_neighbour_left = children[i-1].get_path()
				elif wrap:
					children[i].focus_neighbour_left = children[-1].get_path()
			if not children[i].focus_neighbour_right:
				if i+1 < len(children):
					children[i].focus_neighbour_right = children[i+1].get_path()
				elif wrap:
					children[i].focus_neighbour_right = children[0].get_path()
		
		# set no neighbour (node itself) if nothing was already set
		for i in range(len(children)):
			if not children[i].focus_neighbour_left:
				children[i].focus_neighbour_left = children[i].get_path()
			if not children[i].focus_neighbour_right:
				children[i].focus_neighbour_right = children[i].get_path()
				
	if auto_neighbours in ['vertical','both']:
		for i in range(len(children)):
			if not children[i].focus_neighbour_top:
				if i-1 >= 0:
					children[i].focus_neighbour_top = children[i-1].get_path()
				elif wrap:
					children[i].focus_neighbour_top = children[-1].get_path()
			if not children[i].focus_neighbour_bottom:
				if i+1 < len(children):
					children[i].focus_neighbour_bottom = children[i+1].get_path()
				elif wrap:
					children[i].focus_neighbour_bottom = children[0].get_path()
					
		# set no neighbour (node itself) if nothing was already set
		for i in range(len(children)):
			if not children[i].focus_neighbour_top:
				children[i].focus_neighbour_top = children[i].get_path()
			if not children[i].focus_neighbour_bottom:
				children[i].focus_neighbour_bottom = children[i].get_path()

func save_focused_element():
	saved_focused_element = get_focus_owner()
	
## restore the focused element if there is one saved, otherwise give focus to the default one (if present)
func restore_focused_element():
	if not saved_focused_element:
		if get_node_or_null(default_focused_element) != null:
			get_node(default_focused_element).grab_focus()
		return
	saved_focused_element.grab_focus()

func recursive_release_focus():
	release_focus()
	for child in get_children():
		if child.has_method('recursive_release_focus'):
			child.recursive_release_focus()
		elif child.has_method('release_focus'):
			child.release_focus()
			
