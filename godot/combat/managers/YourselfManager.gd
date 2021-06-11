extends Node

const DX = 500
const DY = 600
const FOUR = 7

const BAD = 'environments/bad_eyes'

var displacement = {}

var players = 0
var cards_left = {}

signal done

func get_all_cards():
	return get_tree().get_nodes_in_group('card')

func _ready():
	var cards = get_all_cards()
	for card in cards:
		card.connect('taken', self, '_on_card_taken')
		
		displacement[card.position] = card
		
	for card in cards:
		card.set_content(BAD)
		
	# place player cards
	var spawners = get_tree().get_nodes_in_group('player_spawner')
	var indices = range(len(cards))
	indices.shuffle()
	indices = indices.slice(0, FOUR * len(spawners)) # add four cards per player
	for ps in spawners:
		if ps.get_player() == null:
			yield(ps, "player_assigned")
		cards_left[ps.get_player()] = FOUR
		players += 1
		for i in range(FOUR):
			cards[indices[0]].set_character_player(ps.get_player())
			indices.pop_front()
			
	for card in cards:
		if card.get_character_player() == null:
			card.set_tint(Color(0.1,0.1,0.1))
		else:
			card.set_content(null)
		
func intro():
	global.the_match.connect('game_over', self, '_on_game_over')
	
	for card in get_all_cards():
		if card.get_character_player() != null:
			card.reveal()
		
	yield(get_tree().create_timer(1 + players), "timeout")
	
	for card in get_all_cards():
		card.hide()
		
	yield(get_tree().create_timer(0.5), "timeout")
	
	emit_signal("done")
	
	
func _on_card_taken(card, player, ship):
	
	if card.get_character_player() == player:
		card.show_mark(cards_left[player])
		cards_left[player] -= 1
		
	# wait a bit after animations
	yield(card, 'revealed')
	
	yield(get_tree().create_timer(1), "timeout")
	
	var score
	if card.get_character_player() == player:
		score = 10
	else:
		score = -1
		if card.get_character_player() == null:
			card.queue_free()
		else:
			card.hide()
			
	global.the_match.add_score(player.id, score)
	global.arena.show_msg(player.species, score, card.global_position)
	
# reveal cards at the end of the match
func _on_game_over(_winners):
	for card in get_all_cards():
		card.set_auto_flip_back(false)
		card.set_pause_mode(PAUSE_MODE_PROCESS)
		
	yield(get_tree().create_timer(1), "timeout")
	
	for card in get_all_cards():
		card.reveal()
		
