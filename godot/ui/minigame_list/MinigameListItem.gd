extends HBoxContainer
class_name MinigameListItem

var minigame: Minigame

func set_minigame(v: Minigame) -> void:
	minigame = v
	$LogoContainer/Logo.texture = minigame.get_icon()
	$Texts/Title.text = minigame.get_name()
	$Texts/Description.text = minigame.get_description()
