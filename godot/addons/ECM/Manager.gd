extends Node

class_name Manager

@export var enabled : bool = true :
	get:
		return enabled # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of _set_enabled

func _set_enabled(value):
	enabled = value
	if not is_inside_tree():
		await self.ready
	set_process(enabled)
	
func get_host():
	return get_world_3d()
	
func get_world_3d():
	return get_parent()
	
