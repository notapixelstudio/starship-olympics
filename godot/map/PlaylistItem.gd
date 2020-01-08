tool

extends Control

export var species : Resource setget set_species
export var planet : Resource setget set_planet

onready var ship = $Ship
func set_species(value):
	species = value
	refresh()
	
func set_planet(value):
	planet = value
	refresh()
	
func _ready():
	refresh()
	
func refresh():
	if ship:
		ship.texture = (species as SpeciesTemplate).ship
		$PlanetName.text = (planet as Planet).name
		$IconMode.texture = (planet as Planet).game_mode.icon
		
