extends GenericOption

onready var value_node = $ElementCheckbox
func _initialize():
	print("THe value of this button is ", value_node.pressed)
	value_node.pressed = value

func _ready():
	_initialize()

func _on_ElementCheckbox_toggled(button_pressed):
	value = button_pressed
