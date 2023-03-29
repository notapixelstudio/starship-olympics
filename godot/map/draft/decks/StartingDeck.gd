extends Resource

class_name StartingDeck
# This is NOT A DECK

export var id : String
export var order : int = 0
export var name : String
export var image : StreamTexture
export var cards : Array = [Object(), Object(), Object(), Object()] # DraftCard
export var nexts : Array = [] # DraftCard
export var playlist := false
export var unlocks : Array # [String] # ids of decks (indifferent if they are playlists or not)

func get_id() -> String:
	return self.resource_path.get_basename().get_file()
	
func get_name() -> String:
	return name
	
func deal_cards() -> Array:
	var all_cards = []
	for card in cards:
		# each card should be unique, even if it's the same card
		all_cards.append(card.duplicate())
	
	if not is_playlist():
		all_cards.shuffle()
		
	return all_cards
	
func get_nexts() -> Array:
	return nexts
	
func is_playlist() -> bool:
	return playlist

func get_unlocks() -> Array:
	return unlocks
	
func get_image() -> Texture:
	return image
