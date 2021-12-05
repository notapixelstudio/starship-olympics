extends Control

func _ready():
	for button in $Dynamic/Custom.get_children():
		button.disabled = not button.disabled
		if button.disabled:
			button.focus_mode = Control.FOCUS_NONE
		else:
			button.focus_mode = Control.FOCUS_ALL

func _on_Toggle_toggled(button_pressed):
	for button in $Dynamic/Classic.get_children():
		button.disabled = not button.disabled
		if button.disabled:
			button.focus_mode = Control.FOCUS_NONE
		else:
			button.focus_mode = Control.FOCUS_ALL
	for button in $Dynamic/Custom.get_children():
		button.disabled = not button.disabled
		if button.disabled:
			button.focus_mode = Control.FOCUS_NONE
		else:
			button.focus_mode = Control.FOCUS_ALL
