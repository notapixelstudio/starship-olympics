extends DraftCard
class_name RandomCard

export var cover : Texture

const CARDS_BASE_DIR := "res://map/draft/cards/"

var _subcard_ids : Array = []
var current_subcard : DraftCard = null

func is_available_for_random_extraction():
	return false # avoid infinite recursion

func on_card_picked() -> void:
	randomize_subcard()

func get_minigame() -> Minigame:
	return current_subcard.get_minigame() if current_subcard else null
	
func randomize_subcard() -> void:
	randomize()
	retrieve_new_subcard() # do it once to change subcard
	while not current_subcard.is_available_for_random_extraction(): # avoid infinite recursion
		retrieve_new_subcard()
	
#func sort_new_subcards_first(a, b):
#	return not (global.the_game.get_deck().get_remembered_card_ids().has(a))

func retrieve_new_subcard() -> void:
	if len(_subcard_ids) <= 0:
		_subcard_ids = TheUnlocker.get_unlocked_list('cards')
		_subcard_ids.shuffle()
		
		# prefer subcards not already seen, if possible - WARNING this doesn't seem to be working
#		_subcard_ids.sort_custom(self, "sort_new_subcards_first")
		
	var cards = global.get_resources(CARDS_BASE_DIR)
	var id = _subcard_ids.pop_front()
	current_subcard = global.get_actual_resource(cards, id)
	
func is_winter() -> bool:
	return current_subcard.is_winter() if current_subcard else false
	
func is_perfectionist() -> bool:
	return current_subcard.is_perfectionist() if current_subcard else false

func get_name() -> String:
	return current_subcard.get_name() if current_subcard else ''
	
func get_icon() -> Texture:
	return get_cover()
	
func get_cover() -> Texture:
	return cover

func get_suit_top() -> Array:
	return current_subcard.get_suit_top()

func get_suit_bottom() -> Array:
	return current_subcard.get_suit_bottom()
