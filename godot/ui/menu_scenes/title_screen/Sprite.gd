extends Sprite

export var species : Resource setget set_species

onready var trail = $Trail


func set_species(value):
	species = value
	if is_inside_tree():
		yield(self, "ready")

	texture = species.ship_off
