extends ScrollContainer

export var DeckListItemScene : PackedScene
export var show_locked : bool = false
const DECK_PATH = "res://map/draft/decks/"

func _ready():
	Events.connect("starting_deck_selected", self, "deck_chosen")
	var decks = global.get_resources(DECK_PATH)
	var unlocked_deck_keys = TheUnlocker.get_unlocked_list("starting_decks")
	var i = 0
	for key in unlocked_deck_keys:
		var deck = decks[key]  # global.get_actual_resource(decks, unlocked_decks[i])
		var item = DeckListItemScene.instance()
		item.set_deck(deck, true)
		if i % 2:
			item.color = Color(0,0,0,0.2)
		$VBoxContainer.add_child(item)
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
	$VBoxContainer.get_child(0).grab_focus()
	
func deck_chosen(starting_deck: StartingDeck):
	global.starting_deck_id = starting_deck.get_id()
	Events.emit_signal("selection_starting_deck_over")

func _on_FightButton_pressed():
	var decks = global.get_resources(DECK_PATH)
	var potential_deck_ids = TheUnlocker.get_unlocked_list("starting_decks")
	potential_deck_ids.append_array(TheUnlocker.get_unlocked_list("starting_decks", TheUnlocker.HIDDEN))
	var potential_playlists := []
	for deck_id in potential_deck_ids:
		if decks[deck_id].is_playlist():
			potential_playlists.append(decks[deck_id])
			
	if len(potential_playlists) <= 0:
		return
		
	var deck = potential_playlists[randi() % len(potential_playlists)]
	print("playlist {name} has been randomly chosen".format({"name": deck.get_id()}))
	Events.emit_signal("starting_deck_selected", deck)
