extends Control
tool

export var species : Resource setget set_species

func _ready():
	species = null
	
func set_species(value: SpeciesTemplate):
	species = value
	if not $Sprite:
		return
	if species:
		$Sprite.texture = species.character_ok
	else:
		$Sprite.texture = null
