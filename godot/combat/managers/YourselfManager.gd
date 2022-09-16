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
		card.connect('taken',Callable(self,'_on_card_taken'))
		
		displacement[card.position] = card
		
	for card in cards:
		card.set_content(BAD)
		
func place_player_cards():
	var cards = get_all_cards()
	var spawners = get_tree().get_nodes_in_group('player_spawner')
	var indices = range(len(cards))
	indices.shuffle()
	indices = indices.slice(0, FOUR * len(spawners)) # add four cards per player
	for ps in spawners:
		if ps.get_player() == null:
			await ps.player_assigned
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
	place_player_cards()
	
	Events.connect('match_ended',Callable(self,'_on_match_ended'))
	
	for card in get_all_cards():
		if card.get_character_player() != null:
			card.reveal()
		
	await get_tree().create_timer(1 + players).timeout
	
	for card in get_all_cards():
		card.hide()
		
	await get_tree().create_timer(0.5).timeout
	
	emit_signal("done")
	
	
func _on_card_taken(card, player, ship):
	
	if card.get_character_player() == player:
		card.show_mark(cards_left[player])
		cards_left[player] -= 1
	elif card.get_character_player() != null: # enemy character
		card.show_mark(cards_left[card.get_character_player()])
		cards_left[card.get_character_player()] -= 1
		
	# wait a bit after animations
	await card.revealed
	
	await get_tree().create_timer(1).timeout
	
	# do nothing if the game has already ended
	if not global.is_match_running():
		return
	
	var score
	var affected_player = player
	var position = card.global_position
	if card.get_character_player() == player:
		score = 10
	else:
		if card.get_character_player() == null:
			score = -1
			card.queue_free()
		else: # enemy character
			score = 10
			affected_player = card.get_character_player()
			position = global.arena.get_ship_from_player_id(affected_player.id).global_position
			
	global.the_match.add_score(affected_player.id, score)
	global.arena.show_msg(affected_player.species, score, position)
	
# reveal cards at the end of the match
func _on_match_ended():
	for card in get_all_cards():
		card.set_auto_flip_back(false)
		card.set_process_mode(PROCESS_MODE_ALWAYS)
		
	await get_tree().create_timer(1).timeout
	
	for card in get_all_cards():
		card.reveal()
		
