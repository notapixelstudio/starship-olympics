extends Control
class_name FancyMenu
## A parent [Control] for [FancyButton]s.

@export_enum('horizontal', 'vertical', 'both', 'none') var auto_neighbours := 'none'
@export var wrap := true
@export var default_focused_element : NodePath
@export var focus_default_element_on_ready := true

var _saved_focused_element : Control

func _ready():
	if focus_default_element_on_ready and get_node_or_null(default_focused_element):
		give_focus_to(get_node(default_focused_element))
	
	var children : Array[FancyButton] = get_fancy_button_children()
	
	if auto_neighbours in ['horizontal','both']:
		for i in range(len(children)):
			if not children[i].focus_neighbor_left:
				if i-1 >= 0:
					children[i].focus_neighbor_left = children[i-1].get_path()
				elif wrap:
					children[i].focus_neighbor_left = children[-1].get_path()
			if not children[i].focus_neighbor_right:
				if i+1 < len(children):
					children[i].focus_neighbor_right = children[i+1].get_path()
				elif wrap:
					children[i].focus_neighbor_right = children[0].get_path()
		
		# set no neighbour (node itself) if nothing was already set
		for i in range(len(children)):
			if not children[i].focus_neighbor_left:
				children[i].focus_neighbor_left = children[i].get_path()
			if not children[i].focus_neighbor_right:
				children[i].focus_neighbor_right = children[i].get_path()
				
	if auto_neighbours in ['vertical','both']:
		for i in range(len(children)):
			if not children[i].focus_neighbor_top:
				if i-1 >= 0:
					children[i].focus_neighbor_top = children[i-1].get_path()
				elif wrap:
					children[i].focus_neighbor_top = children[-1].get_path()
			if not children[i].focus_neighbor_bottom:
				if i+1 < len(children):
					children[i].focus_neighbor_bottom = children[i+1].get_path()
				elif wrap:
					children[i].focus_neighbor_bottom = children[0].get_path()
					
		# set no neighbour (node itself) if nothing was already set
		for i in range(len(children)):
			if not children[i].focus_neighbor_top:
				children[i].focus_neighbor_top = children[i].get_path()
			if not children[i].focus_neighbor_bottom:
				children[i].focus_neighbor_bottom = children[i].get_path()
				

## Save the currently focused element. See [method restore_focused_element] to restore it.
func save_focused_element():
	_saved_focused_element = get_viewport().gui_get_focus_owner()
	
## Restore the focused element if there is one saved, otherwise give focus to the default one (if present).
func restore_focused_element():
	if not _saved_focused_element:
		if get_node_or_null(default_focused_element) != null:
			get_node(default_focused_element).grab_focus()
		return
	_saved_focused_element.grab_focus()
	
## Isolate the given Control child, making other Controls unreachable from it.
func isolate_child(child: Control):
	if not child in get_children():
		return
		
	child.focus_neighbor_top = child.get_path()
	child.focus_neighbor_bottom = child.get_path()
	child.focus_neighbor_left = child.get_path()
	child.focus_neighbor_right = child.get_path()

## Return an Array of children FancyButtons
func get_fancy_button_children() -> Array[FancyButton]:
	var children : Array[FancyButton] = []
	for child in get_children():
		if child is FancyButton:
			children.append(child)
	return children
	
func give_focus_to(what: FancyButton) -> void:
	what.grab_focus()
