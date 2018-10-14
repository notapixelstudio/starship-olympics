extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var navigator = get_node("Navigator")

func _ready():
	navigator.connect("show_arenas", self, "_on_Navigator_show_arenas")

func _on_Navigator_show_arenas(planet):
	$Camera2D.current = not $Camera2D.current
	navigator.show_arenas(planet)