tool

extends Control

export var species : Resource setget set_species
export var planet : Resource setget set_planet

onready var ship = $Ship
func set_species(value):
	species = value
	if not is_inside_tree():
		yield(self, "ready")
	ship.texture = species.ship
	
func set_planet(value):
	planet = value
	if not is_inside_tree():
		yield(self, "ready")
	
	$PlanetName.text = (planet as Planet).name
	$IconMode.texture = (planet as Planet).game_mode.icon
	

