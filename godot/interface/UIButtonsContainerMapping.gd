extends Control


func _on_Toggle_toggled(button_pressed):
	for button in $Dynamic/Classic.get_children():
		button.disabled = not button.disabled
	for button in $Dynamic/Custom.get_children():
		button.disabled = not button.disabled
