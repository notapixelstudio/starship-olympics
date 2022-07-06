extends Node

class_name Deck

var cards: Array = []
var card_pool : CardPool

const DECK_PATH = "res://map/draft/"
const CARD_POOL_PATH = "res://map/draft/pool"

func _init():
	randomize()
	# we might decide to put this in a 
	var decks = global.get_resources(DECK_PATH)
	var unlocked_decks = TheUnlocker.get_unlocked_list("starting_decks")
	var starting_deck: StartingDeck = global.get_actual_resource(decks, unlocked_decks[0])
	cards.append_array(starting_deck.minigames)
	
	var pools = global.get_resources(CARD_POOL_PATH)
	var unlocked_pools = TheUnlocker.get_unlocked_list("card_pools")
	card_pool = global.get_actual_resource(pools, unlocked_pools[0])
	
	self.shuffle()
	
func draw(how_many : int) -> Array:
	var result = []
	for i in range(how_many):
		result.append(cards.pop_front())
	return result
	
func shuffle():
	cards.shuffle()
	
func put_back_cards(cards_to_put_back : Array) -> void:
	cards.append_array(cards_to_put_back)
	self.shuffle()
	
func add_new_card() -> void:
	self.shuffle()
	var new_card = card_pool.get_new_card()
	if new_card != null:
		cards.push_front(new_card) # the new card is drawn as soon as possible
