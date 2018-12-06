extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal show_planet(planet)
signal unshow_planet(planet)
signal show_arenas(planet)

onready var container = get_node("container")

func _ready():
	for button in container.get_children():
		button.connect("focus_planet", self, "_on_focus_planet")
		button.connect("exit_focus_planet", self, "_on_exit_focus_planet")
		button.connect("select_planet", self, "_on_planet_selected")
	yield(get_tree().create_timer(0.2),"timeout")
	container.get_child(0).grab_focus()

func show_arenas(planet):
	container.get_node(planet).show_arenas()
	
func _on_focus_planet(planet):
	emit_signal("show_planet", planet)

func _on_exit_focus_planet(planet):
	emit_signal("unshow_planet", planet)

func _on_planet_selected(planet):
	emit_signal("show_arenas", planet)
