tool

extends MapCell

class_name MapPlanet

export var planet : Resource setget set_planet
onready var sprite = $Sprite

export var active : bool = false setget set_active

var not_available = false setget set_availability

func set_availability(value):
	not_available = value
	if sprite:
		$NA.visible = not_available
		
func set_planet(value):
	planet = value
	refresh()
	
func set_active(value):
	active = value
	refresh()
	
func toggle_active():
	set_active(not active)
	
func act(cursor):
	toggle_active()
	.act(cursor)
	
func _ready():
	refresh()
	
func refresh():
	if is_inside_tree():
		sprite.texture = planet.planet_active_sprite if active else planet.planet_sprite
		