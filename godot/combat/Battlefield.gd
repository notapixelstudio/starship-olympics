extends Node

var groups: Array
@onready var default_container = $Middleground

func _ready():
	for container in get_children():
		groups.append(container.name)

#func add_child(node: Node, legible_unique_name=false):
#	var container = _get_container(node)
#	if not node in container.get_children():
#		container.call_deferred("add_child", node)

func remove_child(node):
	var container = _get_container(node)
	container.remove_child(node)
	

func _get_container(node):
	for group in groups:
		if node.is_in_group(group):
			return get_node(group)
	return default_container
