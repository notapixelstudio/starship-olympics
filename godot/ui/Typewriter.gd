extends Label

export var duration := 0.06

signal done

func type(text_to_type : String):
	visible_characters = 0
	text = text_to_type
	for i in range(len(text_to_type)):
		visible_characters += 1
		yield(get_tree().create_timer(duration), "timeout")
		
	emit_signal('done')
