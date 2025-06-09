extends Screen

var _progress := 0.0

func _on_timer_timeout() -> void:
	_progress += 4.0
	%Bar.set_value(_progress)


func _on_press_any_key_any_key_pressed() -> void:
	Events.loading_screen_done.emit()
