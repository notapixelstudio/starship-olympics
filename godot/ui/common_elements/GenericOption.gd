extends Control

class_name GenericOption

enum OPTION_TYPE{ON_OFF, NUMBER, ARRAY}

var value

### Properties ###
@export var option_name : String
### Text of the label that is going to appear on the Option ###
@export var label_description: String
@export var node_owner_path := "Options"

var node_owner

func _ready():
	node_owner = get_tree().get_root().get_node(node_owner_path)
	set_process_input(false)
	setup()

func setup():
	pass
	
func set_value(v):
	value = v
	if node_owner:
		Events.option_changed.emit(option_name, value)
	else:
		print_debug("Setter has been called without a proper setup")
		
