extends VBoxContainer

func _ready():
	disable()

func disable():
	for button in get_children():
		if button is Button:
			button.disabled = true

func enable():
	for button in get_children():
		if button is Button:
			button.disabled = false
	get_child(0).grab_focus()
