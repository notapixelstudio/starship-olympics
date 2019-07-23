extends Control

class_name GenericOption

enum OPTION_TYPE{ON_OFF, NUMBER, ARRAY}

signal value_changed

export (String) var description = "Life"
export (String) var optional_path 
export (String) var label_description
export (OPTION_TYPE) var elem_type = OPTION_TYPE.ON_OFF
export (bool) var is_global = false
export (NodePath) var node_owner_path
export (NodePath) var description_node_path

var node_owner
var value setget _set_value 
var min_value
var max_value
var array_value

func _set_value(new_value):
	value = new_value
	emit_signal("value_changed", value)
	if node_owner:
		node_owner.set(description, value)
	else:
		print_debug("Setter has been called without a proper setup")
		
func _initialize():
	# description_node.text = description
	# value_node.text = str(value)
	# set node and animations if needed
	pass

var description_node

func _ready():
	if not label_description:
		label_description = description

	description_node = get_node(description_node_path)
	description_node.text = label_description.to_upper()
	
	if is_global:
		node_owner = global
	else:
		node_owner = get_node(node_owner_path)
		
	value = node_owner.get(description)
	
	if elem_type == OPTION_TYPE.NUMBER:
		min_value = node_owner.get("min_"+description)
		max_value = node_owner.get("max_"+description)
	
	set_process_input(false)
	
	
func nested_get(ancestor: Node, path:String, separator:String = "."):
	"""
	:param Node ancestor: Ancestor node that has the nested references
	:param str path: String separated by 'separator' that indicates the path
	:param str separator: separator for the 
	:return value from path, NULL if does not exists
	"""
	var nests = path.split(separator)
	var object = ancestor
	var parent
	for property in nests:
		object = object.get(property)
		if object is Node:
			parent = object
	return object