tool
extends DeckListItem

const DECK_PATH = "res://map/draft/decks/"

func set_deck(deck: StartingDeck) -> void:
	return

func _on_Button_pressed():
	print("A random playlist has been chosen!")
	var decks = global.get_resources(DECK_PATH)
	var potential_deck_ids = TheUnlocker.get_unlocked_list("starting_decks")
	var potential_playlists := []
	for deck_id in potential_deck_ids:
		if decks[deck_id].is_playlist():
			potential_playlists.append(decks[deck_id])
			
	if len(potential_playlists) <= 0:
		return
		
	var deck = potential_playlists[randi() % len(potential_playlists)]
	print("playlist {name} has been randomly chosen".format({"name": deck.get_id()}))
	Events.emit_signal("starting_deck_selected", deck)
