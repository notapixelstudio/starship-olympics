extends ScreenScene
class_name BackScreen

func _on_Back_button_down():
	emit_signal("back")

func exit():
	$FancyMenu.save_focused_element()
	
func enter():
	$FancyMenu.restore_focused_element()
