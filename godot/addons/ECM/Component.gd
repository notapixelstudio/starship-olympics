extends Node

class_name Component

export var enabled : bool = true

func _enter_tree():
	if enabled:
		_add_to_corresponding_group()
		
func _exit_tree():
	_remove_from_corresponding_group()
	
func _add_to_corresponding_group():
	get_entity().add_to_group('component__'+name)
	
func _remove_from_corresponding_group():
	if get_entity().is_in_group('component__'+name):
		get_entity().remove_from_group('component__'+name)
		
signal enabled
signal disabled
func set_enabled(value : bool):
	var old_enabled = enabled
	
	enabled = value
	
	if enabled:
		_add_to_corresponding_group()
	else:
		_remove_from_corresponding_group()
		
	if old_enabled == false and enabled == true:
		emit_signal('enabled')
	elif old_enabled == true and enabled == false:
		emit_signal('disabled')

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
	
