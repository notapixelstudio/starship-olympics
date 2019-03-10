extends Node

class_name Entity

func get_host():
	""" Returns the node this entity is attached to. """
	return get_parent()
	
func has(component_name : String) -> bool:
	return could_have(component_name) and get_node(component_name).is_enabled()
	
func get(component_name : String) -> Component:
	var result : Component = get_node(component_name)
	return result
	
func could_have(component_name : String) -> bool:
	return has_node(component_name)
