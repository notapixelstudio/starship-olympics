extends Node

func E(node : Node) -> Entity:
	"""
	  Finds the nearest ancestor for the given node having an Entity subnode and returns it (if there are
	  more than one, the first is returned). Returns null if no such node is found.
	"""
	if not node:
		return null
		
	if node == get_tree().root:
		return null
		
	for child in node.get_children():
		if child is Entity:
			return child
		
	return E(node.get_parent())
	