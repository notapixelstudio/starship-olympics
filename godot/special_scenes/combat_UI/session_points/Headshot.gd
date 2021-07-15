extends Control
tool

export var species : Resource setget set_species

func _ready():
	species = null
	
func set_species(value: Species):
	species = value
	if not $Sprite:
		return
	if species:
		$Sprite.texture = species.character_ok
		$Polygon2D.modulate = species.color
		$Line2D.visible = true
	else:
		$Sprite.texture = null
		$Polygon2D.modulate = Color(1,1,1,0)
		$Line2D.visible = false
		
