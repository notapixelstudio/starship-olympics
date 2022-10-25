extends Node

class_name Deck

var cards : Array = [] # of DraftCard
var played_pile : Array = [] # of DraftCard
var next : Array = [] # of DrafCard
var remembered_card_ids : Dictionary = {} # String -> bool

const DECK_PATH = "res://map/draft/decks/"
const CARD_POOL_PATH = "res://map/draft/pool"

var card_pool : CardPool
func _init():
	randomize()
	# starting decks have to provide levels for each player count
	var decks = global.get_resources(DECK_PATH)
	var unlocked_decks = TheUnlocker.get_unlocked_list("starting_decks")
	print("starting deck will be "+ global.starting_deck)
	var starting_deck: StartingDeck = global.get_actual_resource(decks, global.starting_deck)
	#var starting_deck = load(DECK_PATH+'/winter.tres')
	append_cards(starting_deck.deal_cards())
	
	card_pool = CardPool.new()
	for starting_card in starting_deck.cards:
		card_pool.remove_card(starting_card)
	
	next.append_array(starting_deck.get_nexts())

func get_card(card_id: String) -> DraftCard:
	for card in self.cards:
		if card_id == (card as DraftCard).get_id():
			return card
	return null
	
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
			print("New card extracted from next: " + new_card.get_id())
			new_card.set_new(true)
			new_cards.append(new_card)
			remember_card_id(new_card.get_id())
			
	new_cards.shuffle()
	cards = new_cards + cards # new cards are placed on top
	
	# wipe the next array at each refill
	next = []

func put_card_into_played_pile(card) -> void:
	played_pile.append(card)
	
func prepare_next_cards(next_card_ids) -> void:
	if len(next_card_ids) <= 0:
		print("No cards given to prepare as next!")
		return
		
	next_card_ids.shuffle()
	
	var next_cards = []
	for id in next_card_ids:
		if do_you_remember_card_id(id):
			print("Skipping card I already remember: " + id)
			continue
		
		var card = card_pool.retrieve_card(id)
		if card == null:
			print("Skipping null card: " + id)
			continue
			
		if not card.has_level_for_player_count(global.the_game.get_number_of_players()):
			print("Skipping card because of player count = " + str(global.the_game.get_number_of_players()) + ": " + id)
			continue
		
		next.append(card)
		print("Card added to next: " + card.get_id())
	
func remember_card_id(id: String) -> void:
	remembered_card_ids[id] = true
	
func forget_card_id(id: String) -> void:
	remembered_card_ids.erase(id)
	
func do_you_remember_card_id(id: String) -> bool:
	return remembered_card_ids.has(id)

func get_remembered_card_ids() -> Dictionary:
	return remembered_card_ids

func to_dict() -> Dictionary:
	var next_info = self.cards_to_dict(next)
	var played_info = self.cards_to_dict(played_pile)
	return {
		remembered_card_ids=remembered_card_ids,
		next=next_info,
		played_pile=played_info
	}

func cards_to_dict(array_of_cards: Array) -> Array:
	var serialized_cards := []
	for card in array_of_cards:
		serialized_cards.append((card as DraftCard).get_id())
	return serialized_cards

func set_from_dictionary(data: Dictionary):
	next = []
	played_pile = []
	var next_ids = data.get("next", [])
	remembered_card_ids = data.get("remembered_card_ids", self.remembered_card_ids)
	var played_ids = data.get("played_pile", [])
	var next_info = data.get("next", [])
	for next_card_id in next_info:
		next.append(card_pool.retrieve_card(next_card_id))
	for played_card_id in played_ids:
		for card_in_deck in cards:
			if played_card_id == (card_in_deck as DraftCard).get_id():
				print(card_pool.retrieve_card(played_card_id))
				played_pile.append(card_in_deck)
	print(data)
	
