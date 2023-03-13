tool
extends DeckListItem

signal pressed

const DECK_PATH = "res://map/draft/decks/"

func _ready():
	$"%Button".set_text('RANDOM WORLD')
func set_deck(deck: StartingDeck) -> void:
	return

func _on_Button_pressed():
	emit_signal('pressed')
