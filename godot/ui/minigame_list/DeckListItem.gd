@tool
extends ColorRect
class_name DeckListItem

@export var CardScene : PackedScene
@export var card_texture : Texture2D
@export var arrow_texture : Texture2D
@export var shuffle_texture : Texture2D
@export var starting_deck: Resource :
	get:
		return starting_deck # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_starting
var deck: StartingDeck

func set_starting(v: StartingDeck):
	if not is_inside_tree():
		await self.ready
	starting_deck = v
	set_deck(starting_deck, true)

const CARD_SIZE := Vector2(96, 96)

func set_deck(v: StartingDeck, unlocked: bool) -> void:
	deck = v
	$"%MapRadio".minimum_size.x = 0
	$"%MapRadio".text = deck.get_name() 
	$"%MapRadio".minimum_size.x = $"%MapRadio".size.x + 100
	if not unlocked:
		$"%Title".modulate = Color(0.5,0.5,0.5)
		
	var container
	
	for card in deck.cards:
		container = Container.new()
		container.minimum_size = CARD_SIZE
		$"%HBoxContainer".add_child(container)
		
		var card_node = CardScene.instantiate()
		card_node.scale = Vector2(0.25,0.25)
		card_node.position = CARD_SIZE/2
		card_node.set_content_card(card)
		container.add_child(card_node)
		card_node.instant_reveal = true
		card_node.reveal()
		
	container = Container.new()
	container.minimum_size = CARD_SIZE
	$"%HBoxContainer".add_child(container)
	
	var sprite = Sprite2D.new()
	
	if deck.shuffle_before_dealing:
		sprite.texture = shuffle_texture
	else:
		sprite.texture = arrow_texture
		
	sprite.scale = Vector2(0.2,0.2)
	sprite.position = CARD_SIZE/2
	container.add_child(sprite)
	
	for card in deck.nexts:
		container = Container.new()
		container.minimum_size = CARD_SIZE
		$"%HBoxContainer".add_child(container)
		
		var card_node = CardScene.instantiate()
		card_node.scale = Vector2(0.25,0.25)
		card_node.position = CARD_SIZE/2
		card_node.set_content_card(card)
		container.add_child(card_node)
		card_node.instant_reveal = true
		card_node.reveal()


func _on_MapRadio_toggled(button_pressed):
	if button_pressed:
		print("{name} has been chosen".format({"name":deck.get_id()}))
		Events.emit_signal("starting_deck_selected", self.deck)
		
func grab_focus():
	$"%MapRadio".grab_focus()
