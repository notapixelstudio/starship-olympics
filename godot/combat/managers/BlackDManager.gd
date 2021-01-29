extends Node

const DIAMOND = 'environments/diamond'
const BIG_DIAMOND = 'environments/diamond_big'
const BLACK_DIAMOND = 'environments/diamond_black'

var figures = []

func get_all_cards():
	return get_tree().get_nodes_in_group('card')

func _ready():
	var cards = get_all_cards()
	assert(len(cards) == 32)
	for card in cards:
		card.connect('revealing_while_undetermined', self, '_on_card_revealing_while_undetermined')
		card.connect('taken', self, '_on_card_taken')
	
	# figures
	for i in cards.size():
		figures.append(DIAMOND if randf() < 0.5 else BIG_DIAMOND if randf() < 0.6 else null)
		
	figures.shuffle()
	figures[2 + randi() % 30] = BLACK_DIAMOND # skip first two flips
	
func next_figure():
	return figures.pop_front()
	
func _on_card_revealing_while_undetermined(card):
	# card content is determined as they are flipped
	card.set_content(next_figure())
	
func _on_card_taken(card, player):
	# wait a bit after animations
	yield(card, 'revealed')
	yield(get_tree().create_timer(1), "timeout")
	
	var score
	match card.content:
		null:
			return
		DIAMOND:
			score = 1
		BIG_DIAMOND:
			score = 3
		BLACK_DIAMOND:
			score = -100
			
	global.the_match.add_score(player.id, score)
	global.arena.show_msg(player.species, score, card.position)
	card.queue_free()
