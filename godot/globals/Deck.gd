extends Node

class_name Deck

var cards : Array = [] # of DraftCard
var played_pile : Array = [] # of DraftCard
var card_pool : CardPool
var next : Array = []
var remembered_card_ids : Dictionary = {} # String -> bool

const DECK_PATH = "res://map/draft/decks/"
const CARD_POOL_PATH = "res://map/draft/pool"

func _init():
	randomize()
	# starting decks have to provide levels for each player count
	var decks = global.get_resources(DECK_PATH)
	var unlocked_decks = TheUnlocker.get_unlocked_list("starting_decks")
	#var starting_deck: StartingDeck = global.get_actual_resource(decks, unlocked_decks[0])
	var starting_deck = load(DECK_PATH+'/test.tres')
	append_cards(starting_deck.deal_cards())
	
	var pools = global.get_resources(CARD_POOL_PATH)
	var unlocked_pools = TheUnlocker.get_unlocked_list("card_pools")
	card_pool = global.get_actual_resource(pools, unlocked_pools[0])
	
	for starting_card in starting_deck.cards:
		card_pool.remove_card(starting_card)
	
	next.append_array(starting_deck.get_nexts())
	
# could return less than the number of requested cards in corner cases
func draw(how_many : int) -> Array:
	# reshuffe the played pile into the deck if the deck is emptied
	if how_many > len(cards):
		print('deck is about to be emptied (' + str(len(cards)) + ' left, ' + str(how_many) + ' requested).')
		print('reshuffling ' + str(len(played_pile)) + ' cards from the played pile.')
		print(played_pile)
		append_cards(played_pile)
		played_pile = []
		shuffle()
		print('deck now contains ' + str(len(cards)) + ' cards')
		print(cards)
		
	var result = []
	for i in range(min(how_many, len(cards))):
		var card = cards.pop_front()
		assert(card is DraftCard)
		card.on_card_drawn()
		result.append(card)
	return result
	
func shuffle():
	cards.shuffle()
	for card in cards:
		card.set_new(false)
	
# add cards to the deck
func append_cards(cards_to_be_appended : Array) -> void:
	cards.append_array(cards_to_be_appended)
	for new_card in cards_to_be_appended:
		remember_card_id(new_card.get_id())
	
func add_new_cards(amount := 1) -> void:
	next.shuffle()
	var new_cards = []
	for i in range(amount):
		var new_card = next.pop_front()
		if new_card != null:
			new_card.set_new(true)
			new_cards.append(new_card)
			remember_card_id(new_card.get_id())
			
	new_cards.shuffle()
	cards = new_cards + cards # new cards are placed on top
	
	# wipe the next array at each refill, forgetting all cards in it
	for next_card in next:
		forget_card_id(next_card.get_id())
	next = []

func put_card_into_played_pile(card) -> void:
	played_pile.append(card)
	
func prepare_next_cards(next_card_ids) -> void:
	if len(next_card_ids) <= 0:
		return
		
	next_card_ids.shuffle()
	
	var next_cards = []
	for id in next_card_ids:
		if do_you_remember_card_id(id):
			print("Skipping duplicate: " + id)
			continue
		
		var card = card_pool.retrieve_card(id)
		if card == null:
			continue
			
		if not card.has_level_for_player_count(global.the_game.get_number_of_players()):
			continue
		
		next.append(card)
	
func remember_card_id(id: String) -> void:
	remembered_card_ids[id] = true
	
func forget_card_id(id: String) -> void:
	remembered_card_ids.erase(id)
	
func do_you_remember_card_id(id: String) -> bool:
	return remembered_card_ids.has(id)

func get_remembered_card_ids() -> Dictionary:
	return remembered_card_ids
	
