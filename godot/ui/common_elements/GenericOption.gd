extends Control

class_name GenericOption

enum OPTION_TYPE{ON_OFF, NUMBER, ARRAY}

signal value_changed(value)

### Properties ###
@export var element_path : String
# Text of the label that is going to appear on the Option
@export var label_description: String

@export var node_owner_path := "global"

var value : set = _set_value
var node_owner

func _ready():
	node_owner = get_tree().get_root().get_node(node_owner_path)
	set_process_input(false)

func _set_value(new_value):
	value = new_value
	if node_owner:
		node_owner.set(element_path, value)
		emit_signal("value_changed", value)
	else:
		print_debug("Setter has been called without a proper setup")
		
