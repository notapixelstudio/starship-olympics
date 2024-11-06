extends Node

class_name Manager

@export var enabled : bool = true: set = _set_enabled

func _set_enabled(value):
	enabled = value
	if not is_inside_tree():
		await self.ready
	set_process(enabled)
	
func get_host():
	return get_world_3d()
	
func get_world_3d():
	return get_parent()
	
