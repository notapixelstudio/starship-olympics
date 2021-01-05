extends Node

# retrieve all Traits with a given name
func get_all(trait_name):
	var nodes = get_tree().get_nodes_in_group('Trait_'+trait_name)
	if OS.is_debug_build():
		for node in nodes:
			node.validate()
	return nodes
	
# retrieve all objects having the specified Trait
func get_all_with(trait_name):
	var nodes = get_all(trait_name)
	var objects = []
	for n in nodes:
		objects.append(n.host)
	return objects

# check if the given node has a Trait with the given name
func has_trait(node, trait_name):
	if OS.is_debug_build() and node.has_node(trait_name):
		node.get_node(trait_name).validate()
	return node.has_node(trait_name)

# retrieve the Trait with the specified name from the given node
func get_trait(node, trait_name):
	if OS.is_debug_build():
		assert(has_trait(node, trait_name))
	return node.get_node(trait_name)
