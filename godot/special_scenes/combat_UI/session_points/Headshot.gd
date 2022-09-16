extends Control
@tool

@export var species : Resource :
	get:
		return species # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_species

func _ready():
	species = null
	
func set_species(value: Species):
	species = value
	if not $Sprite2D:
		return
	if species:
		$Sprite2D.texture = species.character_ok
		$Polygon2D.modulate = species.color
		$Line2D.visible = true
	else:
		$Sprite2D.texture = null
		$Polygon2D.modulate = Color(1,1,1,0)
		$Line2D.visible = false
		
