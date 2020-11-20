tool
extends MarginContainer

class_name CommandRemap

signal remapped
signal try_remap

export var action: String
export var device: String setget _set_device

func _process(delta):
	$Container/Description.text = action
	
func _set_device(value_):
	device = value_
	if not is_inside_tree():
		yield(self, "ready")
	$Container/Button.action = device+"_"+action


func _on_Button_remapped(action: String, new_control: String):
	emit_signal("remapped", action, new_control)


func _on_Button_try_remap(action):
	emit_signal("try_remap", action)
