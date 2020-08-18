extends ColorRect

var species
onready var sprite = $Sprite

func initialize(species_):
	if not is_inside_tree():
		yield(self, "ready")
	if species_:
		species = species_
		sprite.texture = species.ship_off
	
