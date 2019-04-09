extends Control

class_name SpeciesContainer

onready var character = $Character

func set_species(texture : Texture):
	character.texture = texture
