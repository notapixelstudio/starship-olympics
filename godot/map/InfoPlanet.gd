extends Node2D

func set_planet(planet:Planet):
	$Label.text = planet.name
	$Gamemode.texture = planet.game_mode.icon