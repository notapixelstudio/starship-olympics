extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func focus_on_planet(planet):
	get_node(planet).show_planet()

func unfocus_on_planet(planet):
	get_node(planet).unshow_planet()
	
func show_arenas(planet):
	if get_node(planet).selected:
		get_node(planet).hide_arenas()
	else:
		get_node(planet).show_arenas()