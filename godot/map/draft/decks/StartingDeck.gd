extends Resource

class_name StartingDeck
# This is NOT A DECK

export var id : String
export var name : String
export var cards : Array = [Object(), Object(), Object(), Object()] # DraftCard
export var nexts : Array = [] # DraftCard
export var playlist := false

func get_id() -> String:
	return self.resource_path.get_basename().get_file()
	
func get_name() -> String:
	return name
	
func deal_cards() -> Array:
	var all_cards = cards.duplicate()
	
	if not is_playlist():
		all_cards.shuffle()
		
	return all_cards
	
func get_nexts() -> Array:
	return nexts
	
func is_playlist() -> bool:
	return playlist
