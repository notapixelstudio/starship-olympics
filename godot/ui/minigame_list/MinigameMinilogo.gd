extends Control
class_name MinigameMinilogo

var minigame: Minigame

func set_minigame(v: Minigame) -> void:
	minigame = v
	$Minilogo.texture = minigame.get_icon()
	
