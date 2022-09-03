extends ScrollContainer

export var DeckListItemScene : PackedScene

const DECK_PATH = "res://map/draft/decks/"

func _ready():
	var decks = global.get_resources(DECK_PATH)
	var unlocked_decks = TheUnlocker.get_unlocked_list("starting_decks")
	var i = 0
	for key in decks:
		var deck = decks[key]#global.get_actual_resource(decks, unlocked_decks[i])
		var item = DeckListItemScene.instance()
		item.set_deck(deck, unlocked_decks.has(key))
		if i % 2:
			item.color = Color(0,0,0,0.2)
		$VBoxContainer.add_child(item)
		i += 1
		
