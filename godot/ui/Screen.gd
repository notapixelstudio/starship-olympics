extends Control

signal next(next_packed_scene) 
signal back

class_name Screen

func enter():
	set_process_input(true)

func exit():
	set_process_input(false)
	recursive_release_focus()

func recursive_release_focus():
	release_focus()
	for child in get_children():
		if child.has_method('recursive_release_focus'):
			child.recursive_release_focus()
		elif child.has_method('release_focus'):
			child.release_focus()
			
