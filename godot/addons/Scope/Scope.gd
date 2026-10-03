class_name Scope extends Node

## Finds the nearest ancestor of node having a scope with the given node name (default: 'Scope').
static func get_scope(node: Node, scope_name := 'Scope') -> Scope:
	var current: Node = node
	while current:
		if current.has_node(scope_name):
			return current.get_node(scope_name)
		current = current.get_parent()
		
	assert(false, 'No "%s" scope found for node %s' % [scope_name, node.name])
	return null
