extends Resource

class_name CardPool

@export var id : String
@export var cards : Array[Resource] :
	set(value):
		cards = value
		for card in cards:
			
			index[(card as DraftCard).get_id()] = card
				
		randomize()
		cards.shuffle()
	
var index : Dictionary = {}

func get_id() -> String:
	return id

func has(card_id: String) -> bool:
	return index.has(card_id)
	
func retrieve_card(id) -> DraftCard:
	if not has(id):
		return null
	var card = index[id]
	return card

func get_card(id) -> DraftCard:
	return index[id]

func remove_card(card) -> void:
	index.erase(card.get_id())
	cards.erase(card)
