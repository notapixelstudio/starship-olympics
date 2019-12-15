extends Node

class_name Manager

export var enabled : bool = true setget _set_enabled

func _set_enabled(value):
	enabled = value
	if not is_inside_tree():
		yield(self, "ready")
	set_process(enabled)
	
func get_host():
	return get_world()
	
func get_world():
	return get_parent()
	