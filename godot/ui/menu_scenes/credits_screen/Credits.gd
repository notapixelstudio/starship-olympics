extends Control

const menu_scene = "res://ui/menu_scenes/title_screen/MainScreen.tscn"

func _ready():
	set_process_input(false)
	await get_tree().create_timer(1.0).timeout
	set_process_input(true)

func go_ahead():
	get_tree().change_scene_to_file(menu_scene)
	
func _input(event):
	if not event is InputEventJoypadMotion and not event is InputEventMouse and not event is InputEventPanGesture and not event.pressed:
		go_ahead()
		set_process_input(false)
