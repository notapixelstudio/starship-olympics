@tool

extends Control

@export var species : Resource: set = set_species
@export var planet : Resource: set = set_planet

@onready var ship = $Ship
func set_species(value):
	species = value
	if not is_inside_tree():
		await self.ready
	ship.texture = species.ship
	
func set_planet(value):
	planet = value
	if not is_inside_tree():
		await self.ready
	
	$PlanetName.text = (planet as Planet).name
	$IconMode.texture = (planet as Planet).game_mode.icon
	

