extends Control

class_name UIOptionPanel

@onready var content = $Content
# N.B.: "find_node" is not really efficient but we need to be generic 
@onready var container = find_child("UIButtonsContainer", true)

func _ready():
	add_to_group("UIOptionPanel")
	assert(content)
	assert(container)
	for button in get_tree().get_nodes_in_group("UI_Navigator"):
		assert (button is NavigatorButton)
		button.connect("request_nav_to", Callable(self, "_on_nav_pressed"))
	
func _on_nav_pressed(title: String, nav_menu: PackedScene, extra_args: Dictionary = {}):
	Events.emit_signal("ui_nav_to", title, nav_menu.instantiate(), extra_args)

func get_focus():
	container.get_child(0).grab_focus()

func _on_Language_value_changed(value):
	print(TranslationServer.get_locale())
	Events.emit_signal("language_changed")
