extends Label
class_name Typewriter

signal done

func type(text_to_type : String):
	visible_characters = 0
	text = text_to_type
	$Tween.interpolate_property(self, "visible_characters", 0, len(text_to_type), 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN, 1.0)
	
	$Tween.start()
	yield($Tween, "tween_all_completed")
	emit_signal('done')

func done():
	$Tween.stop_all()
	$Tween.remove_all()
	visible_characters = -1
	emit_signal('done')

func _input(event):
	if event.is_action_pressed("ui_accept"):
		set_process_input(false)
		self.done()
