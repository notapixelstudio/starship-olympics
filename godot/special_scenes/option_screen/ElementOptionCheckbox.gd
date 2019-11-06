extends GenericOption

onready var value_node = $ElementCheckbox
onready var description_node = $ElementCheckbox

func _process(delta):
	description_node.text = label_description.to_upper()
func _ready():
	if not label_description:
		label_description = variable_name

	description_node.text = label_description.to_upper()
	value = node_owner.get(variable_name)
	print("value checkbox "+str(value))
	_initialize()
	
func _initialize():
	value_node.pressed = value


func _on_ElementCheckbox_toggled(button_pressed):
	value = button_pressed
	node_owner.set(variable_name, value)


func _on_MarginContainer_focus_entered():
	set_process_input(true)


func _on_MarginContainer_focus_exited():
	set_process_input(false)
