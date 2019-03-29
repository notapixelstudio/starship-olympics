extends Control

var array_planets : Array
var current_planet : String


const PLANETS_PATH = "res://map/planets/"
signal done
var back = false
var can_choose = false
func _ready():
	array_planets = global.dir_contents(PLANETS_PATH, '', '.tres')
	current_planet = array_planets[0]
	# let's wait a bit to avoid the immediate selection of the arena
	yield(get_tree().create_timer(1.0), "timeout")
	can_choose = true
	$panel/Element.grab_focus()
	_on_Element_value_changed(current_planet)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if can_choose:
			emit_signal("done")
	elif event.is_action_pressed("ui_cancel"):
		back = true
		emit_signal("done")
		
func _exit_tree():
	get_tree().paused = false

func _on_Element_value_changed(value):
	var c : Planet = load(PLANETS_PATH + value)
	$panel/Sprite.texture = c.planet_sprite
	$panel/Name.text = c.name
	$panel/Tagline1.text = c.tagline1
	$panel/Tagline2.text = c.tagline2
	