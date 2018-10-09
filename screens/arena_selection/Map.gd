extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func focus_on_planet(planet):
	print(planet)
	get_node(planet+"/arrow_selection").visible = true

func unfocus_on_planet(planet):
	get_node(planet).get_node("arrow_selection").visible = false