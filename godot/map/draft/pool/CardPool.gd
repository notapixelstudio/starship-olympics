extends Resource

class_name CardPool

export var id : String
export var cards : Array = [] setget set_cards # DraftCard

var index : Dictionary = {}

func set_cards(v: Array):
	cards = v
	for card in cards:
		if card is DraftCard:
			index[card.get_id()] = card
			
	randomize()
	cards.shuffle()

func has(card) -> bool:
	return index.has(card)
	
func retrieve_card(id) -> Minigame:
	if not has(id):
		return null
	var card = index[id]
	index.erase(id)
	return card

func get_card(id) -> DraftCard:
	return index[id]

func remove_card(card) -> void:
	index.erase(card.get_id())
	cards.erase(card)
