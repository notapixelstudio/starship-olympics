extends ColorRect
class_name MinigameListItem

export var MinigameMinilogoScene : PackedScene

var minigame: Minigame

func set_minigame(v: Minigame, pool: CardPool) -> void:
	minigame = v
	$HBoxContainer/LogoContainer/Logo.texture = minigame.get_icon()
	$HBoxContainer/Texts/Title.text = minigame.get_name()
	$HBoxContainer/Texts/Description.text = minigame.get_description()
	$HBoxContainer/Unlocks/Id.text = minigame.get_id()
	
	for successor_id in minigame.unlocks:
		var successor = pool.get_card(successor_id)
		var minilogo = MinigameMinilogoScene.instance()
		minilogo.set_minigame(successor)
		$HBoxContainer/Unlocks/List.add_child(minilogo)
