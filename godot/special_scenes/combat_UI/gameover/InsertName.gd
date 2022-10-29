extends LineEdit

signal name_inserted

func _ready():
	set_process_input(false)
	
func _input(event):
	if event.is_action_pressed("confirm"):
		if(self.text.strip_edges() == ""):
			self.text = self.placeholder_text
		emit_signal("name_inserted", str(self.text).to_upper())
