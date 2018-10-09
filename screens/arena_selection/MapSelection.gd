extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var map = get_node("Map/Map")
onready var navigator = get_node("Navigator/Navigator")

func _ready():
	navigator.connect("show_planet", self, "_on_Navigator_show_planet")
	navigator.connect("unshow_planet", self, "_on_Navigator_unshow_planet")

func _on_Navigator_show_planet(planet):
	map.focus_on_planet(planet)

func _on_Navigator_unshow_planet(planet):
	map.unfocus_on_planet(planet)
