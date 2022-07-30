extends ColorRect
class_name MinigameListItem

export var MinigameMinilogoScene : PackedScene

var minigame: Minigame

func set_minigame(v: Minigame, pool: CardPool) -> void:
	minigame = v
	$HBoxContainer/LogoContainer/Logo.texture = minigame.get_icon()
	$HBoxContainer/Texts/HBoxContainer/Title.text = minigame.get_name()
	$HBoxContainer/Texts/Description.text = minigame.get_description()
	$HBoxContainer/Unlocks/Id.text = minigame.get_id()
	
	for successor_id in minigame.unlocks:
		var successor = pool.get_card(successor_id)
		var minilogo = MinigameMinilogoScene.instance()
		minilogo.set_minigame(successor)
		$HBoxContainer/Unlocks/List.add_child(minilogo)
	
	var player_counts = ''
	if minigame.level_1players:
		player_counts += '1'
	else:
		player_counts += '[color=#555555]1[/color]'
	if minigame.level_2players:
		player_counts += '2'
	else:
		player_counts += '[color=#555555]2[/color]'
	if minigame.level_3players:
		player_counts += '3'
	else:
		player_counts += '[color=#555555]3[/color]'
	if minigame.level_4players:
		player_counts += '4'
	else:
		player_counts += '[color=#555555]4[/color]'
		
	$HBoxContainer/Texts/HBoxContainer/PlayerCount.bbcode_text = '[center]'+player_counts+'[/center]'
	
