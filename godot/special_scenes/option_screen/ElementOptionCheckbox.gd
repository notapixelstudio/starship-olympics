extends GenericOption

onready var value_node = $ElementCheckbox

func _initialize():
	value_node.pressed = value

func _ready():
	_initialize()

func _on_ElementCheckbox_toggled(button_pressed):
	value = button_pressed
	node_owner.set(description, value)
