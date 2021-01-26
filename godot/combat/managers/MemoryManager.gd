extends Node

const BASIC_FIGURES = [
	'animals/a00',
	'animals/a01',
	'animals/a02',
	'animals/a03',
	'animals/a04'
]
const ADVANCED_FIGURES = [
	'animals/b00',
	'animals/b01',
	'animals/b02',
	'animals/b03',
	'animals/b04',
	'animals/b05',
	'animals/b06',
	'animals/b07',
	'animals/b08',
	'animals/b09',
	'animals/b10'
]
var figures = []
var current_cards = {}

func _ready():
	var cards = get_tree().get_nodes_in_group('card')
	assert(len(cards) == 32)
	for card in cards:
		card.connect('revealing_while_undetermined', self, '_on_card_revealing_while_undetermined')
		card.connect('taken', self, '_on_card_taken')
	
	# ---
	# assign figures to cards
	# ---
	
	# basic figures appear exactly four times each (20 cards in total)
	var basic_figures = BASIC_FIGURES.duplicate() + BASIC_FIGURES.duplicate() + BASIC_FIGURES.duplicate() + BASIC_FIGURES.duplicate()
	basic_figures.shuffle()
	assert(len(basic_figures) == 20)
	
	
	# advanced figures appear in pairs, and sometimes do not appear at all (12 cards in total, so 6 of them out of 11 are shown in a single match)
	var selected_advanced_figures = ADVANCED_FIGURES.duplicate()
	selected_advanced_figures.shuffle()
	selected_advanced_figures = selected_advanced_figures.slice(0, 5)
	
	var advanced_figures = selected_advanced_figures.duplicate() + selected_advanced_figures.duplicate()
	advanced_figures.shuffle()
	assert(len(advanced_figures) == 12)
	
	# the first twelve figures are always basic, the next twelve are a mix, the last eight are always advanced
	figures = basic_figures.slice(0, 11)
	var mix = basic_figures.slice(12, 19) + advanced_figures.slice(0, 3)
	mix.shuffle()
	figures += mix
	figures += advanced_figures.slice(4, 11)
	
	assert(len(figures) == len(cards))
	
func next_figure():
	return figures.pop_front()
	
func _on_card_revealing_while_undetermined(card):
	# card content is determined as they are flipped
	card.set_content(next_figure())
	
func _on_card_taken(card, player):
	# wait a bit after animations
	yield(card, 'revealed')
	yield(get_tree().create_timer(1), "timeout")
	
	if current_cards.has(player):
		# check if a matching pair was made
		if card.equals(current_cards[player]):
			global.the_match.add_score(player.id, 2)
			global.arena.show_msg(player.species, 1, current_cards[player].position)
			global.arena.show_msg(player.species, 1, card.position)
			current_cards[player].queue_free()
			card.queue_free()
		else:
			# flip cards back
			current_cards[player].hide()
			card.hide()
		# in any case, remove the cards from the currently selected ones
		current_cards.erase(player)
	else:
		current_cards[player] = card
