extends Control

class_name UIOptionPanel

export (String, "normal", "large") var panel_type = "normal"
onready var content = $Content
onready var back_button = $Back

func _ready():
	add_to_group("UIOptionPanel")
	assert(content)
	assert(back_button)
	for button in get_tree().get_nodes_in_group("UI_Navigator"):
		assert (button is NavigatorButton)
		button.connect("request_nav_to", self, "_on_nav_pressed")
	content.grab_focus()
	
func _on_nav_pressed(title: String, nav_menu: PackedScene):
	Events.emit_signal("ui_nav_to", title, nav_menu.instance())
	
func _on_Back_pressed():
	Events.emit_signal("ui_back_menu")
