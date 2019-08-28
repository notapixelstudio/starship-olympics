extends GenericOption

onready var value_node = $ElementCheckbox
onready var description_node = $ElementCheckbox

func _ready():
	if not label_description:
		label_description = variable_name

	description_node.text = label_description.to_upper()
	
func _initialize():
	value_node.pressed = value


func _on_ElementCheckbox_toggled(button_pressed):
	value = button_pressed
	node_owner.set(variable_name, value)
