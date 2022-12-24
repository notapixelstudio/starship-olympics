extends ColorRect
class_name CollectionItem

export var MinigameMinilogoScene : PackedScene

var card: DraftCard

func set_card(v: DraftCard, pool: CardPool) -> void:
	card = v
	$HBoxContainer/LogoContainer/Logo.texture = card.get_icon()
	$HBoxContainer/Texts/HBoxContainer/Title.text = card.get_name()
	$HBoxContainer/Texts/Description.text = card.get_description()
	
	var text = ''
	var possible_player_counts := [1,2,3,4]
	var actual_player_counts := card.get_available_player_counts(possible_player_counts)
	print(actual_player_counts)
	for player_count in possible_player_counts:
		if actual_player_counts.has(player_count):
			text += str(player_count)
		else:
			text += '[color=#555555]'+str(player_count)+'[/color]'
	
	$HBoxContainer/Texts/HBoxContainer/PlayerCount.bbcode_text = '[center]'+text+'[/center]'
	
	$HBoxContainer/Texts/HBoxContainer/Wrapper/Winter.visible = not card is MysteryCard and card.is_winter()
	if not card is MysteryCard and card.is_winter():
		$HBoxContainer/LogoContainer/Logo.modulate = Color(0.7,1,1.3,1)
	
	if card is MysteryCard:
		$HBoxContainer/Texts/HBoxContainer/Title.modulate = Color(0.7,0.3,0.7,1)
		$HBoxContainer/LogoContainer/Logo.scale = Vector2(0.6,0.6)
