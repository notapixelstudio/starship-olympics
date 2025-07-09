extends Node2D

func set_species(species: Species):
	if species:
		$Sprite2D.texture = species.get_character_image()
		$Polygon2D.modulate = species.get_color()
		$Line2D.visible = true
		%Left.modulate = species.get_color()
		%Right.modulate = species.get_color()
	else:
		$Sprite2D.texture = null
		$Polygon2D.modulate = Color(1,1,1,0)
		$Line2D.visible = false
		$Sprite2D.modulate = Color(1,1,1)
		$Sprite2D.self_modulate = Color(1,1,1)

func set_selected(value: bool):
	%Left.visible = not value
	%Right.visible = not value
	
