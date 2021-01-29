extends Node

const DX = 500
const DY = 600

const DIAMOND = 'environments/diamond'
const BIG_DIAMOND = 'environments/diamond_big'
const MINE = 'weapons/mine'

var displacement = {}

signal done

func get_all_cards():
	return get_tree().get_nodes_in_group('card')

func _ready():
	var cards = get_all_cards()
	for card in cards:
		card.connect('taken', self, '_on_card_taken')
		
		displacement[card.position] = card
		
	# figures
	var figures = []
	for i in cards.size():
		if randf() < 0.08:
			figures.append(MINE)
		else:
			figures.append(DIAMOND)
		
	figures.shuffle()
	
	for i in cards.size():
		cards[i].set_content(figures[i])
		
	# find all mines
	for card in cards:
		if card.get_content() != MINE:
			continue
			
		card.set_tint(Color(1,0.4,0.7))
		
		# surround mines with gold
		var dirs = [
			card.position + Vector2(0, -DY),
			card.position + Vector2(DX, -DY),
			card.position + Vector2(DX, 0),
			card.position + Vector2(DX, DY),
			card.position + Vector2(0, DY),
			card.position + Vector2(-DX, DY),
			card.position + Vector2(-DX, 0),
			card.position + Vector2(-DX, -DY)
		]
		for dir in dirs:
			if displacement.has(dir) and displacement[dir].get_content() != MINE:
				displacement[dir].set_content(BIG_DIAMOND)
				
func intro():
	global.the_match.connect('game_over', self, '_on_game_over')
	
	for card in get_all_cards():
		card.reveal()
		
	yield(get_tree().create_timer(3), "timeout")
	
	for card in get_all_cards():
		card.hide()
		
	yield(get_tree().create_timer(0.5), "timeout")
	
	emit_signal("done")
	
	
func _on_card_taken(card, player, ship):
	# wait a bit after animations
	yield(card, 'revealed')
	
	if card.content == MINE:
		ship.die(null)
		return
	
	yield(get_tree().create_timer(1), "timeout")
	
	var score
	match card.content:
		null:
			return
		DIAMOND:
			score = 1
		BIG_DIAMOND:
			score = 3
			
	global.the_match.add_score(player.id, score)
	global.arena.show_msg(player.species, score, card.position)
	card.queue_free()

# reveal cards at the end of the match
func _on_game_over(_winners):
	for card in get_all_cards():
		card.set_auto_flip_back(false)
		card.set_pause_mode(PAUSE_MODE_PROCESS)
		
	yield(get_tree().create_timer(1), "timeout")
	
	for card in get_all_cards():
		card.reveal()
		
