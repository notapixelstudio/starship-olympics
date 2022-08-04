extends ColorRect
class_name DeckListItem

export var CardScene : PackedScene
export var card_texture : Texture
export var arrow_texture : Texture
export var shuffle_texture : Texture

var deck: StartingDeck

const CARD_SIZE := Vector2(96, 96)

func set_deck(v: StartingDeck, unlocked: bool) -> void:
	deck = v
	$VBoxContainer/Title.text = deck.get_name()
	if not unlocked:
		$VBoxContainer/Title.modulate = Color(0.5,0.5,0.5)
		
	var container
	
	for card in deck.cards:
		container = Container.new()
		container.rect_min_size = CARD_SIZE
		$VBoxContainer/HBoxContainer.add_child(container)
		
		var card_node = CardScene.instance()
		card_node.scale = Vector2(0.25,0.25)
		card_node.position = CARD_SIZE/2
		card_node.set_content_card(card)
		container.add_child(card_node)
		card_node.instant_reveal = true
		card_node.reveal()
		
	container = Container.new()
	container.rect_min_size = CARD_SIZE
	$VBoxContainer/HBoxContainer.add_child(container)
	
	var sprite = Sprite.new()
	
	if deck.shuffle_before_dealing:
		sprite.texture = shuffle_texture
	else:
		sprite.texture = arrow_texture
		
	sprite.scale = Vector2(0.2,0.2)
	sprite.position = CARD_SIZE/2
	container.add_child(sprite)
	
	for card in deck.nexts:
		container = Container.new()
		container.rect_min_size = CARD_SIZE
		$VBoxContainer/HBoxContainer.add_child(container)
		
		var card_node = CardScene.instance()
		card_node.scale = Vector2(0.25,0.25)
		card_node.position = CARD_SIZE/2
		card_node.set_content_card(card)
		container.add_child(card_node)
		card_node.instant_reveal = true
		card_node.reveal()
