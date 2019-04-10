extends Control

export var species : Resource setget set_species

func set_species(value):
	species = value
	$Sprite.texture = species.character_ok
	