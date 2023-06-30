extends ScrollContainer

export var DeckListItemScene : PackedScene
const DECK_PATH = "res://map/draft/decks/"
const PATH_FILE_CHAMPIONS = "user://hall_of_fame.json"

func _ready():
	Events.connect("starting_deck_selected", self, "deck_chosen")
	var playlist_info = {}
	var data = global.read_file_by_line(InfoChampion.PATH_FILE_CHAMPIONS)
	for winner_info in data:
		var starting_deck_id = winner_info["session_info"].get("starting_deck")
		if starting_deck_id:
			playlist_info[starting_deck_id] = {
				'username': winner_info["player"]["username"],
				'species': winner_info["player"]["species"]
			}
	
	var decks = global.get_resources(DECK_PATH)
	var unlocked_deck_keys = TheUnlocker.get_unlocked_list("starting_decks")
	var new_deck_keys = TheUnlocker.get_unlocked_list("starting_decks", TheUnlocker.NEW)
	unlocked_deck_keys.append_array(new_deck_keys)
	var i = 0
	var deck_values = decks.values()
	deck_values.sort_custom(self, 'sort_by_order')
	for deck in deck_values:
		# skip non playlists
		if not deck.is_playlist() or not deck.get_id() in unlocked_deck_keys:
			continue
		var item = DeckListItemScene.instance()
		item.set_deck(deck)
		if playlist_info.get(deck.get_id()):
			item.add_flag(playlist_info.get(deck.get_id()))
		item.set_index(i)
		$"%DecksContainer".add_child(item)
		i += 1
	yield(get_tree().create_timer(0.1), "timeout")
	
	# select latest deck
	var found := false
	for child in $"%DecksContainer".get_children():
		if not child is DeckListItem:
			continue
		child.grab_focus()
		break
	
#	$"%RandomDeckListItem".grab_focus()
	
	if global.demo:
		choose_random_playlist()
		return
	
func sort_by_order(a, b):
	return a.order > b.order
	
func deck_chosen(starting_deck: StartingDeck):
	global.starting_deck_id = starting_deck.get_id()
	Events.emit_signal("selection_starting_deck_over")

func choose_random_playlist():
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
	
func _on_RandomDeckListItem_pressed():
	choose_random_playlist()

func _on_BackButton_pressed():
	queue_free()
	Events.emit_signal("nav_to_character_selection")
	
