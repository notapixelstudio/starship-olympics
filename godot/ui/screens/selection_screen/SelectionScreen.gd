extends BackScreen

func _on_SelectionScreen_fight():
		emit_signal("next", next_scene)
