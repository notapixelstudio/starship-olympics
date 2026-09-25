extends LineEdit

signal name_inserted

func _ready():
	set_process_input(false)
	
func _input(event):
	if is_processing_input() and is_visible_in_tree() and event.is_action_pressed("confirm"):
		set_process_input(false)
		get_viewport().set_input_as_handled()
		if(self.text.strip_edges() == ""):
			self.text = self.placeholder_text
		emit_signal("name_inserted", str(self.text).to_upper())
