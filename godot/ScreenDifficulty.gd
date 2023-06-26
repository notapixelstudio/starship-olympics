extends ScreenScene

class_name Difficulty

func _on_Easy_pressed():
	emit_signal("next", next_scene)
