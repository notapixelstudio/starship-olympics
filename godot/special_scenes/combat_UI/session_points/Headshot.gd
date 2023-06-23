extends Control

func set_player(player: InfoPlayer): # InfoPlayer
	if player:
		$Sprite.texture = player.get_character_image()
		$Polygon2D.modulate = player.get_color()
		$Line2D.visible = true
	else:
		$Sprite.texture = null
		$Polygon2D.modulate = Color(1,1,1,0)
		$Line2D.visible = false
		
