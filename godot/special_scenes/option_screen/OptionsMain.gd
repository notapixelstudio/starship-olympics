extends VBoxContainer

signal nav_to

func _ready():
	for button in get_children():
		if button is NavigatorButton:
			button.connect("nav_to", self, "_on_nav_pressed")


func _on_nav_pressed(title, nav_menu):
	emit_signal("nav_to", title, nav_menu.instance())
