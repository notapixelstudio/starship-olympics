extends Control

func set_player(player: InfoPlayer): # InfoPlayer
	$DronesOverlay.visible = false
	if player:
		$Sprite.texture = player.get_character_image()
		$Polygon2D.modulate = player.get_color()
		$Line2D.visible = true
		if player.is_cpu():
			$Sprite.modulate = player.get_color()
			$Sprite.self_modulate = Color(1.1,1.1,1.1)
			$DronesOverlay.visible = true
	else:
		$Sprite.texture = null
		$Polygon2D.modulate = Color(1,1,1,0)
		$Line2D.visible = false
		$Sprite.modulate = Color(1,1,1)
		$Sprite.self_modulate = Color(1,1,1)
