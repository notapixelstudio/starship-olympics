extends Node

class_name Component

var enabled : bool = true

func set_enabled(value : bool):
	enabled = value

func enable():
	set_enabled(true)
	
func disable():
	set_enabled(false)
	
func toggle_enabled():
	set_enabled(not enabled)
	
func is_enabled() -> bool:
	return enabled
	
func get_entity():
	return get_parent()
	
func get_host():
	return get_entity().get_host()
	