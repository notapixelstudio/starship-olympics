tool
extends DeckListItem

signal pressed

const DECK_PATH = "res://map/draft/decks/"
const RANDOM_TEXTURE = preload("res://assets/map/cards/planets/random_planet.png")

func _ready():
	$"%Button".set_label('RANDOM WORLD')
	$"%Button".set_image(RANDOM_TEXTURE)
	
func set_deck(deck: StartingDeck) -> void:
	return

func _on_Button_pressed():
	emit_signal('pressed')
