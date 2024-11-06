extends Control

func set_player(player: Player):
	$DronesOverlay.visible = false
	if player:
		$Sprite2D.texture = player.get_character_image()
		$Polygon2D.modulate = player.get_color()
		$Line2D.visible = true
		if player.is_cpu():
			$Sprite2D.modulate = player.get_color()
			$Sprite2D.self_modulate = Color(1.1,1.1,1.1)
			$DronesOverlay.visible = true
	else:
		$Sprite2D.texture = null
		$Polygon2D.modulate = Color(1,1,1,0)
		$Line2D.visible = false
		$Sprite2D.modulate = Color(1,1,1)
		$Sprite2D.self_modulate = Color(1,1,1)
