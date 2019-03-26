extends Node

class_name Manager

func get_host():
	return get_world()
	
func get_world():
	return get_parent()
	