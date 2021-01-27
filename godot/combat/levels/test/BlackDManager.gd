extends Node

const DIAMOND = 'environments/diamond'
const BIG_DIAMOND = 'environments/diamond_big'
const BLACK_DIAMOND = 'environments/diamond_black'

var luck = 0.99999999

func get_all_cards():
	return get_tree().get_nodes_in_group('card')

func _ready():
	var cards = get_all_cards()
	assert(len(cards) == 32)
	for card in cards:
		card.connect('revealing_while_undetermined', self, '_on_card_revealing_while_undetermined')
		card.connect('taken', self, '_on_card_taken')
	
func next_figure():
	if randf() > luck:
		return BLACK_DIAMOND
	luck *= luck # the chance of getting a black diamond increases for each new card
	
	if randf() > luck*0.8:
		return null # there's also an increasing chance of getting an empty card
	
	if randf() < 0.1:
		return BIG_DIAMOND
		
	return DIAMOND
	
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
