extends ColorRect
class_name DeckListItem

export var CardScene : PackedScene
export var card_texture : Texture

var deck: StartingDeck

const CARD_SIZE := Vector2(96, 96)

func set_deck(v: StartingDeck, unlocked: bool) -> void:
	deck = v
	$VBoxContainer/Title.text = deck.get_name()
	if not unlocked:
		$VBoxContainer/Title.modulate = Color(0.5,0.5,0.5)
		
	for card in deck.cards:
		var container = Container.new()
		container.rect_min_size = CARD_SIZE
		$VBoxContainer/HBoxContainer.add_child(container)
		
		var card_node = CardScene.instance()
		card_node.scale = Vector2(0.25,0.25)
		card_node.position = CARD_SIZE/2
		card_node.set_content_card(card)
		container.add_child(card_node)
		card_node.instant_reveal = true
		card_node.reveal()
		
#		var card_sprite = Sprite.new()
#		card_sprite.texture = card_texture
#		card_sprite.scale = Vector2(0.5,0.5)
#		card_sprite.position = CARD_SIZE/2
#		container.add_child(card_sprite)
#
#		var sprite = Sprite.new()
#		sprite.texture = card.get_icon()
#		sprite.scale = Vector2(0.2,0.2)
#		sprite.position = CARD_SIZE/2
#		container.add_child(sprite)
		
#	$HBoxContainer/LogoContainer/Logo.texture = card.get_icon()
#	$HBoxContainer/Texts/HBoxContainer/Title.text = card.get_name()
#	$HBoxContainer/Texts/Description.text = card.get_description()
#
#	var text = ''
#	var possible_player_counts := [1,2,3,4]
#	var actual_player_counts := card.get_available_player_counts()
#	print(actual_player_counts)
#	for player_count in possible_player_counts:
#		if actual_player_counts.has(player_count):
#			text += str(player_count)
#		else:
#			text += '[color=#555555]'+str(player_count)+'[/color]'
#
#	$HBoxContainer/Texts/HBoxContainer/PlayerCount.bbcode_text = '[center]'+text+'[/center]'
#
#	$HBoxContainer/Texts/HBoxContainer/Wrapper/Winter.visible = not card is MysteryCard and card.is_winter()
#	if not card is MysteryCard and card.is_winter():
#		$HBoxContainer/LogoContainer/Logo.modulate = Color(0.7,1,1.3,1)
#
#	if card is MysteryCard:
#		$HBoxContainer/Texts/HBoxContainer/Title.modulate = Color(0.7,0.3,0.7,1)
#		$HBoxContainer/LogoContainer/Logo.scale = Vector2(0.6,0.6)
