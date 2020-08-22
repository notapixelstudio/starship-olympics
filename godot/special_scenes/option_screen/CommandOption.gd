tool
extends MarginContainer

class_name CommandRemap

export var action: String
export var device: String setget _set_device

func _process(delta):
	$Container/Description.text = action
	
func _set_device(value_):
	device = value_
	if not is_inside_tree():
		yield(self, "ready")
	$Container/Button.action = device+"_"+action
