extends VBoxContainer

func _ready():
	for button in get_children():
		if button is NavigatorButton:
			button.connect("request_nav_to", self, "_on_nav_pressed")


func _on_nav_pressed(title: String, nav_menu: PackedScene):
	Events.emit_signal("nav_to", title, nav_menu.instance())
