extends Control

export (String, 'horizontal', 'vertical', 'both', 'none') var auto_neighbours = 'none'
export var wrap := true

var saved_focused_element : Control

func _ready():
	var children = get_children()
	children[0].grab_focus()
	
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
	
func restore_focused_element():
	if not saved_focused_element:
		return
	saved_focused_element.grab_focus()
