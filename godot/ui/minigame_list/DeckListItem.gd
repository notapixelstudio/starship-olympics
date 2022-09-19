tool
extends ColorRect
class_name DeckListItem

export var CardScene : PackedScene
export var card_texture : Texture
export var arrow_texture : Texture
export var shuffle_texture : Texture
export var starting_deck: Resource setget set_starting
var deck: StartingDeck

func set_starting(v: StartingDeck):
	if not is_inside_tree():
		yield(self, "ready")
	starting_deck = v
	set_deck(starting_deck, true)

const CARD_SIZE := Vector2(160, 160)

func set_deck(v: StartingDeck, unlocked: bool) -> void:
	deck = v
	$"%Button".text = deck.get_name().to_upper()
	if not unlocked:
		$"%Title".modulate = Color(0.5,0.5,0.5)
		
	var container
	
	for card in deck.cards:
		container = Container.new()
		container.rect_min_size = CARD_SIZE
		$"%HBoxContainer".add_child(container)
		
		var card_node = CardScene.instance()
		card_node.scale = Vector2(0.42,0.42)
		card_node.position = CARD_SIZE/2 + Vector2(0, 12)
		card_node.set_content_card(card)
		card_node.set_shadow_offset(0)
		container.add_child(card_node)
		card_node.instant_reveal = true
		card_node.reveal()
		
	container = Container.new()
	container.rect_min_size = CARD_SIZE
	$"%HBoxContainer".add_child(container)
	
#	var sprite = Sprite.new()
#
#	if deck.shuffle_before_dealing:
#		sprite.texture = shuffle_texture
#	else:
#		sprite.texture = arrow_texture
#
#	sprite.scale = Vector2(0.2,0.2)
#	sprite.position = CARD_SIZE/2
#	container.add_child(sprite)
#
#	for card in deck.nexts:
#		container = Container.new()
#		container.rect_min_size = CARD_SIZE
#		$"%HBoxContainer".add_child(container)
#
#		var card_node = CardScene.instance()
#		card_node.scale = Vector2(0.25,0.25)
#		card_node.position = CARD_SIZE/2
#		card_node.set_content_card(card)
#		container.add_child(card_node)
#		card_node.instant_reveal = true
#		card_node.reveal()

func grab_focus():
	$"%Button".grab_focus()

func _on_Button_pressed():
	print("{name} has been chosen".format({"name": deck.get_id()}))
	Events.emit_signal("starting_deck_selected", self.deck)
	
