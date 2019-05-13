tool

extends MapPoint

class_name MapPlanet

export var planet : Resource setget set_planet
onready var info_planet = $InfoPlanet
onready var sprite = $Sprite

var not_available = false setget set_availability
	
func set_availability(value):
	not_available = value
	if sprite:
		$NA.visible = not_available
		
func set_planet(value):
	planet = value
	refresh()
	
func _ready():
	refresh()
	
func refresh():
	if sprite:
		info_planet.set_planet(planet)
		sprite.texture = planet.planet_sprite
		