extends Control

export var main_screen : PackedScene

func go_ahead():
	get_tree().change_scene_to(main_screen)
	
func _ready():
	$Language.grab_focus()
	
	
func _input(event):
	if event.is_action("ui_accept"):
		go_ahead()
		set_process_input(false)
