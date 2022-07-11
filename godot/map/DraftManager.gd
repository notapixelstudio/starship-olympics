extends Node

export var this_arena_path : NodePath
export var hand_node_path : NodePath
export var hand_position_node_path : NodePath
export var draft_card_scene : PackedScene

var this_arena
var hand_node : Node
var hand_position : Node

const HAND_SIZE = 4

var players_choices := {} # {InfoPlayer : card}

onready var tween = $Tween

signal selection_finished
signal card_chosen

func _ready():
	Events.connect('continue_after_game_over', self, '_on_continue_after_game_over')
	Events.connect("card_tapped", self, "player_just_chose_a_card")
	
	global.new_session()
	var hand = global.session.get_hand()
	
	this_arena = get_node(this_arena_path)
	hand_node = get_node(hand_node_path) # WARNING is this node ready here?
	
	self.populate_hand(hand.duplicate())
	self.pick_next_card()
	
func _on_continue_after_game_over(session_ended):
	yield(get_tree().create_timer(1.5), "timeout") # this is also needed to wait for entering the tree
	
	var last_match_info = global.session.get_last_match()
	var last_played_card = hand_node.get_card(last_match_info["minigame_id"])
	last_played_card.queue_free()
	
	var ships_have_to_choose = false
	 
	var hand = global.session.get_hand()
	if len(hand) == 0:
		ships_have_to_choose=true
		
		# TODO: almost a duplicate of global.gd, might need some love
		var deck = global.the_game.get_deck()
		
		# fetch a new card
		deck.add_new_card()
		
		hand = deck.draw(HAND_SIZE)
		hand.shuffle()
		global.session.set_hand(hand)
		yield(get_tree().create_timer(1.0), "timeout")
		self.populate_hand(hand.duplicate())
		
	yield(get_tree().create_timer(1.5), "timeout") 
	
	if not session_ended:
		if ships_have_to_choose:
			this_arena.spawn_all_ships(true)
		else:
			# same hand, not yet emptied
			self.pick_next_card()
	else:
		pass # end of session -> new card etc

func player_just_chose_a_card(author, card):
	card.set_player(author.get_player())
	
	self.players_choices[author] = card
	author.get_parent().remove_child(author)
	
	if len(players_choices.keys()) == len(global.the_game.players):
		var cards_to_be_replaced = []
		var hand = global.session.get_hand()
		# everyone chose. Let's remove cards that have not been chosen and 
		# replace them with new one
		for draft_card in hand_node.get_all_cards():
			if draft_card in self.players_choices.values():
				print("well, actually {card_min} has been chosen ".format({"card_min": draft_card.card_content.id}))
			else:
				cards_to_be_replaced.append(draft_card.card_content)
				var index = hand.find(draft_card.card_content)
				hand.pop_at(index)
				
				draft_card.queue_free()
				yield(get_tree().create_timer(0.5), "timeout")
		print("In the hand there are now {num_cards} cards".format({"num_cards": len(hand)}))
		cards_to_be_replaced.shuffle()
		var deck = global.the_game.get_deck()
		var cards_in_deck = []
		for card in deck.cards:
			cards_in_deck.append(card.id)
		print("Discarded phase: cards in deck {missing}".format({"missing": cards_in_deck}))
		global.the_game.deck.put_back_cards(cards_to_be_replaced)
		
		var deck_after_discard = []
		for card in deck.cards:
			deck_after_discard.append(card.id)
		print("Discarded phase: cards in deck {missing}".format({"missing": deck_after_discard}))
		var missing = deck.draw(HAND_SIZE-len(hand))
		# debug mode
		var cards_missing = []
		var cards_hand = []
		var cards_replaced = []
		for card in missing:
			cards_missing.append(card.id)
		for card in hand:
			cards_hand.append(card.id)
		for card in cards_to_be_replaced:
			cards_replaced.append(card.id)
		print("cards to be refilled {missing}".format({"missing": cards_missing}))
		print("cards to be still in hande {hand}".format({"hand": cards_hand}))
		print("cards replaced are {hand}".format({"hand": cards_replaced}))
		
		for card in missing:
			yield(get_tree().create_timer(0.5), "timeout")
			self.add_card(card)
		hand.append_array(missing)
		hand.shuffle()
		global.session.set_hand(hand)
		self.pick_next_card()
		# empty players_choices for the next round
		self.players_choices = {}
	
func pick_next_card():
	# TBD animation
	yield(get_tree().create_timer(3), "timeout")
	
	var picked_card : Minigame = global.session.choose_next_card()
	
	print("Card chosen is {picked}".format({"picked":picked_card.id})) # TBD could be null
	animate_selection(picked_card)
	yield(self, "card_chosen")
	Events.emit_signal("minigame_selected", picked_card)

func add_card(card):
	# will put the card in first empty position
	var draft_card = draft_card_scene.instance()
	draft_card.set_content_card(card)
	for pos_card in hand_node.get_children():
		if pos_card.get_child_count() == 0:
			pos_card.add_child(draft_card)
			break
	yield(get_tree().create_timer(0.5), "timeout")
	draft_card.reveal()
	
	
func populate_hand(hand: Array):
	# shake things up
	hand.shuffle()
	
	for card in hand:
		yield(get_tree().create_timer(0.1), "timeout")
		self.add_card(card)
		
func animate_selection(picked_card: Minigame):
	# This will animate the selection of the chosen card
	var index_selection = 0
	var index = 0
	var chosen_card = null
	var back_pos = Vector2(0,0)
	var back_size = Vector2(1,1)

	for card in hand_node.get_all_cards():
		if card.card_content == picked_card:
			index_selection = index
			back_pos = card.global_position
			back_size = card.scale
			card.z_index = 1000
			chosen_card = card
			tween.interpolate_property(chosen_card, "global_position", chosen_card.global_position, Vector2(0,0), 1.5, Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
			tween.interpolate_property(chosen_card, "scale", chosen_card.scale, Vector2(4,4), 1.5, Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
			
			break
		index+=1
	
	random_selection(hand_node.get_all_cards(), index_selection)
	yield(self, "selection_finished")
	chosen_card.chosen = true
	var wait_time = 0.5
	yield(get_tree().create_timer(wait_time), "timeout")
	chosen_card.chosen = false
	tween.start()
	yield(tween, "tween_all_completed")
	# TODO: danger of lock
	emit_signal("card_chosen")
	yield(get_tree().create_timer(2), "timeout")
	# everything back to position
	chosen_card.global_position = back_pos
	chosen_card.scale = back_size
	chosen_card.z_index = 0
	
func random_selection(list: Array, sel_index, loops=3, max_duration=5):
	list.shuffle()
	list.resize(min(5, len(list)))
	var total_wait: float = 0
	var duration_last_loop = max_duration * 0.8
	var first_loops = max_duration-duration_last_loop
	# each elements will have this speed for the first loops
	var fastest_wait_time = first_loops / len(list) / loops
	print("duration of last loop: " + str(duration_last_loop))
	var num_iterations = len(list)*loops +sel_index
	
	for i in range(num_iterations-1):
		# print("{i}: {what} for {miniga}".format({"i": i, "what": max(fastest_wait_time, duration_last_loop * 1/(pow(2, 1 + num_iterations-i))), "miniga":list[i%len(list)].content.get_id()}))
		var wait_time = max(fastest_wait_time, duration_last_loop * 1/(pow(4, 1 + num_iterations-i)))
		list[i%len(list)].chosen = true
		yield(get_tree().create_timer(wait_time), "timeout")
		total_wait+= wait_time
		list[i%len(list)].chosen = false
	print("Waited for "+ str(total_wait))
	emit_signal("selection_finished")
