extends ColorRect

var species setget set_species
onready var sprite = $Sprite
onready var desc = $Label

var planet setget set_planet
var rest_text = "choose a planet"
var chosen = false setget set_chosen
onready var rectangle = $character_selection_rect

func set_chosen(chosen_):
	if not is_inside_tree():
		yield(self, "ready")
	chosen = chosen_
	if chosen:
		rectangle.modulate = species.color
	else:
		rectangle.modulate = Color(1,1,1)
	
	
func set_species(species_):
	
	if not is_inside_tree():
		yield(self, "ready")
	if species_:
		species = species_
		sprite.texture = species.ship_off
		desc.text = rest_text
	
func set_planet(planet_):
	if not is_inside_tree():
		yield(self, "ready")
	if planet_:
		planet = planet_
		desc.text = planet.name
	else:
		desc.text = rest_text
