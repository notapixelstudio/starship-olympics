extends ColorRect
class_name MinigameListItem

export var MinigameMinilogoScene : PackedScene

var minigame: Minigame

func set_minigame(v: Minigame) -> void:
	minigame = v
	$HBoxContainer/LogoContainer/Logo.texture = minigame.get_icon()
	$HBoxContainer/Texts/Title.text = minigame.get_name()
	$HBoxContainer/Texts/Description.text = minigame.get_description()
	
	for successor in minigame.unlocks:
		var minilogo = MinigameMinilogoScene.instance()
		minilogo.set_minigame(successor)
		$HBoxContainer/Unlocks/List.add_child(minilogo)
