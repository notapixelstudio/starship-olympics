extends Node

class_name Deck

var cards : Array = ['res://combat/minigames/crown','diamond','slam','deathmatch']
var card_resources: Array = []

func _init():
	randomize()
	self.shuffle()
	global.get_resources("res://combat/minigames/")
	var unlocked_decks = TheUnlocker.get_unlocked_list("starting_decks")
	#for resource_id in unlocked_decks:
	#	card_resources.append(global.get_actual_resource(unlocked_minigames, resource_id))
	
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
