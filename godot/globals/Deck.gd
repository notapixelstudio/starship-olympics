extends Node

class_name Deck

var cards: Array = []
const DECK_PATH = "res://map/draft/"
func _init():
	randomize()
	# we might decide to put this in a 
	var decks = global.get_resources(DECK_PATH)
	var unlocked_decks = TheUnlocker.get_unlocked_list("starting_decks")
	var starting_deck: StartingDeck = global.get_actual_resource(decks, unlocked_decks[0])
	cards.append_array(starting_deck.minigames)
	
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
	
func add_new_cards(new_cards : Array) -> void:
	if len(new_cards) <= 0:
		return
		
	var a_new_card = new_cards.pop_front()
	cards.append_array(new_cards)
	self.shuffle()
	cards.push_front(a_new_card) # one of the new cards is drawn as soon as possible
