extends Control

export (String, 'horizontal', 'vertical', 'both', 'none') var auto_neighbours = 'none'
export var wrap := true

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
