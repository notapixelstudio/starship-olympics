extends Resource

class_name CardPool

export var id : String
export var cards : Array = [] setget set_cards, get_cards # DraftCard
var index : Dictionary = {}
const CARD_POOL_PATH = "res://map/draft/cards"

func _init():
	index = global.get_resources(CARD_POOL_PATH)
	cards = index.values()


func get_id() -> String:
	return id

func set_cards(v: Array):
	cards = v
	for card in cards:
		assert(card is DraftCard)
		index[card.get_id()] = card
		
	randomize()
	cards.shuffle()

func has(card_id: String) -> bool:
	return index.has(card_id)
	
func retrieve_card(id) -> DraftCard:
	if not has(id):
		return null
	var card = index[id]
	return card

func get_card(id) -> DraftCard:
	return index[id]

func get_cards() -> Array:
	return cards
