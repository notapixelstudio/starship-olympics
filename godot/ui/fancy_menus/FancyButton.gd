extends TextureButton

func _ready():
	blur()
	
func focus():
	self_modulate = Color(1.1, 1.1, 1.1)

func blur():
	self_modulate = Color(0.4, 0.4, 0.4)
	
	
func _on_FancyButton_focus_entered():
	focus()
	
func _on_FancyButton_focus_exited():
	blur()
	
