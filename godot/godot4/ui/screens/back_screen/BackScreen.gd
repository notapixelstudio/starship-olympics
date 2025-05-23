extends Screen
class_name BackScreen

func _on_Back_button_down():
	emit_signal("back")
	
func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		emit_signal("back")

func exiting():
	$FancyMenu.save_focused_element()
	super.exiting()
	
func enter():
	super.enter()
	$FancyMenu.restore_focused_element()
