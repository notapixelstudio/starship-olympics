extends Control

class_name Screen

signal next(next_packed_scene) 
signal back

func enter():
	set_process_input(true)
	set_process_unhandled_input(true)

func exit():
	set_process_input(false)
	set_process_unhandled_input(false)
	recursive_release_focus()

func recursive_release_focus():
	release_focus()
	for child in get_children():
		if child.has_method('recursive_release_focus'):
			child.recursive_release_focus()
		elif child.has_method('release_focus'):
			child.release_focus()
			
func get_id() -> String:
	return name
