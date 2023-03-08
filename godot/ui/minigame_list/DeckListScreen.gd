extends ScrollContainer

export var DeckListItemScene : PackedScene
const DECK_PATH = "res://map/draft/decks/"

func _ready():
	Events.connect("starting_deck_selected", self, "deck_chosen")
	
	if global.demo:
		choose_random_playlist()
		return
	
	var decks = global.get_resources(DECK_PATH)
	var unlocked_deck_keys = TheUnlocker.get_unlocked_list("starting_decks")
	var i = 0
	var deck_values = decks.values()
	deck_values.sort_custom(self, 'sort_by_order')
	for deck in deck_values:
		# skip non playlists
		if not deck.is_playlist():
			continue
		var item = DeckListItemScene.instance()
		item.set_deck(deck)
		$"%DecksContainer".add_child(item)
		i += 1
	yield(get_tree().create_timer(0.1), "timeout")

	# select previously used deck
#	var found := false
#	for child in $VBoxContainer.get_children():
#		if not child is DeckListItem:
#			continue
#		var deck: StartingDeck = (child as DeckListItem).deck
#		if global.starting_deck_id == deck.get_id():
#			(child as DeckListItem).grab_focus()
#			found = true
#			break
#	if not found:
#		# select the first one, and overwrite the global id
#		var first = $VBoxContainer.get_child(0)
#		var deck: StartingDeck = (first as DeckListItem).deck
#		global.starting_deck_id = deck.get_id() # TBD maybe this should also be persisted somehow?
#		(first as DeckListItem).grab_focus()
	$"%RandomDeckListItem".grab_focus()
	
func sort_by_order(a, b):
	return a.order < b.order
	
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
