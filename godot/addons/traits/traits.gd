extends Node

# retrieve all Traits with a given name
func get_all(trait_name):
	var nodes = get_tree().get_nodes_in_group('Trait_'+trait_name)
	if OS.is_debug_build():
		for node in nodes:
			node.validate()
	return nodes

# check if the given node has a Trait with the given name
func has_trait(node, trait_name):
	if OS.is_debug_build():
		return node.has_node(trait_name) and node.get_node(trait_name).validate()
	return node.has_node(trait_name)

func get_trait(node, trait_name):
	return node.get_node(trait_name)
