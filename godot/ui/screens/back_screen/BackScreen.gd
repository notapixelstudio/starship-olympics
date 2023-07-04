extends Screen
class_name BackScreen

func _on_Back_button_down():
	emit_signal("back")
	
func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		emit_signal("back")

func exit():
	.exit()
	$FancyMenu.save_focused_element()
	
func enter():
	.enter()
	$FancyMenu.restore_focused_element()
